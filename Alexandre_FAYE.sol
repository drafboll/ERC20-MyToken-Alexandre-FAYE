// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IERC20.sol";

contract MyToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances; 
    address public owner;
    
    // pour les bonus (Mint et Burn)
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "OWNER_ONLY");
        _;
    }
    
    constructor() {
        name = "AlexandreTOKEN";
        symbol = "WST";
        decimals = 18;
        owner = msg.sender;
        
        uint256 initialSupply = 5_000_000 * 10**uint256(decimals); 
        _totalSupply = initialSupply;
        _balances[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    
    function allowance(address _owner, address spender) external view override returns (uint256) {
        return _allowances[_owner][spender];
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(msg.sender != address(0), "TRANSFER_FROM_ZERO");
        require(recipient != address(0), "TRANSFER_TO_ZERO");
        require(_balances[msg.sender] >= amount, "INSUFFICIENT_BALANCE");
        
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "APPROVE_TO_ZERO");
        // CORRECTION : utilise _allowances
        _allowances[msg.sender][spender] = amount;
        
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(sender != address(0), "TRANSFER_FROM_ZERO");
        require(recipient != address(0), "TRANSFER_TO_ZERO");
        require(_balances[sender] >= amount, "INSUFFICIENT_BALANCE");

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "INSUFFICIENT_ALLOWANCE");
        
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        
        _allowances[sender][msg.sender] = currentAllowance - amount; 
        
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function mint(uint256 amount) external onlyOwner {
        require(amount > 0, "AMOUNT_ZERO");
        _totalSupply += amount;
        _balances[owner] += amount;
        emit Mint(owner, amount);
        emit Transfer(address(0), owner, amount);
    }
    
    function burn(uint256 amount) external {
        require(amount > 0, "AMOUNT_ZERO");
        require(_balances[msg.sender] >= amount, "INSUFFICIENT_BALANCE_FOR_BURN");
        _totalSupply -= amount;
        _balances[msg.sender] -= amount;
        emit Burn(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }
    
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "INVALID_NEW_OWNER");
        owner = newOwner;
    }
}