// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

// ContractName__ErrorName() is a convention for error messages
error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint;

    // constants are set with value immediately
    uint public constant MINIMUM_USD = 50 * 1 ether;

    // immutables can only set with a value once
    // i_ is a convention for immutables
    address public immutable i_owner;

    // s_ used as a convention for state variables
    address[] private s_funders;

    mapping(address => uint) private s_addressToAmountFunded;

    AggregatorV3Interface private s_priceFeed;

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        // clear funded amount to zero
        for (uint fundersIndex; fundersIndex < s_funders.length; fundersIndex++) {
            address funder = s_funders[fundersIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // clear funders array
        s_funders = new address[](0);

        // send balance to owner
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "failed to withdraw funds");
    }

    function getAddressToAmountFunded(address fundingAddress) public view returns (uint) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() public view returns (uint) {
        return s_priceFeed.version();
    }

    function getFunder(uint index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

}
