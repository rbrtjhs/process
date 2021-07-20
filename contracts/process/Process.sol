// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./Step.sol";
import "./Item.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { ProcessLibrary } from "../ProcessLibrary.sol";

contract Process is Ownable {

    modifier inStatus(ProcessLibrary.ProcessStatus _status) {
        require(status == _status, "Process is in not in desired status");
        _;
    }

    modifier onlyStepOwner() {
        require(steps[stepIndex].owner() == msg.sender, "Only step owner can change");
        _;
    }

    Item public item;
    Step[] public steps;
    ProcessLibrary.ProcessStatus public status;
    uint256 public stepIndex;
    string public name;

    constructor(string memory _name) {
        status = ProcessLibrary.ProcessStatus.MODIFIABLE;
        stepIndex = 0;
        name = _name;
    }

    function setItem(Item _item) external inStatus(ProcessLibrary.ProcessStatus.MODIFIABLE) {
        item = _item;
    }

    function addStep(Step _step) external inStatus(ProcessLibrary.ProcessStatus.MODIFIABLE) {
        steps.push(_step);
    }

    function removeSteps(uint256[] memory _indexes) external inStatus(ProcessLibrary.ProcessStatus.MODIFIABLE) {
        for (uint256 i = 0; i < _indexes.length; i++) {
            removeStep(_indexes[i]);
        }
    }

    function removeStep(uint index) public inStatus(ProcessLibrary.ProcessStatus.MODIFIABLE) {
        if (index >= steps.length) return;

        for (uint i = index; i < steps.length-1; i++){
            steps[i] = steps[i+1];
        }
        delete steps[steps.length-1];
    }

    function finishCreation() external inStatus(ProcessLibrary.ProcessStatus.MODIFIABLE) {
        require(steps.length > 0, "Process needs at least 1 step");
        require(address(item) != address(0), "Process needs item");
        for (uint i = 0; i < steps.length; i++) {
            steps[i].setItem(item);
        }
        status = ProcessLibrary.ProcessStatus.IN_PROGRESS;
    }

    function nextStep() external onlyStepOwner() inStatus(ProcessLibrary.ProcessStatus.IN_PROGRESS) {
        if (stepIndex < steps.length - 1) {
            require(address(item.details(address(steps[stepIndex]),0)) != address(0), "Can't move to the next step without adding a detail.");
            steps[stepIndex].transferToStep(steps[stepIndex + 1]);
            stepIndex++;
            if (stepIndex == steps.length - 1) {
                status = ProcessLibrary.ProcessStatus.FINISHED;
            }
        }
    }
}