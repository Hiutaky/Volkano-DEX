pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LAVADex {
    event DepositSuccess(uint256 amount);
    event WithdrawSuccess(uint256 amount);

    ERC20 USDT;

    // Token to send for USDT
    ERC20 VLC;
    
    address USDTRewardAddr = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2; //pass in constructor
    uint256 totalReward; //total reward balance in USDT
    uint256 poolFee = 5; //pool tx fee in %
    uint8 decimals = 18; //usdt decimals
    address thisAddress = address(this);
    
    mapping (address => uint256) public balances;

    //usdtAddress - USDT Contract Token Address
    constructor(address usdtAddress, address vlcAddress) {
        USDT = ERC20(usdtAddress);
        VLC = ERC20(vlcAddress);
    }

    //swap vUSDT and recieve VLC in ratio 1:1 + FEES
    function SwapUSDTforVLC(uint256 amount) public {
        uint256 userUSDTbalance = USDT.balanceOf(msg.sender);
        uint256 userVLCbalance = VLC.balanceOf(msg.sender);
        uint256 poolUSDTbalance = USDT.balanceOf(thisAddress);
        
        require( amount <= VLC.balanceOf(thisAddress), "Not enough Token in the Pool Balance");
        require( userUSDTbalance >= amount, "Deposited Amount must be less than total balance" );
        require( USDT.allowance(msg.sender, address(this) ) >= amount );
        
        USDT.transferFrom(msg.sender, address(this), amount);
        
        assert( USDT.balanceOf( address(this) ) > poolUSDTbalance );
        // Send amount tokens to msg.sender
        VLC.transfer(msg.sender, amount);
        
        assert( VLC.balanceOf(msg.sender) >= userVLCbalance );

        emit DepositSuccess(amount);
    }

    function SwapVLCforUSDT(uint256 amount) public {
        uint256 userVLCbalance = VLC.balanceOf(msg.sender);
        uint256 poolUSDTbalance = USDT.balanceOf(address(this));
        
        // Recieve VLC amount from msg.sender
        require(userVLCbalance >= amount);
        require(poolUSDTbalance >= amount);
        
        VLC.transferFrom(msg.sender, address(this), amount);
        uint256 newUserVLCbalance = VLC.balanceOf(msg.sender);
        assert( newUserVLCbalance < userVLCbalance );
        
        //send USDT amount to msg.sender
        USDT.transfer(msg.sender, amount);


        emit WithdrawSuccess(amount);
    }
    
    function PoolTotalUSDT() public view returns (uint256){
        return USDT.balanceOf(address(this));
    }
    
    function PoolTotalVLC() public view returns (uint256){
        return VLC.balanceOf(address(this));
    }

    
    function balanceUSDT() public view returns (uint256){
        return USDT.balanceOf(msg.sender);
    }
    
    function balanceVLC() public view returns (uint256){
        return VLC.balanceOf(msg.sender);
    }
    
    function poolTotalReward() public view returns (uint256) {
        return totalReward;
    }
}
