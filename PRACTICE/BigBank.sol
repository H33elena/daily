// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Bank.sol";

contract BigBank is Bank {
    // 最小存款金额检查
    modifier minDepositRequired() {
        require(msg.value > 0.001 ether, "Deposit must be greater than 0.001 ether");
        _;
    }

    // 重写 deposit 函数，添加最小存款限制
    function deposit() public payable override minDepositRequired {
        super.deposit();
    }

    // 转移管理员权限
    function transferAdmin(address newAdmin) external {
        require(msg.sender == admin, "Only current admin can transfer admin rights");
        require(newAdmin != address(0), "New admin cannot be zero address");
        admin = newAdmin;
    }
} 