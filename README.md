# SZU Token (SZU)
SZU Token is an ERC-20 compliant token implemented on the Ethereum blockchain. It includes standard ERC-20 functionality along with additional features like batch transfers and token burning capabilities.

## Features

### Basic ERC-20 Functionality
- Token Name: "SZU Token"
- Token Symbol: "SZU"
- Decimals: 18 (standard ERC-20)
- Full ERC-20 standard implementation including transfers and allowances

### Additional Features
1. **Batch Transfer**
   - Transfer tokens to multiple recipients in a single transaction
   - Saves gas costs compared to multiple individual transfers
   - Includes safety checks for array lengths and balances

2. **Allowance Management**
   - `increaseAllowance`: Safely increase the amount of tokens a spender can use
   - `decreaseAllowance`: Safely decrease the amount of tokens a spender can use

3. **Token Burning**
   - Ability to burn (destroy) tokens, reducing the total supply
   - Only token holders can burn their own tokens

## Contract Functions

### Constructor
```solidity
constructor(uint256 initialSupply)
```
- Initializes the token with a specified initial supply
- Mints initial tokens to the deployer's address

### Batch Transfer
```solidity
function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) public returns (bool)
```
- Transfers different amounts of tokens to multiple addresses in one transaction
- Requirements:
  - Arrays must be of equal length
  - Arrays cannot be empty
  - Sender must have sufficient balance
  - Recipient addresses must be valid

### Allowance Management
```solidity
function increaseAllowance(address spender, uint256 addedValue) public returns (bool)
function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool)
```
- Safely modify the amount of tokens that a spender can use
- Prevents common allowance-related vulnerabilities

### Token Burning
```solidity
function burn(uint256 amount) public
```
- Burns (destroys) tokens from the caller's address
- Reduces total token supply

## Usage

1. Deploy the contract with desired initial supply
2. Use standard ERC-20 functions for basic token operations
3. Utilize batch transfer for efficient multiple transfers
4. Manage allowances safely using increase/decrease functions
5. Burn tokens when needed to reduce supply

## Security Considerations

- The contract inherits from OpenZeppelin's ERC20 implementation
- Includes checks for array lengths and zero addresses
- Validates balances before transfers
- Uses safe math operations (Solidity ^0.8.0)

## Requirements

- Solidity ^0.8.18
- OpenZeppelin Contracts library

## License

This project is licensed under the MIT License.
