// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "./Item.sol";
import "./Process.sol";

import "@openzeppelin/contracts/access/Ownable.sol";


/**
    @author rbrtjhs@gmail.com
    @title This contract is used to track all the items for specific process. Each step can only have item at the time.
 */
contract ItemRegistry is Ownable {

    Process process;
    Item[] public items;
    mapping(address => uint) public itemStep;

    constructor() {
        process = Process(msg.sender);
    }

    function addItem(Item item) external onlyOwner() {
        items.push(item);
    }

    /**
        @return count of the items.
     */
    function getItemsSize() external view returns (uint count) {
        return items.length;
    }

    /**
        For @param item will be set @param stepIndex.
     */
    function setItemStep(Item item, uint stepIndex) external {
        require(address(process) == msg.sender, "Only process can change which item is assigned to can set the initial step"); 
        itemStep[address(item)] = stepIndex;
    }
}