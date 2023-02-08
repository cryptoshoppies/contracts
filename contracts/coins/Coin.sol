// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/common/ICoin.sol";

contract Coin is ERC20, Ownable, ICoin {
    address[] private _payers;

    // we have to check sender's ability to mint or burn coins
    modifier onlyPayer() {
        bool found = false;

        for (uint256 i = 0; i < _payers.length; i++)
            if (_payers[i] == msg.sender) {
                found = true;
                break;
            }

        require(found, "msg.sender is not the payer");
        _;
    }

    constructor() ERC20("ShoCoin", "SHOC") {
        // we have to add owner address to payer's list
        _payers.push(owner());
    }

    // mint coins
    function mint(uint256 amount) external onlyOwner {
        _mint(owner(), amount);
    }

    // burn coins
    function pay(uint256 amount) external onlyPayer {
        _burn(owner(), amount);
    }

    // it adds ability to mint or burn coins
    function addPayer(address payer) external onlyOwner {
        _payers.push(payer);
    }

    // it removes ability to mint or burn coins
    function removePayer(address payer) external onlyOwner {
        for (uint256 i = 0; i < _payers.length; i++) {
            if (payer == _payers[i]) delete _payers[i];
        }
    }

    // return list of payers who can mint or burn coins
    function getPayers() external view returns (address[] memory) {
        return _payers;
    }

    // return true - address exist / false - not exist
    function isPayerExist(address payer) external view returns (bool) {
        for (uint256 i = 0; i < _payers.length; i++) {
            if (payer == _payers[i]) return true;
        }
        return false;
    }
}
