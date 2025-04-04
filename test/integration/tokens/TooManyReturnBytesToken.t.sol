// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {MainnetTokenTest} from "../MainnetToken.t.sol";

contract TooManyReturnBytesTokenTest is MainnetTokenTest {
    ReturnsTooMuchToken _token;

    function setupToken() internal override {
        _token = new ReturnsTooMuchToken();
        deal(address(token()), from, AMOUNT);
        vm.prank(from);
        token().approve(address(permit2), AMOUNT);
    }

    function token() internal view override returns (ERC20) {
        return ERC20(address(_token));
    }
}

contract ReturnsTooMuchToken {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public constant name = "ReturnsTooMuchToken";

    string public constant symbol = "RTMT";

    uint8 public constant decimals = 18;

    /*///////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() {
        totalSupply = type(uint256).max;
        balanceOf[msg.sender] = type(uint256).max;
    }

    /*///////////////////////////////////////////////////////////////
                              ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        assembly {
            mstore(0, 1)
            return(0, 4096)
        }
    }

    function transfer(address to, uint256 amount) public virtual {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        assembly {
            mstore(0, 1)
            return(0, 4096)
        }
    }

    function transferFrom(address from, address to, uint256 amount) public virtual {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        assembly {
            mstore(0, 1)
            return(0, 4096)
        }
    }
}
