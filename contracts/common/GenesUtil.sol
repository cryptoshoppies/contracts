// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// body properties
library GenesUtil {
    function getGeneration(uint256 genes) public pure returns (uint32) {
        unchecked {
            return (uint32)(genes & 0xFFFFFFFF);
        }
    }

    function getCharges(uint256 genes) public pure returns (uint8) {
        unchecked {
            return (uint8)((genes >> (31 * 8)) & 0xFF);
        }
    }

    function setGeneration(uint256 genes, uint32 generation)
        public
        pure
        returns (uint256)
    {
        return ((genes >> 4) << 4) | generation;
    }

    function setCharges(uint256 genes, uint8 charges)
        public
        pure
        returns (uint256)
    {
        return ((genes << 8) >> 8) | (uint256(charges) << (31 * 8));
    }

    function getId(uint256 genes, uint8 partId) public pure returns (uint8) {
        uint256 startIndex = 4;
        uint256 index = partId * 3;
        return (uint8)((genes >> ((startIndex + index + 0) * 8)) & 0xFF);
    }

    function setId(
        uint256 genes,
        uint256 partId,
        uint8 id
    ) public pure returns (uint256) {
        uint256 startIndex = 4;
        uint256 index = partId * 3;
        uint256 shift = (startIndex + index + 0) * 8;
        // clear bytes, n & ~(1 << k)
        genes = genes & ~(0xFF << shift);
        return genes | (uint256(id) << shift);
    }

    function getLevel(uint256 genes, uint8 partId) public pure returns (uint8) {
        uint256 startIndex = 4;
        uint256 index = partId * 3;
        return (uint8)((genes >> ((startIndex + index + 1) * 8)) & 0xFF);
    }

    function setLevel(
        uint256 genes,
        uint256 partId,
        uint8 level
    ) public pure returns (uint256) {
        uint256 startIndex = 4;
        uint256 index = partId * 3;
        uint256 shift = (startIndex + index + 1) * 8;
        // clear bytes, n & ~(1 << k)
        genes = genes & ~(0xFF << shift);
        return genes | (uint256(level) << shift);
    }

    function getArcane(uint256 genes, uint8 partId)
        public
        pure
        returns (uint8)
    {
        uint256 startIndex = 4;
        uint256 index = partId * 3;
        return (uint8)((genes >> ((startIndex + index + 2) * 8)) & 0xFF);
    }

    function setArcane(
        uint256 genes,
        uint256 partId,
        uint8 arcane
    ) public pure returns (uint256) {
        uint256 startIndex = 4;
        uint256 index = partId * 3;
        uint256 shift = (startIndex + index + 2) * 8;
        // clear bytes, n & ~(1 << k)
        genes = genes & ~(0xFF << shift);
        return genes | (uint256(arcane) << shift);
    }
}
