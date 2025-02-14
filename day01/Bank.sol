// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address public admin;
    mapping(address => uint256) public balances;
    address[3] public topDepositors;
    uint256[3] public topAmounts;

    constructor() {
        admin = msg.sender;
    }

    // 接收存款的 fallback 函数
    receive() external payable {
        deposit();
    }

    // 存款函数
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        
        balances[msg.sender] += msg.value;
        updateTopDepositors(msg.sender, balances[msg.sender]);
    }

    // 更新前三名存款用户
    function updateTopDepositors(address depositor, uint256 amount) private {
        for (uint i = 0; i < 3; i++) {
            if (amount > topAmounts[i]) {
                // 将现有元素后移
                for (uint j = 2; j > i; j--) {
                    topAmounts[j] = topAmounts[j-1];
                    topDepositors[j] = topDepositors[j-1];
                }
                // 插入新元素
                topAmounts[i] = amount;
                topDepositors[i] = depositor;
                break;
            }
        }
    }

    // 仅管理员可提取资金
    function withdraw(uint256 amount) external {
        require(msg.sender == admin, "Only admin can withdraw");
        require(amount <= address(this).balance, "Insufficient balance");
        
        payable(admin).transfer(amount);
    }

    // 查询合约余额
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // 查询前三名存款用户
    function getTopDepositors() public view returns (address[3] memory, uint256[3] memory) {
        return (topDepositors, topAmounts);
    }
}
