// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title StreamPay Contract
/// @notice Continuous payment streaming protocol.
contract StreamPay {

    struct Stream {
        address sender;
        address recipient;
        uint256 deposit;
        uint256 rate;
        uint256 startTime;
        uint256 withdrawn;
    }
    
    mapping(uint256 => Stream) public streams;
    uint256 public nextStreamId;
    
    function createStream(address _recipient, uint256 _rate) external payable returns (uint256) {
        uint256 id = nextStreamId++;
        streams[id] = Stream({
            sender: msg.sender,
            recipient: _recipient,
            deposit: msg.value,
            rate: _rate,
            startTime: block.timestamp,
            withdrawn: 0
        });
        return id;
    }
    
    function withdraw(uint256 _id) external {
        Stream storage s = streams[_id];
        require(msg.sender == s.recipient, "Not recipient");
        
        uint256 duration = block.timestamp - s.startTime;
        uint256 balance = (duration * s.rate) - s.withdrawn;
        require(balance > 0, "No funds");
        require(balance <= s.deposit, "Overdrawn");
        
        s.withdrawn += balance;
        payable(s.recipient).transfer(balance);
    }

}
