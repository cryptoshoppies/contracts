// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @custom:security-contact supportcs@ntiloyalty.com
contract ShoToken is ERC721, Pausable, Ownable, ERC721Burnable {
    // --------------------------------------------------------------------
    // USING
    // --------------------------------------------------------------------

    using Strings for uint256;
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

    constructor() ERC721("ShoToken", "SHOTKN") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://nft.cryptoshopee.ntiloyalty.com";
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
