{"ERC20.sol":{"content":"pragma solidity ^0.5.17;\n\nimport \"./IERC20.sol\";\nimport \"./SafeMath.sol\";\n\n/**\n * @dev Implementation of the `IERC20` interface.\n *\n * This implementation is agnostic to the way tokens are created. This means\n * that a supply mechanism has to be added in a derived contract using `_mint`.\n * For a generic mechanism see `ERC20Mintable`.\n *\n * *For a detailed writeup see our guide [How to implement supply\n * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*\n *\n * We have followed general OpenZeppelin guidelines: functions revert instead\n * of returning `false` on failure. This behavior is nonetheless conventional\n * and does not conflict with the expectations of ERC20 applications.\n *\n * Additionally, an `Approval` event is emitted on calls to `transferFrom`.\n * This allows applications to reconstruct the allowance for all accounts just\n * by listening to said events. Other implementations of the EIP may not emit\n * these events, as it isn\u0027t required by the specification.\n *\n * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`\n * functions have been added to mitigate the well-known issues around setting\n * allowances. See `IERC20.approve`.\n */\ncontract ERC20 is IERC20 {\n    using SafeMath for uint256;\n\n    mapping (address =\u003e uint256) internal _balances;\n\n    mapping (address =\u003e mapping (address =\u003e uint256)) internal _allowed;\n\n    uint256 private _totalSupply;\n\n    /**\n    * @dev Total number of tokens in existence\n    */\n    function totalSupply() public view returns (uint256) {\n        return _totalSupply;\n    }\n\n    /**\n    * @dev Gets the balance of the specified address.\n    * @param owner The address to query the balance of.\n    * @return An uint256 representing the amount owned by the passed address.\n    */\n    function balanceOf(address owner) public view returns (uint256) {\n        return _balances[owner];\n    }\n\n    /**\n     * @dev Function to check the amount of tokens that an owner allowed to a spender.\n     * @param owner address The address which owns the funds.\n     * @param spender address The address which will spend the funds.\n     * @return A uint256 specifying the amount of tokens still available for the spender.\n     */\n    function allowance(address owner, address spender) public view returns (uint256) {\n        return _allowed[owner][spender];\n    }\n\n    /**\n    * @dev Transfer token for a specified address\n    * @param to The address to transfer to.\n    * @param value The amount to be transferred.\n    */\n    function transfer(address to, uint256 value) public returns (bool) {\n        _transfer(msg.sender, to, value);\n        return true;\n    }\n\n    /**\n     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\n     * Beware that changing an allowance with this method brings the risk that someone may use both the old\n     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\n     * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     * @param spender The address which will spend the funds.\n     * @param value The amount of tokens to be spent.\n     */\n    function approve(address spender, uint256 value) public returns (bool) {\n        require(spender != address(0), \"ERC20: approve from the zero address\");\n\n        _allowed[msg.sender][spender] = value;\n        emit Approval(msg.sender, spender, value);\n        return true;\n    }\n\n    /**\n     * @dev Transfer tokens from one address to another.\n     * Note that while this function emits an Approval event, this is not required as per the specification,\n     * and other compliant implementations may not emit the event.\n     * @param from address The address which you want to send tokens from\n     * @param to address The address which you want to transfer to\n     * @param value uint256 the amount of tokens to be transferred\n     */\n    function transferFrom(address from, address to, uint256 value) public returns (bool) {\n        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);\n        _transfer(from, to, value);\n        emit Approval(from, msg.sender, _allowed[from][msg.sender]);\n        return true;\n    }\n\n    /**\n     * @dev Increase the amount of tokens that an owner allowed to a spender.\n     * approve should be called when allowed_[_spender] == 0. To increment\n     * allowed value is better to use this function to avoid 2 calls (and wait until\n     * the first transaction is mined)\n     * From MonolithDAO Token.sol\n     * Emits an Approval event.\n     * @param spender The address which will spend the funds.\n     * @param addedValue The amount of tokens to increase the allowance by.\n     */\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\n        require(spender != address(0), \"ERC20: increaseAllowance from the zero address\");\n\n        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);\n        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);\n        return true;\n    }\n\n    /**\n     * @dev Decrease the amount of tokens that an owner allowed to a spender.\n     * approve should be called when allowed_[_spender] == 0. To decrement\n     * allowed value is better to use this function to avoid 2 calls (and wait until\n     * the first transaction is mined)\n     * From MonolithDAO Token.sol\n     * Emits an Approval event.\n     * @param spender The address which will spend the funds.\n     * @param subtractedValue The amount of tokens to decrease the allowance by.\n     */\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\n        require(spender != address(0), \"ERC20: decreaseAllowance from the zero address\");\n\n        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);\n        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);\n        return true;\n    }\n\n    /**\n    * @dev Transfer token for a specified addresses\n    * @param from The address to transfer from.\n    * @param to The address to transfer to.\n    * @param value The amount to be transferred.\n    */\n    function _transfer(address from, address to, uint256 value) internal {\n        require(to != address(0), \"ERC20: account to the zero address\");\n\n        _balances[from] = _balances[from].sub(value);\n        _balances[to] = _balances[to].add(value);\n        emit Transfer(from, to, value);\n    }\n\n    /**\n     * @dev Internal function that mints an amount of the token and assigns it to\n     * an account. This encapsulates the modification of balances such that the\n     * proper events are emitted.\n     * @param account The account that will receive the created tokens.\n     * @param value The amount that will be created.\n     */\n    function _mint(address account, uint256 value) internal {\n        require(account != address(0), \"ERC20: account from the zero address\");\n\n        _totalSupply = _totalSupply.add(value);\n        _balances[account] = _balances[account].add(value);\n        emit Transfer(address(0), account, value);\n    }\n\n    /**\n     * @dev Internal function that burns an amount of the token of a given\n     * account.\n     * @param account The account whose tokens will be burnt.\n     * @param value The amount that will be burnt.\n     */\n    function _burn(address account, uint256 value) internal {\n        require(account != address(0), \"ERC20: account from the zero address\");\n\n        _totalSupply = _totalSupply.sub(value);\n        _balances[account] = _balances[account].sub(value);\n        emit Transfer(account, address(0), value);\n    }\n\n    /**\n     * @dev Internal function that burns an amount of the token of a given\n     * account, deducting from the sender\u0027s allowance for said account. Uses the\n     * internal burn function.\n     * Emits an Approval event (reflecting the reduced allowance).\n     * @param account The account whose tokens will be burnt.\n     * @param value The amount that will be burnt.\n     */\n    function _burnFrom(address account, uint256 value) internal {\n        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);\n        _burn(account, value);\n        emit Approval(account, msg.sender, _allowed[account][msg.sender]);\n    }\n}"},"ERC20Burnable.sol":{"content":"pragma solidity ^0.5.17;\n\nimport \"./ERC20.sol\";\n\n/**\n * @dev Extension of `ERC20` that allows token holders to destroy both their own\n * tokens and those that they have an allowance for, in a way that can be\n * recognized off-chain (via event analysis).\n */\ncontract ERC20Burnable is ERC20 {\n    /**\n     * @dev Destroys `amount` tokens from the caller.\n     *\n     * See `ERC20._burn`.\n     */\n    function burn(uint256 amount) public {\n        _burn(msg.sender, amount);\n    }\n\n    /**\n     * @dev See `ERC20._burnFrom`.\n     */\n    function burnFrom(address account, uint256 amount) public {\n        _burnFrom(account, amount);\n    }\n}"},"ERC20Detailed.sol":{"content":"pragma solidity ^0.5.17;\n\nimport \"./IERC20.sol\";\n\n/**\n * @dev Optional functions from the ERC20 standard.\n */\ncontract ERC20Detailed is IERC20 {\n    string private _name;\n    string private _symbol;\n    uint8 private _decimals;\n\n    /**\n     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of\n     * these values are immutable: they can only be set once during\n     * construction.\n     */\n    constructor (string memory name, string memory symbol, uint8 decimals) public {\n        _name = name;\n        _symbol = symbol;\n        _decimals = decimals;\n    }\n\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() public view returns (string memory) {\n        return _name;\n    }\n\n    /**\n     * @dev Returns the symbol of the token, usually a shorter version of the\n     * name.\n     */\n    function symbol() public view returns (string memory) {\n        return _symbol;\n    }\n\n    /**\n     * @dev Returns the number of decimals used to get its user representation.\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\n     * be displayed to a user as `5,05` (`505 / 10 ** 2`).\n     *\n     * Tokens usually opt for a value of 18, imitating the relationship between\n     * Ether and Wei.\n     *\n     * \u003e Note that this information is only used for _display_ purposes: it in\n     * no way affects any of the arithmetic of the contract, including\n     * `IERC20.balanceOf` and `IERC20.transfer`.\n     */\n    function decimals() public view returns (uint8) {\n        return _decimals;\n    }\n}"},"ERC20Mintable.sol":{"content":"pragma solidity ^0.5.17;\n\nimport \"./ERC20.sol\";\nimport \"./MinterRole.sol\";\n\n/**\n * @dev Extension of `ERC20` that adds a set of accounts with the `MinterRole`,\n * which have permission to mint (create) new tokens as they see fit.\n *\n * At construction, the deployer of the contract is the only minter.\n */\ncontract ERC20Mintable is ERC20, MinterRole {\n    /**\n     * @dev See `ERC20._mint`.\n     *\n     * Requirements:\n     *\n     * - the caller must have the `MinterRole`.\n     */\n    function mint(address account, uint256 amount) public onlyMinter returns (bool) {\n        _mint(account, amount);\n        return true;\n    }\n}"},"ERC20Pausable.sol":{"content":"pragma solidity ^0.5.17;\n\nimport \"./ERC20.sol\";\nimport \"./Pausable.sol\";\n\n/**\n * @title Pausable token\n * @dev ERC20 with pausable transfers and allowances.\n *\n * Useful if you want to e.g. stop trades until the end of a crowdsale, or have\n * an emergency switch for freezing all token transfers in the event of a large\n * bug.\n */\ncontract ERC20Pausable is ERC20, Pausable {\n    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {\n        return super.transfer(to, value);\n    }\n\n    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {\n        return super.transferFrom(from, to, value);\n    }\n\n    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {\n        return super.approve(spender, value);\n    }\n\n    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {\n        return super.increaseAllowance(spender, addedValue);\n    }\n\n    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {\n        return super.decreaseAllowance(spender, subtractedValue);\n    }\n}"},"fanCToken.sol":{"content":"pragma solidity ^0.5.17;\n\nimport \"./ERC20.sol\";\nimport \"./ERC20Detailed.sol\";\nimport \"./ERC20Pausable.sol\";\nimport \"./ERC20Burnable.sol\";\nimport \"./ERC20Mintable.sol\";\nimport \"./Ownable.sol\";\n\n/**\n * @title SimpleToken\n * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.\n * Note they can later distribute these tokens as they wish using `transfer` and other\n * `ERC20` functions.\n */\ncontract FANC is ERC20, ERC20Detailed, ERC20Pausable, ERC20Burnable, ERC20Mintable, Ownable {\n\n    /**\n     * @dev Constructor that gives msg.sender all of existing tokens.\n     */\n    struct LockInfo {\n        uint256 _releaseTime;\n        uint256 _amount;\n    }\n   \n    address public implementation;\n\n    mapping (address =\u003e LockInfo[]) public timelockList;\n    mapping (address =\u003e bool) public frozenAccount;\n   \n    event Freeze(address indexed holder,bool status);    \n    event Lock(address indexed holder, uint256 value, uint256 releaseTime);\n    event Unlock(address indexed holder, uint256 value);\n\n    modifier notFrozen(address _holder) {\n        require(!frozenAccount[_holder], \"ERC20: frozenAccount\");\n        _;\n    }\n   \n    constructor () public ERC20Detailed(\"fanC Token\", \"FANC\", 18) {\n        _mint(msg.sender, 3000000000 * (10 ** uint256(decimals())));\n    }\n   \n    function balanceOf(address owner) public view returns (uint256) {\n       \n        uint256 totalBalance = super.balanceOf(owner);\n        if( timelockList[owner].length \u003e0 ){\n            for(uint i=0; i\u003ctimelockList[owner].length;i++){\n                totalBalance = totalBalance.add(timelockList[owner][i]._amount);\n            }\n        }\n       \n        return totalBalance;\n    }\n   \n    function transfer(address to, uint256 value) public notFrozen(msg.sender) notFrozen(to) returns (bool) {\n        if (timelockList[msg.sender].length \u003e 0 ) {\n            _autoUnlock(msg.sender);            \n        }\n        return super.transfer(to, value);\n    }\n   \n\n    function freezeAccount(address holder, bool value) public onlyPauser returns (bool) {        \n        frozenAccount[holder] = value;\n        emit Freeze(holder,value);\n        return true;\n    }\n\n    function lock(address holder, uint256 value, uint256 releaseTime) public onlyPauser returns (bool) {\n        require(_balances[holder] \u003e= value,\"There is not enough balances of holder.\");\n        _lock(holder,value,releaseTime);\n       \n        return true;\n    }\n   \n    function transferWithLock(address holder, uint256 value, uint256 releaseTime) public onlyPauser returns (bool) {\n        _transfer(msg.sender, holder, value);\n        _lock(holder,value,releaseTime);\n        return true;\n    }\n   \n    function unlock(address holder, uint256 idx) public onlyPauser returns (bool) {\n        require( timelockList[holder].length \u003e idx, \"There is not lock info.\");\n        _unlock(holder,idx);\n        return true;\n    }\n   \n    /**\n     * @dev Upgrades the implementation address\n     * @param _newImplementation address of the new implementation\n     */\n    function upgradeTo(address _newImplementation) public onlyOwner {\n        require(implementation != _newImplementation);\n        _setImplementation(_newImplementation);\n    }\n   \n    function _lock(address holder, uint256 value, uint256 releaseTime) internal returns(bool) {\n        _balances[holder] = _balances[holder].sub(value);\n        timelockList[holder].push( LockInfo(releaseTime, value) );\n       \n        emit Lock(holder, value, releaseTime);\n        return true;\n    }\n   \n    function _unlock(address holder, uint256 idx) internal returns(bool) {\n        LockInfo storage lockinfo = timelockList[holder][idx];\n        uint256 releaseAmount = lockinfo._amount;\n        timelockList[holder][idx] = timelockList[holder][timelockList[holder].length.sub(1)];\n        timelockList[holder].pop();\n       \n        emit Unlock(holder, releaseAmount);\n        _balances[holder] = _balances[holder].add(releaseAmount);\n       \n        return true;\n    }\n   \n    function _autoUnlock(address holder) internal returns(bool) {\n        for(uint256 idx =0; idx \u003c timelockList[holder].length ; idx++ ) {\n            if (timelockList[holder][idx]._releaseTime \u003c= now) {\n                // If lockupinfo was deleted, loop restart at same position.\n                if( _unlock(holder, idx) ) {\n                    idx -=1;\n                }\n            }\n        }\n        return true;\n    }\n   \n    /**\n     * @dev Sets the address of the current implementation\n     * @param _newImp address of the new implementation\n     */\n    function _setImplementation(address _newImp) internal {\n        implementation = _newImp;\n    }\n   \n    /**\n     * @dev Fallback function allowing to perform a delegatecall\n     * to the given implementation. This function will return\n     * whatever the implementation call returns\n     */\n    function () payable external {\n        address impl = implementation;\n        require(impl != address(0), \"ERC20: account is the zero address\");\n        assembly {\n            let ptr := mload(0x40)\n            calldatacopy(ptr, 0, calldatasize)\n            let result := delegatecall(gas, impl, ptr, calldatasize, 0, 0)\n            let size := returndatasize\n            returndatacopy(ptr, 0, size)\n           \n            switch result\n            case 0 { revert(ptr, size) }\n            default { return(ptr, size) }\n        }\n    }\n}"},"IERC20.sol":{"content":"pragma solidity ^0.5.17;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\n * the optional functions; to access them see `ERC20Detailed`.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a `Transfer` event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through `transferFrom`. This is\n     * zero by default.\n     *\n     * This value changes when `approve` or `transferFrom` are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * \u003e Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an `Approval` event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a `Transfer` event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to `approve`. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}"},"MinterRole.sol":{"content":"pragma solidity ^0.5.17;\n\nimport \"./Roles.sol\";\n\ncontract MinterRole {\n    using Roles for Roles.Role;\n\n    event MinterAdded(address indexed account);\n    event MinterRemoved(address indexed account);\n\n    Roles.Role private _minters;\n\n    constructor () internal {\n        _addMinter(msg.sender);\n    }\n\n    modifier onlyMinter() {\n        require(isMinter(msg.sender), \"MinterRole: caller does not have the Minter role\");\n        _;\n    }\n\n    function isMinter(address account) public view returns (bool) {\n        return _minters.has(account);\n    }\n\n    function addMinter(address account) public onlyMinter {\n        _addMinter(account);\n    }\n\n    function renounceMinter() public {\n        _removeMinter(msg.sender);\n    }\n\n    function _addMinter(address account) internal {\n        _minters.add(account);\n        emit MinterAdded(account);\n    }\n\n    function _removeMinter(address account) internal {\n        _minters.remove(account);\n        emit MinterRemoved(account);\n    }\n}"},"Ownable.sol":{"content":"pragma solidity ^0.5.17;\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\ncontract Ownable {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor () internal {\n        _owner = msg.sender;\n        emit OwnershipTransferred(address(0), _owner);\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(isOwner(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Returns true if the caller is the current owner.\n     */\n    function isOwner() public view returns (bool) {\n        return msg.sender == _owner;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * \u003e Note: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public onlyOwner {\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     */\n    function _transferOwnership(address newOwner) internal {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}"},"Pausable.sol":{"content":"pragma solidity ^0.5.17;\n\nimport \"./PauserRole.sol\";\n\n/**\n * @dev Contract module which allows children to implement an emergency stop\n * mechanism that can be triggered by an authorized account.\n *\n * This module is used through inheritance. It will make available the\n * modifiers `whenNotPaused` and `whenPaused`, which can be applied to\n * the functions of your contract. Note that they will not be pausable by\n * simply including this module, only once the modifiers are put in place.\n */\ncontract Pausable is PauserRole {\n    /**\n     * @dev Emitted when the pause is triggered by a pauser (`account`).\n     */\n    event Paused(address account);\n\n    /**\n     * @dev Emitted when the pause is lifted by a pauser (`account`).\n     */\n    event Unpaused(address account);\n\n    bool private _paused;\n\n    /**\n     * @dev Initializes the contract in unpaused state. Assigns the Pauser role\n     * to the deployer.\n     */\n    constructor () internal {\n        _paused = false;\n    }\n\n    /**\n     * @dev Returns true if the contract is paused, and false otherwise.\n     */\n    function paused() public view returns (bool) {\n        return _paused;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is not paused.\n     */\n    modifier whenNotPaused() {\n        require(!_paused, \"Pausable: paused\");\n        _;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is paused.\n     */\n    modifier whenPaused() {\n        require(_paused, \"Pausable: not paused\");\n        _;\n    }\n\n    /**\n     * @dev Called by a pauser to pause, triggers stopped state.\n     */\n    function pause() public onlyPauser whenNotPaused {\n        _paused = true;\n        emit Paused(msg.sender);\n    }\n\n    /**\n     * @dev Called by a pauser to unpause, returns to normal state.\n     */\n    function unpause() public onlyPauser whenPaused {\n        _paused = false;\n        emit Unpaused(msg.sender);\n    }\n}"},"PauserRole.sol":{"content":"pragma solidity ^0.5.17;\n\nimport \"./Roles.sol\";\n\ncontract PauserRole {\n    using Roles for Roles.Role;\n\n    event PauserAdded(address indexed account);\n    event PauserRemoved(address indexed account);\n\n    Roles.Role private _pausers;\n\n    constructor () internal {\n        _addPauser(msg.sender);\n    }\n\n    modifier onlyPauser() {\n        require(isPauser(msg.sender), \"PauserRole: caller does not have the Pauser role\");\n        _;\n    }\n\n    function isPauser(address account) public view returns (bool) {\n        return _pausers.has(account);\n    }\n\n    function addPauser(address account) public onlyPauser {\n        _addPauser(account);\n    }\n\n    function renouncePauser() public {\n        _removePauser(msg.sender);\n    }\n\n    function _addPauser(address account) internal {\n        _pausers.add(account);\n        emit PauserAdded(account);\n    }\n\n    function _removePauser(address account) internal {\n        _pausers.remove(account);\n        emit PauserRemoved(account);\n    }\n}"},"Roles.sol":{"content":"pragma solidity ^0.5.17;\n\n/**\n * @title Roles\n * @dev Library for managing addresses assigned to a Role.\n */\nlibrary Roles {\n    struct Role {\n        mapping (address =\u003e bool) bearer;\n    }\n\n    /**\n     * @dev Give an account access to this role.\n     */\n    function add(Role storage role, address account) internal {\n        require(!has(role, account), \"Roles: account already has role\");\n        role.bearer[account] = true;\n    }\n\n    /**\n     * @dev Remove an account\u0027s access to this role.\n     */\n    function remove(Role storage role, address account) internal {\n        require(has(role, account), \"Roles: account does not have role\");\n        role.bearer[account] = false;\n    }\n\n    /**\n     * @dev Check if an account has this role.\n     * @return bool\n     */\n    function has(Role storage role, address account) internal view returns (bool) {\n        require(account != address(0), \"Roles: account is the zero address\");\n        return role.bearer[account];\n    }\n}"},"SafeMath.sol":{"content":"pragma solidity ^0.5.17;\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it\u0027s recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003c= a, \"SafeMath: subtraction overflow\");\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0, \"SafeMath: division by zero\");\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b != 0, \"SafeMath: modulo by zero\");\n        return a % b;\n    }\n}"}}