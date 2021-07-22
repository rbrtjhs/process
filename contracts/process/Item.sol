// SPDX-License-Identifier: GNU GPL v3

pragma solidity ^0.8.0;

import "./Step.sol";
import "../detail/Detail.sol";
import "./Process.sol";
import "../ProcessLibrary.sol";

contract Item {
    Step public initialStep;
    Step public currentStep;
    Process process;
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
        details[address(currentStep)].push(detail);
    }

    function setStep(Step step) external onlyCurrentStep() {
        currentStep = step;
    }

    function setInitialStep(Step step) external onlyProcess() {
        currentStep = step;
        initialStep = step;
    }
}