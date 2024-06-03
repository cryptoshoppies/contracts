// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/common/ICoin.sol";

contract ShoCoin is ERC20, ERC20Burnable, Pausable, Ownable, ICoin {
    constructor() ERC20("TestShoCoin", "SHOC") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /// mint coins
    function mint(uint256 amount) override external onlyOwner {
        _mint(owner(), amount);
    }

    /// burn coins
    function pay(uint256 amount) override external onlyOwner {
        _burn(owner(), amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
}
