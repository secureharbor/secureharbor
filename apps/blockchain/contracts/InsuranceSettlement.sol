// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract InsuranceSettlement {
    address public owner;

    constructor() {
        // Set the contract deployer as the owner
        owner = msg.sender;
    }

    // Modifier to restrict function execution to the contract's owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    // Function to receive Ether. The `payable` modifier allows the function to accept Ether.
    receive() external payable {}

    // Function to withdraw Ether and send it to a specified address for claim settlement
    function settleClaim(address payable _to, uint _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance in contract.");
        _to.transfer(_amount);
    }

    // Function to check the contract's balance
    function checkBalance() external view returns (uint) {
        return address(this).balance;
    }
}
