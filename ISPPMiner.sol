// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface ISPPMiner {

    function addInvitee(address _userAddr) external;

    function subInvitee(address _userAddr) external;
  
    function referReward(address _userAddr, uint256 _hashToken) external;

    function getMyChilders(address _userAddr) external returns (address[] memory);


    

}