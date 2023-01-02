// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface ICoin {
    /**
     * Mint, makes new coins
     */
    function mint(uint256 amount) external returns (bool);

    /**
     * Pay, use coins
     */
    function pay(uint256 amount) external returns (bool);
}
