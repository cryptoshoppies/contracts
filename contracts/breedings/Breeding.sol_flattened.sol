
// File: contracts/common/GenesUtil.sol



pragma solidity ^0.8.17;

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

// File: contracts/common/IBreeding.sol



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

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/breedings/Breeding.sol



pragma solidity ^0.8.17;




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
        momOut = momIn;
        dadOut = dadIn;

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

            require(id >= _minId && id <= _maxId, "error, breading, part id must be in range");

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
