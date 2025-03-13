// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {IERC20Permit} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {Nonces} from "../lib/openzeppelin-contracts/contracts/utils/Nonces.sol";


contract GovToken is ERC20, ERC20Permit, ERC20Votes {
    constructor() ERC20("MyToken", "MTK") ERC20Permit("MyToken") {}

    // The following functions are overrides required by Solidity.

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function _mint(address to, uint256 amount) internal override(ERC20) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20) {
        super._burn(account, amount);
    }

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(address owner) public view virtual override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}