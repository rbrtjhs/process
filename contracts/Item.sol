// SPDX-License-Identifier: GNU GPL v3

pragma solidity ^0.8.0;

import "./Step.sol";
import "./Detail.sol";

contract Item {
    Step public initialStep;
    Step public currentStep;
    string public name;
    mapping(address => Detail []) public details;

    modifier onlyCurrentStep() {
        require(msg.sender == address(currentStep));
        _;
    }

    constructor(string memory _name, Step _initialStep) {
        name = _name;
        initialStep = _initialStep;
        currentStep = _initialStep;
    }

    function addDetail(Detail detail) onlyCurrentStep() external {
        details[address(currentStep)].push(detail);
    }

    function setStep(Step step) onlyCurrentStep() external {
        currentStep = step;
    }
}