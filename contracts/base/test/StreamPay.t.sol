// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../src/StreamPay.sol";

contract StreamPayTest is Test {
    StreamPay public c;
    
    function setUp() public {
        c = new StreamPay();
    }

    function testDeployment() public {
        assertTrue(address(c) != address(0));
    }
}
