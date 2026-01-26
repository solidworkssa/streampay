// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StreamPay {
    struct Stream {
        address sender;
        address receiver;
        uint256 amount;
        uint256 startTime;
        uint256 duration;
        uint256 withdrawn;
        bool active;
    }

    mapping(uint256 => Stream) public streams;
    uint256 public streamCounter;

    event StreamCreated(uint256 indexed streamId, address indexed sender, address indexed receiver);
    event Withdrawn(uint256 indexed streamId, uint256 amount);
    event StreamCancelled(uint256 indexed streamId);

    error Unauthorized();
    error InvalidStream();

    function createStream(address receiver, uint256 duration) external payable returns (uint256) {
        uint256 streamId = streamCounter++;
        streams[streamId] = Stream(msg.sender, receiver, msg.value, block.timestamp, duration, 0, true);
        emit StreamCreated(streamId, msg.sender, receiver);
        return streamId;
    }

    function withdraw(uint256 streamId) external {
        Stream storage stream = streams[streamId];
        if (msg.sender != stream.receiver) revert Unauthorized();
        
        uint256 available = availableToWithdraw(streamId);
        stream.withdrawn += available;
        payable(stream.receiver).transfer(available);
        emit Withdrawn(streamId, available);
    }

    function cancelStream(uint256 streamId) external {
        Stream storage stream = streams[streamId];
        if (msg.sender != stream.sender) revert Unauthorized();
        
        stream.active = false;
        uint256 remaining = stream.amount - stream.withdrawn;
        if (remaining > 0) {
            payable(stream.sender).transfer(remaining);
        }
        emit StreamCancelled(streamId);
    }

    function availableToWithdraw(uint256 streamId) public view returns (uint256) {
        Stream memory stream = streams[streamId];
        uint256 elapsed = block.timestamp - stream.startTime;
        if (elapsed >= stream.duration) return stream.amount - stream.withdrawn;
        return (stream.amount * elapsed / stream.duration) - stream.withdrawn;
    }

    function getStream(uint256 streamId) external view returns (Stream memory) {
        return streams[streamId];
    }
}
