// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenBank {
    // Token 合约地址
    IERC20 public token;
    
    // 记录用户存款余额
    mapping(address => uint256) public balances;
    
    // 在构造函数中设置 Token 地址
    constructor(address _token) {
        token = IERC20(_token);
    }
    
    // 存款方法
    function deposit(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        
        // 检查用户是否授权足够的代币
        require(token.allowance(msg.sender, address(this)) >= _amount, 
                "Insufficient allowance");
        
        // 转移代币到合约
        require(token.transferFrom(msg.sender, address(this), _amount),
                "Transfer failed");
        
        // 更新用户余额
        balances[msg.sender] += _amount;
    }
    
    // 取款方法
    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        // 更新用户余额
        balances[msg.sender] -= _amount;
        
        // 转移代币给用户
        require(token.transfer(msg.sender, _amount), "Transfer failed");
    }
    
    // 查询余额
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
} 