// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@opengsn/contracts/src/interfaces/IERC2771Recipient.sol";
import "@opengsn/contracts/src/ERC2771Recipient.sol";
import "contracts/common/Counters.sol";
import "contracts/common/ICoin.sol";
import "contracts/common/IBreeding.sol";

contract Cryptoshopee is ERC721, Ownable, ERC2771Recipient {
    using Strings for uint256;
    using Counters for Counters.Counter;

    event WasBorn(
        uint256 tokenId,
        uint256 parent1,
        uint256 parent2,
        uint256 genes
    );
    event Charged(uint256 tokenId, uint8 charge);

    Counters.Counter private _currTokenId;
    uint8 private _breedingPrice;

    struct Token {
        uint256 parent1;
        uint256 parent2;
        uint256 genes;
        uint256 generation;
        uint8 charge;
    }

    mapping(uint256 => Token) private Tokens;

    address private _coinContract;
    address private _breedingContract;

    string private _contractURI;
    string private _baseURIPrivate;
    string private _baseExtension = ".json";

    constructor() ERC2771Recipient() ERC721("Cryptoshopee", "CSHP") {}

    // цей метод має викликатись сервером для створення НФТ при скануванні QR- коду.
    /// @param _genes гени токену з картки
    /// @param _charge заряд токена для 0 генерації
    function Mint(uint256 _genes, uint8 _charge)
        external
        onlyOwner
        returns (uint256)
    {
        return (CreateToken(0, 0, 0, _genes, _charge));
    }

    function CreateToken(
        uint256 _parent1,
        uint256 _parent2,
        uint256 _generation,
        uint256 _genes,
        uint8 _charge
    ) internal returns (uint256) {
        Token memory _token = Token({
            parent1: _parent1,
            parent2: _parent2,
            genes: _genes,
            generation: _generation,
            charge: _charge
        });

        Counters.increment(_currTokenId);
        uint256 tokenId = Counters.current(_currTokenId);

        Tokens[tokenId] = _token;
        _safeMint(owner(), tokenId);

        emit WasBorn(tokenId, _parent1, _parent2, _genes);

        return tokenId;
    }

    /// Створення нового покоління токену.
    function Breeding(uint256 token1, uint256 token2)
        external
        onlyOwner
        returns (uint256 _newTokenId)
    {
        require(_exists(token1), "query for nonexistent token");
        require(_exists(token2), "query for nonexistent token");
        //WARNING: Якщо в ми ніде не зберігаємо власника токена в контракті, то неможливо перевірити в контракті чи він має право робити бридінг!
        Token storage mom = Tokens[token1];
        Token storage dad = Tokens[token2];

        // TODO: Або ж логіку можна задати як сумму енергії баться і мами, або в залежності від генерації задати массив вартостей
        require(mom.charge >= _breedingPrice, "insufficient charge");
        require(dad.charge >= _breedingPrice, "insufficient charge");

        // Визначення генерації виніс сюди, щоб не тягати дві змінні в інший контракт, якщо треба, то можна перемістити в IBreeding
        uint256 generation = (mom.generation + dad.generation) / 2 + 1;
        uint256 _newGenes = IBreeding(_breedingContract).breading(
            mom.genes,
            dad.genes,
            generation
        );

        _newTokenId = CreateToken(token1, token2, generation, _newGenes, 1);

        mom.charge -= _breedingPrice;
        dad.charge -= _breedingPrice;

        return _newTokenId;
    }

    function Charge(uint256 tokenId, uint8 value) external onlyOwner {
        require(_exists(tokenId), "query for nonexistent token");

        ICoin(_coinContract).pay(value);

        Tokens[tokenId].charge += value;

        emit Charged(tokenId, value);
    }

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
        _baseURIPrivate = URI;
    }

    function setCoinContract(address coinContract) public onlyOwner {
        _coinContract = coinContract;
    }

    function setBreedingContract(address breedingContract) public onlyOwner {
        _breedingContract = breedingContract;
    }

    function setBreedingPrice(uint8 breedingPrice) public onlyOwner {
        _breedingPrice = breedingPrice;
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
                abi.encodePacked(_baseURIPrivate, tokenId.toString(), _baseExtension)
            );
    }

    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success);
    }

    // GSN
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
