// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TodoList {
    struct Todo {
        string text;
        bool completed;
    }

    Todo[] public todos;
    address public owner;

    event TodoCreated(uint256 index, string text);
    event TodoCompleted(uint256 index);

    constructor() {
        owner = msg.sender;
    }

    function create(string memory text) external {
        todos.push(Todo(text, false));
        emit TodoCreated(todos.length - 1, text);
    }

    function complete(uint256 index) external {
        require(index < todos.length, "Invalid");
        require(!todos[index].completed, "Already done");
        todos[index].completed = true;
        emit TodoCompleted(index);
    }

    function getCount() external view returns (uint256) {
        return todos.length;
    }
}