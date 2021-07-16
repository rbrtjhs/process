// SPDX-License-Identifier: GNU GPL v3

pragma solidity ^0.8.0;

import "./Detail.sol";

contract StringDetail is Detail {
    string public text;

    constructor(string memory _text) {
        text = _text;
    }
}