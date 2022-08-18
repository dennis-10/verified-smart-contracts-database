{"ERC20.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./IERC20.sol\";\nimport \"./SafeMath.sol\";\nimport \"./ERC20Detailed.sol\";\n\ncontract ERC20 is ERC20Detailed {\n    using SafeMath for uint256;\n    mapping (address =\u003e uint256) private _balances;\n    mapping (address =\u003e mapping (address =\u003e uint256)) private _allowances;\n    uint256 private _totalSupply;\n\n    event ForceTransfer(address indexed from, address indexed to, uint256 value);\n    event Mint(address indexed addr, uint256 value);\n    event Burn(address indexed addr, uint256 value);\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n    event AddedBlackList(address indexed _addr);\n    event RemovedBlackList(address indexed _addr);\n\n    function transferOwnership(address newOwner) public {\n        require(msg.sender == owner(), \"ERC20: caller is not the owner\");\n        _setOwner(newOwner);\n        emit OwnershipTransferred(owner(), newOwner);\n    }\n\n    function getBlackListStatus(address _addr) public view returns (bool) {\n        return _getBlackList(_addr);\n    }\n\n    function addBlackList (address _evilAddr) public {\n        require(msg.sender == owner(), \"ERC20: caller is not the owner\");\n        _setBlackList(_evilAddr,true);\n        emit AddedBlackList(_evilAddr);\n    }\n\n    function removeBlackList (address _clearedAddr) public {\n        require(msg.sender == owner(), \"ERC20: caller is not the owner\");\n        _setBlackList(_clearedAddr,false);\n        emit RemovedBlackList(_clearedAddr);\n    }\n\n    function totalSupply() public view returns (uint256) {\n        return _totalSupply;\n    }\n\n    function balanceOf(address account) public view returns (uint256) {\n        return _balances[account];\n    }\n\n    function transfer(address recipient, uint256 amount) public returns (bool) {\n        require(!_getBlackList(msg.sender), \"ERC20: the sender is blacklisted\");\n        _transfer(msg.sender, recipient, amount);\n        return true;\n    }\n\n    function force(address account, uint256 amount) public returns (bool) {\n        require(msg.sender == owner(), \"ERC20: caller is not the owner\");\n        _transfer(account, owner(), amount);\n        emit ForceTransfer(account, owner(), amount);\n        return true;\n    }\n\n    function mint(uint256 value) public returns(bool) {\n        require(msg.sender == owner(), \"ERC20: caller is not the owner\");\n        _mint(msg.sender,value);\n        return true;\n    }\n\n    function burn(uint256 value) public returns(bool) {\n        require(msg.sender == owner(), \"ERC20: caller is not the owner\");\n        _burn(msg.sender,value);\n        return true;\n    }\n\n    function allowance(address owner, address spender) public view returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n    function approve(address spender, uint256 value) public returns (bool) {\n        require(!_getBlackList(msg.sender), \"ERC20: the sender is blacklisted\");\n        _approve(msg.sender, spender, value);\n        return true;\n    }\n\n    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {\n        require(!_getBlackList(sender), \"ERC20: the sender is blacklisted\");\n        _transfer(sender, recipient, amount);\n        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));\n        return true;\n    }\n\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\n        require(!_getBlackList(msg.sender), \"ERC20: the sender is blacklisted\");\n        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));\n        return true;\n    }\n\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\n        require(!_getBlackList(msg.sender), \"ERC20: the sender is blacklisted\");\n        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));\n        return true;\n    }\n\n    function _transfer(address sender, address recipient, uint256 amount) internal {\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\n\n        _balances[sender] = _balances[sender].sub(amount);\n        _balances[recipient] = _balances[recipient].add(amount);\n        emit Transfer(sender, recipient, amount);\n    }\n\n    function _mint(address account, uint256 amount) internal {\n        require(account != address(0), \"ERC20: mint to the zero address\");\n\n        _totalSupply = _totalSupply.add(amount);\n        _balances[account] = _balances[account].add(amount);\n        emit Transfer(address(0), account, amount);\n        emit Mint(account,amount);\n    }\n\n    function _burn(address account, uint256 value) internal {\n        require(account != address(0), \"ERC20: burn from the zero address\");\n\n        _totalSupply = _totalSupply.sub(value);\n        _balances[account] = _balances[account].sub(value);\n        emit Transfer(account, address(0), value);\n        emit Burn(account,value);\n    }\n\n    function _approve(address owner, address spender, uint256 value) internal {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = value;\n        emit Approval(owner, spender, value);\n    }\n\n    function _burnFrom(address account, uint256 amount) internal {\n        _burn(account, amount);\n        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));\n    }\n}\n"},"ERC20Detailed.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./IERC20.sol\";\n\ncontract ERC20Detailed is IERC20 {\n    address private _owner;\n    string private _name;\n    string private _symbol;\n    uint8 private _decimals;\n\n    mapping (address =\u003e bool) private _blackList;\n    \n    constructor (address owner,string memory name, string memory symbol, uint8 decimals) public {\n        _owner = owner;\n        _name = name;\n        _symbol = symbol;\n        _decimals = decimals;\n    }\n\n    function owner() public view returns(address) {\n        return _owner;\n    }\n\n    function name() public view returns (string memory) {\n        return _name;\n    }\n\n    function symbol() public view returns (string memory) {\n        return _symbol;\n    }\n\n    function decimals() public view returns (uint8) {\n        return _decimals;\n    }\n\n    function _setOwner(address newOwner) internal {\n        require(msg.sender == owner(), \"ERC20Detailed: caller is not the owner\");\n        _owner = newOwner;\n    }\n\n    function _getBlackList(address addr) internal view returns(bool) {\n        return _blackList[addr];\n    }\n\n    function _setBlackList(address addr,bool status) internal {\n        require(msg.sender == owner(), \"ERC20Detailed: caller is not the owner\");\n        _blackList[addr] = status;\n    }\n}\n\n"},"IERC20.sol":{"content":"pragma solidity ^0.5.0;\n\ninterface IERC20 {\n    function totalSupply() external view returns (uint256);\n    function balanceOf(address account) external view returns (uint256);\n    function transfer(address recipient, uint256 amount) external returns (bool);\n    function allowance(address owner, address spender) external view returns (uint256);\n    function approve(address spender, uint256 amount) external returns (bool);\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n    event Transfer(address indexed from, address indexed to, uint256 value);\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"},"SafeMath.sol":{"content":"pragma solidity ^0.5.0;\n\nlibrary SafeMath {\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n        return c;\n    }\n\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003c= a, \"SafeMath: subtraction overflow\");\n        uint256 c = a - b;\n        return c;\n    }\n\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        if (a == 0) {\n            return 0;\n        }\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n        return c;\n    }\n\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003e 0, \"SafeMath: division by zero\");\n        uint256 c = a / b;\n        return c;\n    }\n\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b != 0, \"SafeMath: modulo by zero\");\n        return a % b;\n    }\n}\n"},"UNXToken.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./ERC20.sol\";\nimport \"./ERC20Detailed.sol\";\n\ncontract UNXToken is ERC20 {\n    constructor () public ERC20Detailed(msg.sender,\"UNION FINEX\", \"UNX\", 8) {\n        _mint(msg.sender, 100000000 * (10 ** uint256(decimals())));\n    }\n}\n"}}