//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract SZUToken is ERC20 {
    /*
     * @dev Constructor that initializes the SZU token with a given initial supply
     * @param initialSupply The initial amount of tokens to mint
     * Creates a new SZU token with "SZU Token" name and "SZU" symbol
     * Mints the initial supply to the deployer's address
     */
    constructor(uint256 initialSupply) ERC20("SZU Token", "SZU") {
        _mint(msg.sender, initialSupply);
    }

    /*
     * @dev Increases the allowance granted to `spender` by the caller by `addedValue`
     * @param spender The address which will be granted increased allowance
     * @param addedValue The amount by which to increase the allowance
     * @return bool indicating success
     * Similar to {approve} but safer as it works atomically
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /*
     * @dev Decreases the allowance granted to `spender` by the caller by `subtractedValue`
     * @param spender The address which will have its allowance decreased
     * @param subtractedValue The amount by which to decrease the allowance
     * @return bool indicating success
     * Similar to {approve} but safer as it works atomically
     * Requires that the current allowance is greater than or equal to subtractedValue
     */
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
}
