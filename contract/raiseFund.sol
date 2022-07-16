// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract fundraising{
    event Launch(address indexed creator, uint goal, uint32 startAt, uint32 endAt);
    event Pledge(address indexed caller, uint amount);
    event Claim(uint amount);
    event Refund(address indexed caller, uint amount);


    uint public goal;
    uint32 public startAt;
    uint32 public endAt;
    uint public pledged;
    bool public claimed;

    address payable public owner;

    IERC20 public immutable token;
    mapping(address => uint) public amountPledged;

    constructor(address _token) {
        token = IERC20(_token);
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "not owner");
        _;
    }


    function launch(uint _goal, uint32 _startAt, uint32 _endAt) public{
        require(_startAt >= block.timestamp, "Not yet time");
        require(_endAt >= _startAt, "Still in process");
        require(_endAt >= block.timestamp +30);

        emit Launch(msg.sender, _goal, _startAt, _endAt);
    }

    function pledge(address caller, uint256 _amount) public {
        require(startAt >= block.timestamp, "Not yet time");
        require(block.timestamp <= endAt, "Ended");

        amountPledged[msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(msg.sender, _amount);


    }

    function claim(uint _amount) public onlyOwner{
        require(block.timestamp > endAt, "not ended");
        require(pledged >= goal, "pledged < goal");
        require(!claimed, "claimed");

        claimed == true;
        token.transfer(msg.sender, pledged);

        emit Claim(_amount);


    }

    function refund(uint _amount) public{
        require(block.timestamp > endAt, "not ended");
        require(pledged < goal, "Goal not reached");

        uint bal = amountPledged[msg.sender];
        amountPledged[msg.sender] = 0;
        token.transfer(msg.sender, _amount);



    emit Refund(msg.sender, _amount);
    }


}