pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Pausable.sol";
// SPDX-License-Identifier: MIT

/**
 * @dev Implementation of the {IERC20} interface.
 * Richard Liu - Mar 2021 - Assesment based on Nick Friedland  from Sifchain
 * Design an ERC20 compliant token where the balances reset every time you upgrade it.
If you own this stablecoin in January, and there is always a smart contract upgrade at the end of
each month, then in February, you should not own those stablecoins anymore. Your token
should have all ERC20 interfaces and events. You can use whatever framework or version of
solidity that you would like, but you cannot use a framework for handling the creation of the
proxy contracts. It would be great to have a few tests to demonstrate functionality without having
to manually run through things.
 */
contract ERC20 is IERC20, Pausable {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 _totalSupply = 2000000000 * 10 ** uint256(6);   //Fixed 2 billion total supply with 6 decimals

    string private _name;
    string private _symbol;
    uint private _deployedDateTime;  //This is the contract deloyed date and time. it will be used by "isOver30Days" to check if the contract is over 30 days


    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _deployedDateTime = block.timestamp;
         _balances[msg.sender] = _totalSupply;      // Give the creator all initial total tokens
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
         if (isOver30Days()) {
            return 0;    // If this contract is over 30 days old, it reset as 0
         }else{        
            return _totalSupply;
         }    
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        if (isOver30Days()) {
            return 0;   // If this contract is over 30 days old, it reset as 0
        }else{
            return _balances[account];
        }
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public whenNotPaused virtual override returns (bool) {
         require(!isOver30Days() , "Over 30 days.");  // If this contract is over 30 days old, this function will be disabled
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
         if (isOver30Days()) {
            return 0;  // If this contract is over 30 days old, it reset as 0
         }else{
            return _allowances[owner][spender];
         }   
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public whenNotPaused virtual override returns (bool) {
        require(!isOver30Days() , "Over 30 days.");  // If this contract is over 30 days old, this function will be disabled
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public whenNotPaused virtual override returns (bool) {
        
         require(!isOver30Days() , "Over 30 days.");  // If this contract is over 30 days old, this function will be disabled
          
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }


    /**
     * @dev return contract deployed date and time.
     */
    function deployedDateTime() public view virtual returns (uint) {
        return _deployedDateTime;
    }    

    /**
     * @dev return of this contract is 30 days old.
     */
    function isOver30Days() public view virtual returns (bool) {
        //return ( block.timestamp > _deployedDateTime + 10 minutes );
        return ( block.timestamp > _deployedDateTime + 30 days );
    }  
    
    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }


    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}