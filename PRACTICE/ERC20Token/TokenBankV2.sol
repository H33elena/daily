// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20Token.sol";

contract TokenBankV2 {
    mapping(address => mapping(address => uint256)) public balances; // token地址 => 用户地址 => 余额
    
    event Deposit(address token, address user, uint256 amount);
    
    function tokensReceived(address from, uint256 amount) external returns (bool) {
        address token = msg.sender; // 调用者就是token合约地址
        balances[token][from] += amount;
        emit Deposit(token, from, amount);
        return true;
    }
    
    // 查询用户在特定代币的存款余额
    function getBalance(address token, address user) external view returns (uint256) {
        return balances[token][user];
    }
} 