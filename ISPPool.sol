// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface ISPPool {

    function addUser(address addr) external ;

    function deposit( uint256 _usdtAmt, uint256 _sptAmt) external returns(bool);

    function getDepositInfoUsdt(address account) external view returns(uint256 amtUsdt);

    function getDepositInfoTime(address account) external view returns(uint256 depositTime);


}
