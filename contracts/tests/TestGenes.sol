// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "contracts/common/GenesUtil.sol";

contract TestGenes {
    using GenesUtil for uint256;

    uint256 public genes;

    function setGenes(uint256 value) public {
        genes = value;
    }

    function getGenes() public view returns (uint256) {
        return genes;
    }

    function setCharges(uint8 value) public {
        genes = GenesUtil.setCharges(genes, value);
    }

    function getCharges() public view returns (uint8) {
        return GenesUtil.getCharges(genes);
    }

    function setGeneration(uint32 value) public {
        genes = GenesUtil.setGeneration(genes, value);
    }

    function getGeneration() public view returns (uint32) {
        return GenesUtil.getGeneration(genes);
    }
}
