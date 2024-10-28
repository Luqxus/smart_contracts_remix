// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleStorage {
    uint256 number;

    function store(uint256 _num) external {
        number = _num;
    }

    function retrieve() external view returns(uint256) {
        return number;
    }
}