// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./ERC20Token.sol";

contract NFTMarket is ITokenReceiver {
    // NFT 上架信息结构
    struct Listing {
        address seller;
        uint256 price;
        bool isActive;
    }
    
    // NFT合约地址 => (tokenId => Listing)
    mapping(address => mapping(uint256 => Listing)) public listings;
    
    // ERC20代币合约地址
    ERC20WithCallback public paymentToken;
    
    // 临时存储，用于回调函数中识别买家
    address private currentBuyer;
    address private currentNFTContract;
    uint256 private currentTokenId;
    
    constructor(address _paymentToken) {
        paymentToken = ERC20WithCallback(_paymentToken);
    }
    
    // 上架NFT
    function list(address nftContract, uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be greater than 0");
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Not NFT owner");
        require(IERC721(nftContract).getApproved(tokenId) == address(this), "NFT not approved");
        
        listings[nftContract][tokenId] = Listing({
            seller: msg.sender,
            price: price,
            isActive: true
        });
    }
    
    // 常规购买NFT方法
    function buyNFT(address nftContract, uint256 tokenId) external {
        Listing memory listing = listings[nftContract][tokenId];
        require(listing.isActive, "NFT not listed");
        
        // 转移代币
        require(paymentToken.transferFrom(msg.sender, listing.seller, listing.price), 
                "Token transfer failed");
                
        // 转移NFT
        IERC721(nftContract).safeTransferFrom(listing.seller, msg.sender, tokenId);
        
        // 删除上架信息
        delete listings[nftContract][tokenId];
    }
    
    // 通过回调购买NFT
    function buyNFTWithCallback(address nftContract, uint256 tokenId) external {
        Listing memory listing = listings[nftContract][tokenId];
        require(listing.isActive, "NFT not listed");
        
        // 存储当前交易信息供回调使用
        currentBuyer = msg.sender;
        currentNFTContract = nftContract;
        currentTokenId = tokenId;
        
        // 使用支持回调的转账方法
        require(paymentToken.transferWithCallback(address(this), listing.price), 
                "Token transfer failed");
    }
    
    // 实现 ITokenReceiver 接口的回调函数
    function tokensReceived(address from, uint256 amount) external returns (bool) {
        require(msg.sender == address(paymentToken), "Invalid token");
        
        Listing memory listing = listings[currentNFTContract][currentTokenId];
        require(listing.isActive && amount >= listing.price, "Invalid purchase");
        
        // 将代币转给卖家
        require(paymentToken.transfer(listing.seller, amount), "Payment transfer failed");
        
        // 将NFT转给买家
        IERC721(currentNFTContract).safeTransferFrom(listing.seller, currentBuyer, currentTokenId);
        
        // 删除上架信息
        delete listings[currentNFTContract][currentTokenId];
        
        // 清除临时存储
        currentBuyer = address(0);
        currentNFTContract = address(0);
        currentTokenId = 0;
        
        return true;
    }
} 