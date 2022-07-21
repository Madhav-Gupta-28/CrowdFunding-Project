//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract CrowdFunding{

    mapping(address=>uint) public contributors;

    address public manager;
    uint public minimumAmount;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributers;

    struct Request{
        string description;
        address payable reciptent;
        uint ValueNeeded;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;

    }

    mapping(uint => Request) public request;

    uint public numRequest;



    constructor(uint _target, uint _deadline){
    target = _target;
    deadline = block.timestamp + _deadline;
    minimumAmount = 1 ether;
    manager = msg.sender;
    }

    modifier TimeStampLessThanDeadline() {
        require(block.timestamp < deadline, "Hey DeadLine is Passed, Now You cannot contribute");
        _;
    }

    modifier MinContribution(){
        require(msg.value >= 1 ether, "Minimum cobtribution is not met, pay atleast 1 Eth");
        _;
    }


    
    function sendAmount() public payable TimeStampLessThanDeadline MinContribution{

        require(raisedAmount >  target, "No need to pay, Target is Acheived");

        if(contributors[msg.sender] == 0){

            noOfContributers++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount+= msg.value;
    }

    function getContractBalance() public view returns(uint){
         return address(this).balance;
    }


    function refund() public {

        require(block.timestamp > deadline && raisedAmount < target,"You not eligible for refund");
        require(contributors[msg.sender] > 0 );

        address payable user = payable(msg.sender) ;

        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0 ;

    }


    modifier onlyManager(){
        require(msg.sender == manager, "You can't call it, noly manager can");
        _;
    }

    function createRequest(string memory _description, address payable _recipetent, uint _value) public onlyManager {

        Request storage newRequest = request[numRequest]; 

        numRequest++;

        newRequest.description = _description;
        newRequest.reciptent = _recipetent;
        newRequest.ValueNeeded = _value;
        newRequest.completed = false ;
        newRequest.noOfVoters = 0;

    }


    function voteRequest(uint _requestNo) public{

        require(contributors[msg.sender]>0,"YOu must be contributor");
        Request storage thisRequest= request[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;

    }

    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount >= target);
        Request storage thisRequest=request[_requestNo];
        require(thisRequest.completed==false,"The request has been completed");
        require(thisRequest.noOfVoters > noOfContributers/2,"Majority does not support");
        thisRequest.reciptent.transfer(thisRequest.ValueNeeded);
        thisRequest.completed=true;
    }



}





