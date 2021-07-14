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
        require(status == _status);
        _;
    }

    modifier onlyStepOwner() {
        require(steps[stepIndex].owner() == msg.sender);
        _;
    }

    Item public item;
    Step [] public steps;
    ProcessStatus public status;
    uint256 public stepIndex;
    string public name;

    constructor(string memory _name) {
        status = ProcessStatus.MODIFIABLE;
        stepIndex = 0;
        name = _name;
    }

    function setItem(Item _item) inStatus(ProcessStatus.MODIFIABLE) external {
        item = _item;
    }

    function addStep(Step _step) inStatus(ProcessStatus.MODIFIABLE) external {
        steps.push(_step);   
    }

    function removeSteps(uint256 [] memory _indexes) inStatus(ProcessStatus.MODIFIABLE)  external {
        for (uint256 i = 0; i < _indexes.length; i++) {
            removeStep(_indexes[i]);
        }
    }

    function removeStep(uint index) inStatus(ProcessStatus.MODIFIABLE) public {
        if (index >= steps.length) return;

        for (uint i = index; i < steps.length-1; i++){
            steps[i] = steps[i+1];
        }
        delete steps[steps.length-1];
    }

    function finishCreation() inStatus(ProcessStatus.MODIFIABLE) external {
        require(steps.length > 0);
        //require(item);
        status = ProcessStatus.IN_PROGRESS;
    }

    function nextStep() onlyStepOwner() inStatus(ProcessStatus.IN_PROGRESS) external {
        if (stepIndex < steps.length - 1) {
            stepIndex++; 
            steps[stepIndex - 1].transferToStep(steps[stepIndex]);
        }
    }
}