// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IBreeding {
    /// @dev given genes of token 1 & 2, return a genetic combination - may have a random factor
    /// @param momIn genes of mom
    /// @param dadIn genes of dad
    /// @return momOut modify mom genes
    /// @return dadOut modify dad genes
    /// @return child the genes that are supposed to be passed down the child
    function breading(uint256 momIn, uint256 dadIn)
        external
        returns (
            uint256 momOut,
            uint256 dadOut,
            uint256 child
        );
}
