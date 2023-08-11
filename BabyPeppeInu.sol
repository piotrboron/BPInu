// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.9.3/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.3/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@4.9.3/access/Ownable.sol";

contract BabyPeppeInu is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("BabyPeppeInu", "BPINU") {
        _mint(msg.sender, 10000000 * 10 ** decimals());

        //wykluczanie założyciela i kontraktu samego w sobie
        isExcludedFromFee[_msgSender()] = true;
        isExcludedFromFee[address(this)] = true;
    }

 //mapowanie wykluczonych
        mapping(address => bool) isExcludedFromFee;

 //adres dev
        address public devAddress = 0x7Df3BBF2F64A39c6DFC0c6B3676EFBF61742bEe4;

// zmienne do fee
        uint256 public burnFeePercentage = 5;
        uint256 public devFeePercentage = 1;
//exclude i include
    function ExcludedFromFee(address account, bool) public onlyOwner {
        isExcludedFromFee[account] = true;
    }
    function IncludeInFees(address account, bool) public onlyOwner {
        isExcludedFromFee[account] = false;
    }

//nadpisanie funkcji transfer

function _transfer(
    address sender,
    address recipient,
    uint256 amount
) internal override {

//wartosci tak/nie dla wykluczenia adresu z fee
    bool senderExcluded = isExcludedFromFee[sender];
    bool recipientExcluded = isExcludedFromFee[recipient];

//zadeklarowanie zmiennych do burn fee i dev fee
    uint256 burnAmount = 0;
    uint256 devFeeAmount = 0;
    uint256 transferAmount = amount;

    if (!senderExcluded && !recipientExcluded) {
        burnAmount = (amount * burnFeePercentage) / 100;
        devFeeAmount = (amount * devFeePercentage) / 100;
        transferAmount = amount - burnAmount - devFeeAmount;
    }

    super._transfer(sender, recipient, transferAmount);

        if (!senderExcluded && !recipientExcluded) {

            if (burnAmount > 0) {
                _burn(sender, burnAmount);
            }

            if (devFeeAmount > 0) {
                super._transfer(sender, devAddress, devFeeAmount);
            }
        }
    }
}
