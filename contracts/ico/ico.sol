pragma solidity ^0.4.0;
contract fund {
    /* Define variable owner of the type address */
    address owner;

    function fund() {
        owner = msg.sender;
    }

    function kill() { if (msg.sender == owner) selfdestruct(owner); }
}