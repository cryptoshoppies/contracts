// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "contracts/shoToken/ShoToken.sol";

/// @custom:security-contact supportcs@ntiloyalty.com
contract ShoTokenStaging is ShoToken {
    function _baseURI() internal pure override returns (string memory) {
        return "https://nft.cryptoshopee.com/staging/";
    }
}
