// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBank.sol";

contract Admin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // 从 Bank 合约提取资金到 Admin 合约
    function adminWithdraw(IBank bank) external onlyOwner {
        uint256 bankBalance = bank.getContractBalance();
        if (bankBalance > 0) {
            bank.withdraw(bankBalance);
        }
    }

    // Admin 合约接收 ETH 的函数
    receive() external payable {}
} 