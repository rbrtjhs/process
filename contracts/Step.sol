// SPDX-License-Identifier: GNU GPL v3

pragma solidity ^0.8.0;

import "./Process.sol";
import "./Detail.sol";
import "./Item.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";

contract Step is Ownable {
    modifier onlyProcess() {
        require(msg.sender == address(process));
        _;
    }

    Process process;
    Item item;

    constructor (Process _process) {
        process = _process;
    }

    function addDetail(Detail _detail) onlyOwner() external {
        item.addDetail(_detail);
    }

    function transferToStep(Step _step) onlyProcess() external {
        item.setStep(_step);
    }

    function setItem(Item _item) onlyProcess() external {
        item = _item;
    }
}