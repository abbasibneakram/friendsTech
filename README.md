# FriendtechSharesV1 Smart Contract

This smart contract allows users to buy and sell shares using ERC-20 tokens.

## Changes Made

### Modified `buyShares` and `sellShares` Functions

The `buyShares` and `sellShares` functions have been modified to handle ERC-20 tokens instead of Ether. The changes include:

- Removed the payable keyword as there is no need to pay with Ether in the `sellShares` function.
- Introduced the `erc20TokenAddress` variable to store the address of the ERC-20 token contract.
- Interacted with the ERC-20 token contract (`IERC20`) to check the user's balance and transfer tokens.
- Used the `transferFrom` function to transfer tokens from the user to the contract.
- Adjusted the fee distribution to use the `transfer` function for distributing fees in ERC-20 tokens.
- Added an internal function to calculate the fee distribution to different parties.
-

### Test Cases

Test cases have been provided to ensure the correct functionality of the modified contract. The test cases cover:

- Buying shares using ERC-20 tokens.
- Selling shares and receiving ERC-20 tokens in return.

## How to Run Tests

1. Install Truffle: Make sure you have Truffle installed globally.

   ```bash
   npm install -g truffle

   npm install

   truffle compile

   truffle test

   ```
