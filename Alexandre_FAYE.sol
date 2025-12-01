// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
// Va permettre d'importer le fichier IERC20
import "./IERC20.sol";

// Notre contrat MyToken qui respecte le plan de votre exercice
contract MyToken is IERC20 {
    // Les infos publiques, qui va servir à ce qui veuelent utiliser
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public _totalSupply;

    // Le tiroir pour savoir qui a quoi
    // Ce mapping stocke le solde de chaque utilisateur
    mapping(address => uint256) public _balances;
    
    // Il enregistre combien j'autorise une autre adresse à dépenser de mes tokens
    mapping(address => mapping(address => uint256)) public _allowances; 
    address public owner;
    
    // J'ai mis ça pour bloquer l'accès à certaines fonctions, nous seul pouvons le modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "OWNER_ONLY");
        _;
    }
    
    // J'initialise le nom et le symbole 
    constructor() {
        name = "AlexandreTOKEN";
        symbol = "WST";
        decimals = 18;
        owner = msg.sender;
        
        // On calcule les 1 million de tokens avec les 18 décimales
        uint256 initialSupply = 1_000_000 * 10**uint256(decimals); 
        _totalSupply = initialSupply;
        _balances[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }
    
    // Fonctions de lecture, ici les focntions ne demande pas de gaz, donc ca ne va aps modifier l'étatd e la bloc chain
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    
    function allowance(address _owner, address spender) external view override returns (uint256) {
        return _allowances[_owner][spender];
    }
    
    // fonctions de transaction ici coutent du gaz
    // Sécurité : Faut pas transférer depuis/vers l'adresse 0, et faut avoir assez de sous
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(msg.sender != address(0), "TRANSFER_FROM_ZERO");
        require(recipient != address(0), "TRANSFER_TO_ZERO");
        require(_balances[msg.sender] >= amount, "INSUFFICIENT_BALANCE");

        // Je me retire le montant, et je le donne au destinataire
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
    // permet de donner la permission à une autre adresse pour depenser ses tokens pour lui
    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "APPROVE_TO_ZERO");
        // utilise _allowances
        _allowances[msg.sender][spender] = amount;
        
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    // Il permet d'exécuter une procuration en autorisant une adresse tierce à envoyer des tokens en tant que owner grace à la focntion approve
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
}
