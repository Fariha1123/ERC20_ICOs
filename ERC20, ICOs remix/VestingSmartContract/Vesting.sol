pragma solidity ^0.4.23;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
}

contract Vesting {
    using SafeMath for uint;
    address beneficiary;
    uint vestingPeriod;
    uint percentage;
    uint256 internal withDrawAmount;
    uint256 internal releasedAmount;
    uint256 internal initialTokens;
    uint256 internal nextRelease;
    ERC20Interface e;
    
    mapping(address => uint) balances;
    
    constructor(address _beneficiary, uint _vestingPeriod, uint _percentage, uint _tokenAddress) public{
        e = ERC20Interface(_tokenAddress);
        beneficiary = _beneficiary;
        vestingPeriod = _vestingPeriod;
        percentage = _percentage;
        withDrawAmount = 0;
        initialTokens = 0;
        nextRelease = now + (vestingPeriod.mul(31).mul(24).mul(60).mul(60));
        
    }
    
    function checkVested() public view returns(uint totalVested){
        return withDrawAmount;
    }
    
    function checkReleased() public view returns(uint totalReleased){
        
        if(initialTokens == 0 && e.balanceOf(this) > 0){
            initialTokens = e.balanceOf(this);
            releasedAmount += (initialTokens.mul(percentage.mul(100))).div(10000);
            
        }
        
        if(now > nextRelease && releasedAmount!=initialTokens){
            releasedAmount += (initialTokens.mul(percentage.mul(100))).div(10000);
            nextRelease = now + (vestingPeriod.mul(31).mul(24).mul(60).mul(60));
        }
        
        return releasedAmount;
    }
    
    function withDraw() public {
        checkReleased(); //to update the releasedAmount
        require(releasedAmount > withDrawAmount);
        uint256 amount = releasedAmount.sub(withDrawAmount);
        withDrawAmount = withDrawAmount.add(amount);
        require(e.transfer(beneficiary, amount));
    }
    
    function nextReleaseC() public view returns(uint256 releasedate){
        return nextRelease;
    }
    
}