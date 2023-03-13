// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "contracts/common/IBreeding.sol";
import "contracts/common/GenesUtil.sol";
import "contracts/breedings/Breeding.sol";

/// @custom:security-contact supportcs@ntiloyalty.com
contract ShoToken is ERC721, Pausable, Ownable, ERC721Burnable {
    // --------------------------------------------------------------------
    // STRUCT
    // --------------------------------------------------------------------

    struct Token {
        // mom tokenId, (can be 0)
        uint256 parent1;
        // dad tokenId, (can be 0)
        uint256 parent2;
        // genes
        uint256 genes;
    }

    // --------------------------------------------------------------------
    // USING
    // --------------------------------------------------------------------

    using Strings for uint256;
    using Counters for Counters.Counter;
    using GenesUtil for uint256;

    // --------------------------------------------------------------------
    // EVENTS
    // --------------------------------------------------------------------

    event WasBorn(
        uint256 tokenId,
        uint256 parent1,
        uint256 parent2,
        uint256 genes
    );

    event Charged(uint256 tokenId, uint256 genes);

    // --------------------------------------------------------------------
    // FIELDS
    // --------------------------------------------------------------------

    Counters.Counter private _tokenIdCounter;
    mapping(uint256 => Token) private _tokens;
    address private _breedingContract;
    uint256 private _minId = 1;
    uint256 private _maxId = 36;

    // --------------------------------------------------------------------
    // CONSTRUCTOR
    // --------------------------------------------------------------------

    constructor() ERC721("ShoToken", "SHOTKN") {
        _breedingContract = address(new Breeding());
    }

    function _baseURI() internal pure override returns (string memory) {
        return "nft.cryptoshopee.ntiloyalty.com";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // --------------------------------------------------------------------
    // SERVER METHODS
    // --------------------------------------------------------------------

    /// server method - mint nft
    /// @param genes - genes, generation and charge
    function mint(uint256 genes) external onlyOwner returns (uint256) {
        return createToken(0, 0, genes);
    }

    /// server method - make a new child
    function breeding(uint256 token1, uint256 token2)
        external
        onlyOwner
        returns (uint256 newTokenId)
    {
        require(_exists(token1), "query for nonexistent token");
        require(_exists(token2), "query for nonexistent token");

        Token storage mom = _tokens[token1];
        Token storage dad = _tokens[token2];

        // breading with mom and dad
        (uint256 momOut, uint256 dadOut, uint256 child) = IBreeding(
            _breedingContract
        ).breading(mom.genes, dad.genes);

        newTokenId = createToken(token1, token2, child);

        mom.genes = momOut;
        dad.genes = dadOut;

        return newTokenId;
    }

    /// server method - charge NFT
    function charge(uint256 tokenId, uint8 value) external onlyOwner {
        require(_exists(tokenId), "query for nonexistent token");

        uint256 genes = _tokens[tokenId].genes;
        uint256 newGenes = GenesUtil.setCharges(
            genes,
            GenesUtil.getCharges(genes) + value
        );
        _tokens[tokenId].genes = newGenes;

        emit Charged(tokenId, newGenes);
    }

    // --------------------------------------------------------------------
    // PRIVATE
    // --------------------------------------------------------------------

    function createToken(
        uint256 parent1,
        uint256 parent2,
        uint256 genes
    ) private returns (uint256) {
        uint256 bodyPartsCount = 9;
        for (
            uint8 bodyPartIndex = 0;
            bodyPartIndex < bodyPartsCount;
            bodyPartIndex++
        ) {
            uint8 id = GenesUtil.getId(genes, bodyPartIndex);
            require(
                id >= _minId && id <= _maxId,
                "error, createToken, part id must be in range"
            );

            uint8 level = GenesUtil.getLevel(genes, bodyPartIndex);
            require(
                level > 0,
                "error, createToken, part level must be greater than 0"
            );
        }

        Token memory token = Token({
            parent1: parent1,
            parent2: parent2,
            genes: genes
        });

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        _tokens[tokenId] = token;
        _safeMint(owner(), tokenId);

        emit WasBorn(tokenId, parent1, parent2, genes);

        return tokenId;
    }

    // --------------------------------------------------------------------
    // SETTINGS
    // --------------------------------------------------------------------

    // --------------------------------------------------------------------

    function getMinId() public view returns (uint256) {
        return _minId;
    }

    function setMinId(uint256 value) public onlyOwner {
        _minId = value;
    }

    // --------------------------------------------------------------------

    function getMaxId() public view returns (uint256) {
        return _maxId;
    }

    function setMaxId(uint256 value) public onlyOwner {
        _maxId = value;
    }

    // --------------------------------------------------------------------

    function getBreedingContract() external view returns (address) {
        return _breedingContract;
    }

    function setBreedingContract(address breedingContract) public onlyOwner {
        _breedingContract = breedingContract;
    }

    // --------------------------------------------------------------------

    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter.current();
    }

    // --------------------------------------------------------------------

    function getToken(uint256 tokenId)
        public
        view
        returns (
            uint256 mom,
            uint256 dad,
            uint256 genes
        )
    {
        Token storage token = _tokens[tokenId];
        return (token.parent1, token.parent2, token.genes);
    }

    // --------------------------------------------------------------------

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return
            string(abi.encodePacked(_baseURI(), tokenId.toString(), ".json"));
    }

    // --------------------------------------------------------------------

    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success);
    }
}
