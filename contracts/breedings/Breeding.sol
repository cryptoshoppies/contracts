// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/common/IBreeding.sol";
import "contracts/common/GenesUtil.sol";

contract Breading is Ownable, IBreeding {
    // enum bodyPartIndex {
    //     Eyes  = 0,
    //     Mouth = 1,
    //     Ears  = 2,
    //     HandL = 3,
    //     Head  = 4,
    //     HandR = 5,
    //     LegL  = 6,
    //     Body  = 7,
    //     LegR  = 8
    // }

    using GenesUtil for uint256;

    uint8 private _breedingChargePrice = 0;
    uint256 private _globalSeed = 1;
    uint256 private _randomPercent = 5;
    uint256 private _minArcane = 1;
    uint256 private _maxArcane = 30;
    uint256 private _minId = 1;
    uint256 private _maxId = 36;

    function breading(uint256 momIn, uint256 dadIn)
        external
        returns (
            uint256 momOut,
            uint256 dadOut,
            uint256 genes
        )
    {
        if (_breedingChargePrice != 0) {
            require(
                GenesUtil.getCharges(momIn) >= _breedingChargePrice,
                "insufficient charge"
            );
            require(
                GenesUtil.getCharges(dadIn) >= _breedingChargePrice,
                "insufficient charge"
            );
        }

        uint256 randomSeed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.number,
                    block.prevrandao,
                    momIn,
                    dadIn,
                    _globalSeed
                )
            )
        );

        require(randomSeed != 0, "randomSeed can't be 0");

        _globalSeed++;

        uint32 generation = (GenesUtil.getGeneration(momIn) +
            GenesUtil.getGeneration(dadIn)) /
            2 +
            1;

        uint256 bodyPartsCount = 9;
        uint256 randomIndex = 0;

        genes = 0;

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
                1000
            );
            bool isArc = arcanePercent >=
                random(randomSeed, randomIndex++, 0, ((_maxArcane - _minArcane) * 1000) / _maxArcane);

            uint8 id = 1;
            if ((_randomPercent * 10) >= random(randomSeed, randomIndex++, 0, 1000)) {
                id = uint8(
                    random(randomSeed, randomIndex++, _minId, _maxId + 1) &
                        0xFF
                );
            } else {
                if (random(randomSeed, randomIndex++, 0, 1000) >= 500) {
                    id = GenesUtil.getId(dadIn, bodyPartIndex);
                } else {
                    id = GenesUtil.getId(momIn, bodyPartIndex);
                }
            }

            genes = GenesUtil.setId(genes, bodyPartIndex, id);
            genes = GenesUtil.setLevel(genes, bodyPartIndex, 1);
            genes = GenesUtil.setArcane(genes, bodyPartIndex, isArc ? 1 : 0);
        }

        if (_breedingChargePrice != 0) {
            // mom charges
            momOut = GenesUtil.setCharges(
                momIn,
                GenesUtil.getCharges(momIn) - _breedingChargePrice
            );

            // dad charges
            dadOut = GenesUtil.setCharges(
                dadIn,
                GenesUtil.getCharges(dadIn) - _breedingChargePrice
            );
        }

        // set generation
        genes = GenesUtil.setGeneration(genes, generation);

        // set charges
        genes = GenesUtil.setCharges(genes, 1);

        return (momOut, dadOut, genes);
    }

    // --------------------------------------------------------------------
    // GET / SET
    // --------------------------------------------------------------------

    function getGlobalSeed() public view returns (uint256) {
        return _globalSeed;
    }

    function setGlobalSeed(uint256 value) public onlyOwner {
        _globalSeed = value;
    }

    // --------------------------------------------------------------------

    function getMinArcane() public view returns (uint256) {
        return _minArcane;
    }

    function setMinArcane(uint256 value) public onlyOwner {
        _minArcane = value;
    }

    // --------------------------------------------------------------------

    function getMaxArcane() public view returns (uint256) {
        return _maxArcane;
    }

    function setMaxArcane(uint256 value) public onlyOwner {
        _maxArcane = value;
    }

    // --------------------------------------------------------------------

    function getRandomPercent() public view returns (uint256) {
        return _randomPercent;
    }

    function setRandomPercent(uint256 value) public onlyOwner {
        _randomPercent = value;
    }

    // --------------------------------------------------------------------

    function getMinId() public view returns (uint256) {
        return _minId;
    }

    function setMinId(uint256 value) public onlyOwner {
        _minId = value;
    }

    // --------------------------------------------------------------------

    function getMaxId() public view returns (uint256) {
        return _maxId;
    }

    function setMaxId(uint256 value) public onlyOwner {
        _maxId = value;
    }

    // --------------------------------------------------------------------

    function getBreedingChargePrice() public view returns (uint8) {
        return _breedingChargePrice;
    }

    function setBreedingChargePrice(uint8 price) public onlyOwner {
        _breedingChargePrice = price;
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
