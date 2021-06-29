// SPDX-License-Identifier: GNU GPL v3

pragma solidity ^0.8.0;

import "./Step.sol";
import "./Detail.sol";

contract Item {
    Step initialStep;
    Step currentStep;
    string name;
    Detail [] details;

    constructor(string memory _name, Step _initialStep) {
        name = _name;
        initialStep = _initialStep;
        currentStep = _initialStep;
    }

    function addDetail(Detail detail) external {
        details.push(detail);
    }

    function setStep(Step step) external {
        currentStep = step;
    }
}