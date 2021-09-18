// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
contract OwnableData {
    address public owner;
}


contract Ownable is OwnableData {
 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () public {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

 
    function renounceOwnership() public onlyOwner { 
        emit OwnershipTransferred(owner, address(0)); 
        owner = address(0);
    }

   
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

  
}