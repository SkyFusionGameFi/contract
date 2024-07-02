// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "./ERC20.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";

interface IPresale {
    function buy(address buyer, uint amount, address refer) external;
}

contract SkyFusion is ERC20, Ownable {
    ERC20 public USDT = ERC20(0x55d398326f99059fF775485246999027B3197955);

    address public PRESALE_ADDRESS;

    uint public startTrading;

    mapping(address => bool) private whiteLists;


    constructor() ERC20("SkyFusion Token", "SFT")
    {
        _mint(msg.sender, 50_000_000_000 * 10 ** 18);
        whiteLists[msg.sender] = true;
    }

    function _transfer(address from, address to, uint amount) internal override {
        if (startTrading == 0) {
            require(whiteLists[from] || whiteLists[to], "Trading starts only after the token is listed.");
        }
        super._transfer(from, to, amount);
    }

    function buy(uint amount, address refer) external payable {
        require(PRESALE_ADDRESS != address(0), "presale not set");
        USDT.transferFrom(msg.sender, PRESALE_ADDRESS, amount);
        IPresale(PRESALE_ADDRESS).buy(msg.sender, amount, refer);
    }

    function safeTransferFrom(address from, address to, uint amount) public {
        require(msg.sender == PRESALE_ADDRESS);
        transfer(from, to, amount);
    }

    function setPresale(address _presale) external onlyOwner {
        PRESALE_ADDRESS = _presale;
        whiteLists[PRESALE_ADDRESS] = true;
    }

    function enableTrading() external onlyOwner {
        startTrading = 1;
    }

    function addWhiteLists(address user, bool _wl) external onlyOwner {
        whiteLists[user] = _wl;
    }

    receive() payable external {}
}