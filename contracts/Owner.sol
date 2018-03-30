pragma solidity ^0.4.18;

contract Owner {
  // state variables
  address owner;

  // modifiers
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // constructor
  function Owner() public {
    owner = msg.sender;
  }
  
}
