// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @custom:security-contact support@ntiloyalty.com
abstract contract ShoToken is ERC721, Ownable {
    // --------------------------------------------------------------------
    // USING
    // --------------------------------------------------------------------

    using Counters for Counters.Counter;

    // --------------------------------------------------------------------
    // EVENTS
    // --------------------------------------------------------------------

    event Mint(uint256 tokenId);

    // --------------------------------------------------------------------
    // FIELDS
    // --------------------------------------------------------------------

    Counters.Counter private _tokenIdCounter;

    // --------------------------------------------------------------------
    // CONSTRUCTOR
    // --------------------------------------------------------------------

    constructor() ERC721("ShoToken", "SHOTKN") Ownable(_msgSender()) {}

    // --------------------------------------------------------------------
    // OVERRIDES
    // --------------------------------------------------------------------

    function _baseURI() internal pure virtual override returns (string memory) {
        return "https://nft.cryptoshopee.com/";
    }

    // --------------------------------------------------------------------
    // SERVER METHODS
    // --------------------------------------------------------------------

    /// server method - mint nft
    function mint() external onlyOwner returns (uint256) {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        _safeMint(owner(), tokenId);

        emit Mint(tokenId);

        return tokenId;
    }

    // --------------------------------------------------------------------

    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter.current();
    }

    // --------------------------------------------------------------------
    // --------------------------------------------------------------------

    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success);
    }
}
