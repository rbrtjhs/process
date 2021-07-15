// SPDX-License-Identifier: GNU GPL v3

pragma solidity ^0.8.0;

import "./Step.sol";
import "./Item.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Process is Ownable {
    enum ProcessStatus {
        MODIFIABLE,
        IN_PROGRESS,
        FINISHED
    }

    modifier inStatus(ProcessStatus _status) {
        require(status == _status, "Process is in not in desired status.");
        _;
    }

    modifier onlyStepOwner() {
        require(steps[stepIndex].owner() == msg.sender, "Only step owner can change.");
        _;
    }

    Item public item;
    Step[] public steps;
    ProcessStatus public status;
    uint256 public stepIndex;
    string public name;

    constructor(string memory _name) {
        status = ProcessStatus.MODIFIABLE;
        stepIndex = 0;
        name = _name;
    }

    function setItem(Item _item) external inStatus(ProcessStatus.MODIFIABLE) {
        item = _item;
    }

    function addStep(Step _step) external inStatus(ProcessStatus.MODIFIABLE) {
        steps.push(_step);
    }

    function removeSteps(uint256[] memory _indexes) external inStatus(ProcessStatus.MODIFIABLE) {
        for (uint256 i = 0; i < _indexes.length; i++) {
            removeStep(_indexes[i]);
        }
    }

    function removeStep(uint index) public inStatus(ProcessStatus.MODIFIABLE) {
        if (index >= steps.length) return;

        for (uint i = index; i < steps.length-1; i++){
            steps[i] = steps[i+1];
        }
        delete steps[steps.length-1];
    }

    function finishCreation() external inStatus(ProcessStatus.MODIFIABLE) {
        require(steps.length > 0, "Process needs at least 1 step.");
        require(address(item) != address(0), "Process needs item.");
        for (uint i = 0; i < steps.length; i++) {
            steps[i].setItem(item);
        }
        status = ProcessStatus.IN_PROGRESS;
    }

    function nextStep() external onlyStepOwner() inStatus(ProcessStatus.IN_PROGRESS) {
        if (stepIndex < steps.length - 1) {
            stepIndex++;
            steps[stepIndex - 1].transferToStep(steps[stepIndex]);
        }
    }
}