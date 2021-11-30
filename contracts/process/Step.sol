// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "./Process.sol";
import "../detail/Detail.sol";
import "./Item.sol";
import "../ProcessLibrary.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
    @author rbrtjhs@gmail.com
    @title This contract represents one step in the process.
 */
contract Step is Ownable {

    modifier onlyProcess() {
        require(msg.sender == address(process), "Only process can change");
        _;
    }

    Process public process;
    Item public item;
    string public name;

    /** 
        @param _name of the step
        @param _process is the process the step belongs to.
     */
    constructor (string memory _name, Process _process) {
        process = _process;
        name = _name;
    }

    /**
        @param _detail Each step has to add some detail - what step did.
     */
    function addDetail(Detail _detail) external onlyOwner() {
        item.addDetail(_detail);
    }

    /**
        This function transfers from one step to another and can be only performed by the process. 
     */
    function transferToStep(Step _step) external onlyProcess() {
        require(address(item) != address(0), "Step is already empty");
        item.setStep(_step);
        item = Item(address(0));
    }

    /**
        Each step will add some details about what it is doing. To track who added what we need @param _item to track the details.
     */
    function setItem(Item _item) external onlyProcess() {
        item = _item;
    }
}