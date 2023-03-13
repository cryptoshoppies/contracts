// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICoin {
    /// mint coins
    function mint(uint256 amount) external;

    /// burn coins
    function pay(uint256 amount) external;
}
