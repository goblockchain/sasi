pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract mockERC1155Token is ERC1155("mockURI") {
    constructor() {
        _mint(msg.sender, 1, 10 ether, "0x");
        _mint(address(101), 1, 0.1 ether, "0x");
    }

    function mint(address _to, uint _id, uint _amount) external {
        _mint(_to, _id, _amount, "0x");
    }
}

contract mockERC20Token is ERC20("mockToken0", "T0") {
    event Log(address from);

    constructor() {
        emit Log(msg.sender);
        _mint(msg.sender, 10 ether);
        _mint(address(101), 2 ether);
    }

    function mint(address _to, uint _amount) external {
        _mint(_to, _amount);
    }
}
