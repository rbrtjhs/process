// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "./Step.sol";
import "./Item.sol";
import "../ProcessLibrary.sol";
import "./ItemRegistry.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

/**
    @author rbrtjhs@gmail.com
    @title Process is the main class for managing items through process. Each step has to be 
    created manually and later on transfered to the step executor which can be e.g. machine.
 */
contract Process is Ownable {
    event StepChanged(Process process, Step fromStep, Step toStep, Item item);
    
    modifier onlyStepOwner(Item item) {
        require(item.currentStep().owner() == msg.sender, "Only step owner can change");
        _;
    }

    modifier inStatus(ProcessLibrary.ProcessStatus _status) {
        require(status == _status, "Process is in not in desired status");
        _;
    }

    Step[] public steps;
    ProcessLibrary.ProcessStatus public status;
    string public name;
    ItemRegistry public itemRegistry;
    uint public itemsFinished;

    constructor(string memory _name) {
        status = ProcessLibrary.ProcessStatus.MODIFIABLE;
        steps.push(new Step("Initial step", this));
        name = _name;
        itemRegistry = new ItemRegistry();
        itemsFinished = 0;
    }

    function addItem(Item _item) external onlyOwner() {
        itemRegistry.addItem(_item);
    }

    function addStep(Step _step) external onlyOwner() inStatus(ProcessLibrary.ProcessStatus.MODIFIABLE) {
        steps.push(_step);
    }

    function removeSteps(uint256[] memory _indexes) external onlyOwner() inStatus(ProcessLibrary.ProcessStatus.MODIFIABLE) {
        for (uint256 i = 0; i < _indexes.length; i++) {
            removeStep(_indexes[i]);
        }
    }

    function removeStep(uint _index) public onlyOwner() inStatus(ProcessLibrary.ProcessStatus.MODIFIABLE) {
        if (_index >= steps.length || _index == 0) {
            return;
        }

        for (uint i = _index; i < steps.length-1; i++){
            steps[i] = steps[i+1];
        }
        delete steps[steps.length-1];
    }

    /**
        This function finishes the creation of the process. 
        This includes checking if the process has at least one step.
        It also includes if there are any items in it.
        For each item it will  
     */
    function finishCreation() external onlyOwner() inStatus(ProcessLibrary.ProcessStatus.MODIFIABLE) {
        require(steps.length > 1, "Process needs at least 1 step"); 
        require(itemRegistry.getItemsSize() > 0, "Process needs at least one item");
        for (uint i = 0; i < steps.length; i++) {
            require(steps[i].process() == this, "Each step must have this process as set process");
            steps[i].setItem(Item(address(0)));
        }
        steps[1].setItem(itemRegistry.items(0));
        for (uint i = 0; i < itemRegistry.getItemsSize(); i++) {
            itemRegistry.items(i).setInitialStep(steps[0]);
            itemRegistry.setItemStep(itemRegistry.items(i), 0);
        }
        status = ProcessLibrary.ProcessStatus.IN_PROGRESS;
    }

    /**
        Each time step executor finishes it's execution step should call process' nextStep method to move 
        the item to the next step.

        @param item is the moving to the next step.
     */
    function nextStep(Item item) external onlyStepOwner(item) inStatus(ProcessLibrary.ProcessStatus.IN_PROGRESS) {
        uint stepIndex = itemRegistry.itemStep(address(item));
        if (stepIndex < steps.length - 1) {
            require(address(item.details(address(steps[stepIndex]),0)) != address(0), "Can't move to the next step without adding a detail");
            steps[stepIndex].transferToStep(steps[stepIndex + 1]);
            stepIndex++;
            itemRegistry.setItemStep(item, stepIndex);

            emit StepChanged(this, steps[stepIndex - 1], steps[stepIndex], item);
        } else if (stepIndex == steps.length - 1) {
            itemsFinished++;
        } else if (itemRegistry.getItemsSize() == itemsFinished) {
            status = ProcessLibrary.ProcessStatus.FINISHED;
        }
    }
}