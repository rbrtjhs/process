// SPDX-License-Identifier: GNU GPL v3

pragma solidity ^0.8.0;

import "./Process.sol";
import "./Detail.sol";
import "./Item.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Step is Ownable {
    modifier onlyProcess() {
        require(msg.sender == address(process), "Only process can change.");
        _;
    }

    Process public process;
    Item public item;
    string public name;

    constructor (string memory _name, Process _process) {
        process = _process;
        name = _name;
        process.addStep(this);
    }

    function addDetail(Detail _detail) external onlyOwner() {
        //only during in_progress
        item.addDetail(_detail);
    }

    function transferToStep(Step _step) external onlyProcess() {
        item.setStep(_step);
    }

    function setItem(Item _item) external onlyProcess() {
        item = _item;
    }
}