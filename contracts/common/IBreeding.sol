// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IBreeding {
    /// @dev given genes of token 1 & 2, return a genetic combination - may have a random factor
    /// @param genes1 genes of mom
    /// @param genes2 genes of dad
    /// @return the genes that are supposed to be passed down the child
    function breading(
        uint256 genes1,
        uint256 genes2,
        uint256 generation
    ) external returns (uint256);
}
