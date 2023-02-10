// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/common/IBreeding.sol";
import "contracts/common/GenesUtil.sol";

contract Breading is Ownable, IBreeding {
    // enum BodyPartId {
    //     Eyes,
    //     Mouth,
    //     Ears,
    //     HandL,
    //     Head,
    //     HandR,
    //     LegL,
    //     Body,
    //     LegR
    // }

    using GenesUtil for uint256;

    uint256 private _globalSeed = 1;
    uint256 private _randomPercent = 5;
    uint256 private _minArcane = 1;
    uint256 private _maxArcane = 30;
    uint256 private _minId = 1;
    uint256 private _maxId = 36;

    function breading(uint256 genes1, uint256 genes2)
        external
        returns (uint256)
    {
        uint256 randomSeed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.number,
                    block.prevrandao,
                    genes1,
                    genes2,
                    _globalSeed
                )
            )
        );

        require(randomSeed != 0, "randomSeed can't be 0");

        _globalSeed++;

        uint32 generation = (GenesUtil.getGeneration(genes1) +
            GenesUtil.getGeneration(genes2)) /
            2 +
            1;

        uint8 bodyPartsCount = 9;
        uint256 randomIndex = 0;

        uint256 genes = 0;

        // body parts
        for (
            uint8 bodyPartIndex = 0;
            bodyPartIndex < bodyPartsCount;
            bodyPartIndex++
        ) {
            uint256 arcanePercent = getArcanePercent(
                generation,
                _minArcane,
                _maxArcane,
                100
            );
            bool isArc = arcanePercent >=
                random(_globalSeed, randomIndex++, 0, _maxArcane * 100);

            uint8 id = 1;
            if (_randomPercent >= random(_globalSeed, randomIndex++, 0, 100)) {
                id = uint8(
                    random(_globalSeed, randomIndex++, _minId, _maxId + 1) & 0xFF
                );
            } else {
                if (random(_globalSeed, randomIndex++, 0, 100) >= 50) {
                    id = GenesUtil.getId(genes2, bodyPartIndex);
                } else {
                    id = GenesUtil.getId(genes1, bodyPartIndex);
                }
            }

            genes = GenesUtil.setId(genes, bodyPartIndex, id);
            genes = GenesUtil.setLevel(genes, bodyPartIndex, 1);
            genes = GenesUtil.setArcane(genes, bodyPartIndex, isArc ? 1 : 0);
        }

        // set generation
        genes = GenesUtil.setGeneration(genes, generation);

        // set charges
        genes = GenesUtil.setCharges(genes, 1);

        return genes;
    }

    // --------------------------------------------------------------------
    // GET / SET
    // --------------------------------------------------------------------

    function getGlobalSeed() external view returns (uint256) {
        return _globalSeed;
    }

    function setGlobalSeed(uint256 value) public onlyOwner {
        _globalSeed = value;
    }

    // --------------------------------------------------------------------

    function getMinArcane() external view returns (uint256) {
        return _minArcane;
    }

    function setMinArcane(uint256 value) public onlyOwner {
        _minArcane = value;
    }

    // --------------------------------------------------------------------

    function getMaxArcane() external view returns (uint256) {
        return _maxArcane;
    }

    function setMaxArcane(uint256 value) public onlyOwner {
        _maxArcane = value;
    }

    // --------------------------------------------------------------------

    function getRandomPercent() external view returns (uint256) {
        return _randomPercent;
    }

    function setRandomPercent(uint256 value) public onlyOwner {
        _randomPercent = value;
    }

    // --------------------------------------------------------------------

    function getMinId() external view returns (uint256) {
        return _minId;
    }

    function setMinId(uint256 value) public onlyOwner {
        _minId = value;
    }

    // --------------------------------------------------------------------

    function getMaxId() external view returns (uint256) {
        return _maxId;
    }

    function setMaxId(uint256 value) public onlyOwner {
        _maxId = value;
    }

    // --------------------------------------------------------------------
    // RANDOM
    // --------------------------------------------------------------------

    function random(
        uint256 seed,
        uint256 index,
        uint256 minNumber,
        uint256 maxNumber
    ) internal pure returns (uint256 value) {
        value =
            uint256(keccak256(abi.encodePacked(seed, index))) %
            (maxNumber - minNumber);
        value = minNumber + value;
        return value;
    }

    // --------------------------------------------------------------------
    // ARCANE
    // --------------------------------------------------------------------

    function getArcanePercent(
        uint256 generation,
        uint256 min,
        uint256 max,
        uint256 mult
    ) internal pure returns (uint256) {
        if (generation <= min) {
            return 0;
        }
        return ((generation - min) * mult) / max;
    }
}
