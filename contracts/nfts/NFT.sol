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
    struct Token {
        uint256 parent1;
        uint256 parent2;
        uint256 genes;
    }

    using Strings for uint256;
    using Counters for Counters.Counter;
    using GenesUtil for uint256;

    event WasBorn(
        uint256 tokenId,
        uint256 parent1,
        uint256 parent2,
        uint256 genes
    );

    event Charged(uint256 tokenId, uint256 genes);

    Counters.Counter private _currTokenId;
    uint8 private _breedingPrice = 1;
    mapping(uint256 => Token) private _tokens;
    address private _breedingContract;
    string private _contractURI;
    string private _baseURL;
    string private _baseExtension = ".json";

    constructor() ERC2771Recipient() ERC721("ShoToken", "SHOTKN") {}

    // --------------------------------------------------------------------
    // SERVER METHODS
    // --------------------------------------------------------------------

    // server method
    /// @param genes - genes, generation and charge
    function mint(uint256 genes) external onlyOwner returns (uint256) {
        return createToken(0, 0, genes);
    }

    // server method
    // make a new child
    function breeding(uint256 token1, uint256 token2)
        external
        onlyOwner
        returns (uint256 newTokenId)
    {
        require(_exists(token1), "query for nonexistent token");
        require(_exists(token2), "query for nonexistent token");

        //WARNING: Якщо в ми ніде не зберігаємо власника токена в контракті, то неможливо перевірити в контракті чи він має право робити бридінг!
        Token storage mom = _tokens[token1];
        Token storage dad = _tokens[token2];

        // TODO: Або ж логіку можна задати як сумму енергії баться і мами, або в залежності від генерації задати массив вартостей
        require(
            GenesUtil.getCharges(mom.genes) >= _breedingPrice,
            "insufficient charge"
        );
        require(
            GenesUtil.getCharges(dad.genes) >= _breedingPrice,
            "insufficient charge"
        );

        // Визначення генерації виніс сюди, щоб не тягати дві змінні в інший контракт, якщо треба, то можна перемістити в IBreeding
        uint256 newGenes = IBreeding(_breedingContract).breading(
            mom.genes,
            dad.genes
        );

        newTokenId = createToken(token1, token2, newGenes);

        mom.genes = GenesUtil.setCharges(
            mom.genes,
            GenesUtil.getCharges(mom.genes) - _breedingPrice
        );
        dad.genes = GenesUtil.setCharges(
            dad.genes,
            GenesUtil.getCharges(dad.genes) - _breedingPrice
        );

        return newTokenId;
    }

    // charge NFT (we have to be a payer)
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
    ) internal returns (uint256) {
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
    function totalSupply() external view returns (uint256) {
        return Counters.current(_currTokenId);
    }

    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    // setters
    function setBaseExtension(string memory extension) external onlyOwner {
        _baseExtension = extension;
    }

    function setContractURI(string calldata URI) external onlyOwner {
        _contractURI = URI;
    }

    function setBaseURI(string memory URI) external onlyOwner {
        _baseURL = URI;
    }

    function setBreedingContract(address breedingContract) public onlyOwner {
        _breedingContract = breedingContract;
    }

    function setBreedingPrice(uint8 price) public onlyOwner {
        _breedingPrice = price;
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
