// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Step.sol";
import "../detail/Detail.sol";
import "./Process.sol";
import "../ProcessLibrary.sol";

contract Item {
    event DetailAdded(Process process, Step step, Item item);

    Step public initialStep;
    Step public currentStep;
    Process public process;
    string public name;
    mapping(address => Detail[]) public details;

    modifier onlyCurrentStep() {
        require(msg.sender == address(currentStep), "Only current step can change");
        _;
    }

    modifier onlyProcess() {
        require(msg.sender == address(process), "Only process can change");
        _;
    }

    constructor(string memory _name, Process _process) {
        name = _name;
        process = _process;
    }

    function addDetail(Detail detail) external onlyCurrentStep() {
        require(process.status() == ProcessLibrary.ProcessStatus.IN_PROGRESS, "Detail can't be added if the process is not in status IN_PROGRESS");
        details[address(currentStep)].push(detail);

        emit DetailAdded(process, currentStep, this);
    }

    function setStep(Step step) external onlyCurrentStep() {
        currentStep = step;
    }

    function setInitialStep(Step step) external onlyProcess() {
        currentStep = step;
        initialStep = step;
    }
}