// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// body properties
library GenesUtil {
    function getGeneration(uint256 genes) internal pure returns (uint32) {
        unchecked {
            return (uint32)(genes & 0xFFFFFFFF);
        }
    }

    function getCharges(uint256 genes) internal pure returns (uint8) {
        unchecked {
            return (uint8)((genes >> (31 * 8)) & 0xFF);
        }
    }

    function setGeneration(uint256 genes, uint32 generation)
        internal
        pure
        returns (uint256)
    {
        return ((genes >> 4) << 4) | generation;
    }

    function setCharges(uint256 genes, uint8 charges)
        internal
        pure
        returns (uint256)
    {
        return ((genes << 8) >> 8) | (uint256(charges) << (31 * 8));
    }
}
