//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Box} from "../src/Box.sol";
import {GovToken} from "../src/GovToken.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {TimeLock} from "../src/TimeLock.sol";

contract MyGovernerTest is Test {
    Box box;
    GovToken token;
    MyGovernor governor;
    TimeLock lock;

    address user = makeAddr("user");
    uint256 constant INITIAL_SUPPLY = 100 ether;

    uint256 constant VOTING_DELAY = 1;
    uint256 constant VOTING_PERIOD = 50400;

    address[] proposers;
    address[] executors;
    bytes[] calldatas;
    uint256[] values;
    address[] targets;

    function setUp() external {
        token = new GovToken();
        token.mint(user, INITIAL_SUPPLY);

        vm.startPrank(user);
        token.delegate(user);

        lock = new TimeLock(3600 /*1 day */, proposers, executors);
        governor = new MyGovernor(token, lock);

        bytes32 proposerRole = lock.PROPOSER_ROLE();
        bytes32 executorRole = lock.EXECUTOR_ROLE();
        bytes32 adminRole = lock.DEFAULT_ADMIN_ROLE();

        lock.grantRole(proposerRole, address(governor));
        lock.grantRole(executorRole, address(governor));
        lock.grantRole(adminRole, address(governor));
        vm.stopPrank();

        box = new Box();
        box.transferOwnership(address(lock)); 
    }

    function testCantUpdateBoxWithoutGovernance() external {
        vm.expectRevert();
        box.store(42);
    }

    function testGovernaceUpdatesBox() external {
        uint256 valueTostore = 79;
        string memory descritpion = "store 1 in box";
        bytes memory encodeFunctionCall = abi.encodeWithSignature(
            "store(uint256)",
            valueTostore
        );
        values.push(0);
        calldatas.push(encodeFunctionCall);
        targets.push(address(box));
        uint256 proposalId = governor.propose(
            targets,
            values,
            calldatas,
            descritpion
        );
        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        string memory reason = "My choice, my will!!";
        uint8 voteWay = 1;
        vm.prank(user);
        governor.castVoteWithReason(proposalId, voteWay, reason);
        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);
        bytes32 descriptionHash = keccak256(abi.encodePacked(descritpion));
        governor.queue(targets, values, calldatas, descriptionHash);
        vm.warp(block.timestamp + 3600 + 1);
        vm.roll(block.number + 3600 + 1);
        governor.execute(targets, values, calldatas, descriptionHash);
        assert(box.getNumber() == valueTostore);
    }
}
