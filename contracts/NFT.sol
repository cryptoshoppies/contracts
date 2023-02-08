// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@opengsn/contracts/src/interfaces/IERC2771Recipient.sol";
import "@opengsn/contracts/src/ERC2771Recipient.sol";
import "contracts/common/Counters.sol";
import "contracts/common/ICoin.sol";
import "contracts/common/IBreeding.sol";

contract NFT is ERC721, Ownable, ERC2771Recipient {
    struct Part {
        uint8 id;
        uint8 level;
        uint8 arcane;
    }

    event Born(
        uint256 tokenId,
        uint256 parent1,
        uint256 parent2,
        uint32 charges,
        Part[9] genes
    );

    struct Token {
        uint256 parent1;
        uint256 parent2;
        uint256 generation;
        uint8 charge;
        Part[9] genes;
    }

    using Counters for Counters.Counter;

    Counters.Counter private _currTokenId;

    constructor() ERC2771Recipient() ERC721("ShoNFT", "SHONFT") {}

    function chargeNFT(uint256 tokenId, uint8 value) external onlyOwner {
        require(_exists(tokenId), "query for nonexistent token");

        ICoin(_coinContract).pay(value);

        Tokens[tokenId].charge += value;

        emit Charged(tokenId, value);
    }

    function breading(bytes genes1, bytes genes2)
        external
        onlyOwner
        returns (bytes)
    {
        

    }

    function test() external pure returns (Token memory) {
        Part[9] memory part = [
            Part(1, 1, 1),
            Part(1, 1, 1),
            Part(1, 1, 1),
            Part(1, 1, 1),
            Part(1, 1, 1),
            Part(1, 1, 1),
            Part(1, 1, 1),
            Part(1, 1, 1),
            Part(1, 1, 1)
        ];
        part[0] = Part(1, 1, 1);
        Token memory token = Token(1, 1, 1, 1, part);
        return token;
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
