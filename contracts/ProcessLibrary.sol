// SPDX-License-Identifier: GNU GPL v3

pragma solidity ^0.8.0;

library ProcessLibrary {
    enum ProcessStatus {
        MODIFIABLE,
        IN_PROGRESS,
        FINISHED
    }
}