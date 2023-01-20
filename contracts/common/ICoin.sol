// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface ICoin {
    function mint(uint256 amount) external;

    function pay(uint256 amount) external;
}
