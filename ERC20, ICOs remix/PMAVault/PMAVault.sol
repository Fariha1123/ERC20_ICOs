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
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
}

contract PMAVault is Owned {
    using SafeMath for uint;
    uint interval;
    uint percentage;
    uint256 internal withDrawAmount;
    uint256 internal initialTokens;
    uint startInterval;
    uint endInterval;
    ERC20Interface e;
    
    mapping(address => uint) balances;
    /**
    _owner = specify the owner who can withdraw tokens
    _interval = specify the intervals in days
    _percentage = specify percentage of tokens allowed in each withdrawl window, use numbers not decimals, without % sign
    _tokenAddress = contract address of the token, working with e.g; PMA token
    */
    constructor(address _owner, uint _interval, uint _percentage, uint _tokenAddress) public{
        require(_owner != 0x0 && _tokenAddress != 0x0 && _interval != 0 && _percentage != 0);
        
        e = ERC20Interface(_tokenAddress);
        owner = _owner;
        interval = _interval;
        percentage = _percentage;
        withDrawAmount = 0;
        initialTokens = 0;
        startInterval = now.add(interval.mul(24).mul(60).mul(60));
        endInterval = startInterval.add(48*60*60);
    }
    
    function _updateState() internal {
        if(initialTokens == 0 && e.balanceOf(this) > 0){
        initialTokens = e.balanceOf(this);
        }
        if(e.balanceOf(this) > 0){
            withDrawAmount += (initialTokens.mul(percentage.mul(100))).div(10000);
        }
    }
    
    function withDraw() public onlyOwner{
        if(now > endInterval){
            _updateState();
            _updateIntervals();
        }
        if(now > startInterval && now < endInterval){
            _updateState(); //to update the state of the contract
            require(e.transfer(owner, withDrawAmount));
            withDrawAmount = 0;
            _updateIntervals();
        }
    }
    
    function _updateIntervals() internal{
        startInterval = endInterval.add(interval.mul(24).mul(60).mul(60));
        endInterval = startInterval.add(48*60*60);
    }
    
}