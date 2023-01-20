// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/common/ICoin.sol";

contract Coint is ERC20, Ownable, ICoin {
    bool private saveCoin;

    address[] private _payers;

    modifier onlyPayer() {
        address _payer = address(0);

        bool flag = false;

        for (uint256 i = 0; i < _payers.length; i++)
            if (_payers[i] == msg.sender) {
                flag = true;
            }

        require(
            flag,
            "onlyTokenContract"
            "Ownable: caller is not the payer"
        );
        _;
    }

    constructor() ERC20("ShoCoin", "SC") {}

    function mint(uint256 amount) external onlyOwner {
        _mint(owner(), amount);
    }

    function pay(uint256 amount) external onlyPayer {
        _burn(owner(), amount);
    }

    function addPayer(address payer) external onlyOwner {
        _payers.push(payer);
    }

    function removePayer(address payer) external onlyOwner {
        for (uint256 i = 0; i < _payers.length; i++)
            if (payer == _payers[i]) delete _payers[i];
    }

    function getPayers() external view returns (address[] memory) {
        return _payers;
    }
}
