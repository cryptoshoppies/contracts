// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@opengsn/contracts/src/interfaces/IERC2771Recipient.sol";
import "@opengsn/contracts/src/ERC2771Recipient.sol";
import "contracts/common/Counters.sol";
import "contracts/common/IBreeding.sol";
import "contracts/common/GenesUtil.sol";

contract NFT is ERC721, Ownable, ERC2771Recipient {
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

    Counters.Counter private _currTokenId;
    mapping(uint256 => Token) private _tokens;
    address private _breedingContract;
    string private _contractURI;
    string private _baseURL;
    string private _baseExtension = ".json";

    // --------------------------------------------------------------------
    // CONSTRUCTOR
    // --------------------------------------------------------------------

    constructor() ERC2771Recipient() ERC721("ShoToken", "SHOTKN") {}

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
        Token memory token = Token({
            parent1: parent1,
            parent2: parent2,
            genes: genes
        });

        Counters.increment(_currTokenId);
        uint256 tokenId = Counters.current(_currTokenId);

        _tokens[tokenId] = token;
        _safeMint(owner(), tokenId);

        emit WasBorn(tokenId, parent1, parent2, genes);

        return tokenId;
    }

    // --------------------------------------------------------------------
    // NFT
    // --------------------------------------------------------------------

    // geters
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

    function totalSupply() external view returns (uint256) {
        return Counters.current(_currTokenId);
    }

    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    function getBreedingContract() external view returns (address) {
        return _breedingContract;
    }

    // setters
    function setBaseExtension(string memory extension) external onlyOwner {
        _baseExtension = extension;
    }

    function setContractURI(string calldata uri) external onlyOwner {
        _contractURI = uri;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        _baseURL = uri;
    }

    function setBreedingContract(address breedingContract) public onlyOwner {
        _breedingContract = breedingContract;
    }

    //
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
            string(
                abi.encodePacked(_baseURL, tokenId.toString(), _baseExtension)
            );
    }

    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success);
    }

    // --------------------------------------------------------------------
    // GSN
    // --------------------------------------------------------------------

    function isTrustedForwarder(address forwarder)
        public
        view
        override
        returns (bool)
    {
        return ERC2771Recipient.isTrustedForwarder(forwarder);
    }

    function _msgSender()
        internal
        view
        override(Context, ERC2771Recipient)
        returns (address)
    {
        return ERC2771Recipient._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(Context, ERC2771Recipient)
        returns (bytes calldata)
    {
        return ERC2771Recipient._msgData();
    }
}
