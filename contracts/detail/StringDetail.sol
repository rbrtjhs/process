// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "./Detail.sol";

/**
    @author rbrtjhs@gmail.com
 */
contract StringDetail is Detail {
    string public text;

    constructor(string memory _text) {
        text = _text;
    }
}