{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "details": {
        "constantOptimizer": true,
        "cse": true,
        "deduplicate": true,
        "jumpdestRemover": true,
        "orderLiterals": true,
        "peephole": true,
        "yul": false
      },
      "runs": 200
    },
    "remappings": [],
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  },
  "sources": {
    "@openzeppelin/contracts/math/SafeMath.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev Wrappers over Solidity's arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it's recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        uint256 c = a + b;\n        if (c < a) return (false, 0);\n        return (true, c);\n    }\n\n    /**\n     * @dev Returns the substraction of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b > a) return (false, 0);\n        return (true, a - b);\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the\n        // benefit is lost if 'b' is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) return (true, 0);\n        uint256 c = a * b;\n        if (c / a != b) return (false, 0);\n        return (true, c);\n    }\n\n    /**\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b == 0) return (false, 0);\n        return (true, a / b);\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b == 0) return (false, 0);\n        return (true, a % b);\n    }\n\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity's `+` operator.\n     *\n     * Requirements:\n     *\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c >= a, \"SafeMath: addition overflow\");\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b <= a, \"SafeMath: subtraction overflow\");\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity's `*` operator.\n     *\n     * Requirements:\n     *\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        if (a == 0) return 0;\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b > 0, \"SafeMath: division by zero\");\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting when dividing by zero.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b > 0, \"SafeMath: modulo by zero\");\n        return a % b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {trySub}.\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b <= a, errorMessage);\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryDiv}.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b > 0, errorMessage);\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting with custom message when dividing by zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryMod}.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b > 0, errorMessage);\n        return a % b;\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/ERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\nimport \"../../utils/Context.sol\";\nimport \"./IERC20.sol\";\nimport \"../../math/SafeMath.sol\";\n\n/**\n * @dev Implementation of the {IERC20} interface.\n *\n * This implementation is agnostic to the way tokens are created. This means\n * that a supply mechanism has to be added in a derived contract using {_mint}.\n * For a generic mechanism see {ERC20PresetMinterPauser}.\n *\n * TIP: For a detailed writeup see our guide\n * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How\n * to implement supply mechanisms].\n *\n * We have followed general OpenZeppelin guidelines: functions revert instead\n * of returning `false` on failure. This behavior is nonetheless conventional\n * and does not conflict with the expectations of ERC20 applications.\n *\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\n * This allows applications to reconstruct the allowance for all accounts just\n * by listening to said events. Other implementations of the EIP may not emit\n * these events, as it isn't required by the specification.\n *\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\n * functions have been added to mitigate the well-known issues around setting\n * allowances. See {IERC20-approve}.\n */\ncontract ERC20 is Context, IERC20 {\n    using SafeMath for uint256;\n\n    mapping (address => uint256) private _balances;\n\n    mapping (address => mapping (address => uint256)) private _allowances;\n\n    uint256 private _totalSupply;\n\n    string private _name;\n    string private _symbol;\n    uint8 private _decimals;\n\n    /**\n     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with\n     * a default value of 18.\n     *\n     * To select a different value for {decimals}, use {_setupDecimals}.\n     *\n     * All three of these values are immutable: they can only be set once during\n     * construction.\n     */\n    constructor (string memory name_, string memory symbol_) public {\n        _name = name_;\n        _symbol = symbol_;\n        _decimals = 18;\n    }\n\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() public view virtual returns (string memory) {\n        return _name;\n    }\n\n    /**\n     * @dev Returns the symbol of the token, usually a shorter version of the\n     * name.\n     */\n    function symbol() public view virtual returns (string memory) {\n        return _symbol;\n    }\n\n    /**\n     * @dev Returns the number of decimals used to get its user representation.\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\n     * be displayed to a user as `5,05` (`505 / 10 ** 2`).\n     *\n     * Tokens usually opt for a value of 18, imitating the relationship between\n     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is\n     * called.\n     *\n     * NOTE: This information is only used for _display_ purposes: it in\n     * no way affects any of the arithmetic of the contract, including\n     * {IERC20-balanceOf} and {IERC20-transfer}.\n     */\n    function decimals() public view virtual returns (uint8) {\n        return _decimals;\n    }\n\n    /**\n     * @dev See {IERC20-totalSupply}.\n     */\n    function totalSupply() public view virtual override returns (uint256) {\n        return _totalSupply;\n    }\n\n    /**\n     * @dev See {IERC20-balanceOf}.\n     */\n    function balanceOf(address account) public view virtual override returns (uint256) {\n        return _balances[account];\n    }\n\n    /**\n     * @dev See {IERC20-transfer}.\n     *\n     * Requirements:\n     *\n     * - `recipient` cannot be the zero address.\n     * - the caller must have a balance of at least `amount`.\n     */\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(_msgSender(), recipient, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-allowance}.\n     */\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n    /**\n     * @dev See {IERC20-approve}.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\n        _approve(_msgSender(), spender, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-transferFrom}.\n     *\n     * Emits an {Approval} event indicating the updated allowance. This is not\n     * required by the EIP. See the note at the beginning of {ERC20}.\n     *\n     * Requirements:\n     *\n     * - `sender` and `recipient` cannot be the zero address.\n     * - `sender` must have a balance of at least `amount`.\n     * - the caller must have allowance for ``sender``'s tokens of at least\n     * `amount`.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(sender, recipient, amount);\n        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, \"ERC20: transfer amount exceeds allowance\"));\n        return true;\n    }\n\n    /**\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));\n        return true;\n    }\n\n    /**\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     * - `spender` must have allowance for the caller of at least\n     * `subtractedValue`.\n     */\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, \"ERC20: decreased allowance below zero\"));\n        return true;\n    }\n\n    /**\n     * @dev Moves tokens `amount` from `sender` to `recipient`.\n     *\n     * This is internal function is equivalent to {transfer}, and can be used to\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\n     *\n     * Emits a {Transfer} event.\n     *\n     * Requirements:\n     *\n     * - `sender` cannot be the zero address.\n     * - `recipient` cannot be the zero address.\n     * - `sender` must have a balance of at least `amount`.\n     */\n    function _transfer(address sender, address recipient, uint256 amount) internal virtual {\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\n\n        _beforeTokenTransfer(sender, recipient, amount);\n\n        _balances[sender] = _balances[sender].sub(amount, \"ERC20: transfer amount exceeds balance\");\n        _balances[recipient] = _balances[recipient].add(amount);\n        emit Transfer(sender, recipient, amount);\n    }\n\n    /** @dev Creates `amount` tokens and assigns them to `account`, increasing\n     * the total supply.\n     *\n     * Emits a {Transfer} event with `from` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `to` cannot be the zero address.\n     */\n    function _mint(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"ERC20: mint to the zero address\");\n\n        _beforeTokenTransfer(address(0), account, amount);\n\n        _totalSupply = _totalSupply.add(amount);\n        _balances[account] = _balances[account].add(amount);\n        emit Transfer(address(0), account, amount);\n    }\n\n    /**\n     * @dev Destroys `amount` tokens from `account`, reducing the\n     * total supply.\n     *\n     * Emits a {Transfer} event with `to` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `account` cannot be the zero address.\n     * - `account` must have at least `amount` tokens.\n     */\n    function _burn(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"ERC20: burn from the zero address\");\n\n        _beforeTokenTransfer(account, address(0), amount);\n\n        _balances[account] = _balances[account].sub(amount, \"ERC20: burn amount exceeds balance\");\n        _totalSupply = _totalSupply.sub(amount);\n        emit Transfer(account, address(0), amount);\n    }\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.\n     *\n     * This internal function is equivalent to `approve`, and can be used to\n     * e.g. set automatic allowances for certain subsystems, etc.\n     *\n     * Emits an {Approval} event.\n     *\n     * Requirements:\n     *\n     * - `owner` cannot be the zero address.\n     * - `spender` cannot be the zero address.\n     */\n    function _approve(address owner, address spender, uint256 amount) internal virtual {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n\n    /**\n     * @dev Sets {decimals} to a value other than the default one of 18.\n     *\n     * WARNING: This function should only be called from the constructor. Most\n     * applications that interact with token contracts will not expect\n     * {decimals} to ever change, and may work incorrectly if it does.\n     */\n    function _setupDecimals(uint8 decimals_) internal virtual {\n        _decimals = decimals_;\n    }\n\n    /**\n     * @dev Hook that is called before any transfer of tokens. This includes\n     * minting and burning.\n     *\n     * Calling conditions:\n     *\n     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens\n     * will be to transferred to `to`.\n     * - when `from` is zero, `amount` tokens will be minted for `to`.\n     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.\n     * - `from` and `to` are never both zero.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with GSN meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address payable) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes memory) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}\n"
    },
    "contracts/release/core/fund-deployer/IFundDeployer.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\n/// @title IFundDeployer Interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface IFundDeployer {\n    function getOwner() external view returns (address);\n\n    function hasReconfigurationRequest(address) external view returns (bool);\n\n    function isAllowedBuySharesOnBehalfCaller(address) external view returns (bool);\n\n    function isAllowedVaultCall(\n        address,\n        bytes4,\n        bytes32\n    ) external view returns (bool);\n}\n"
    },
    "contracts/release/infrastructure/price-feeds/derivatives/IDerivativePriceFeed.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\n/// @title IDerivativePriceFeed Interface\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Simple interface for derivative price source oracle implementations\ninterface IDerivativePriceFeed {\n    function calcUnderlyingValues(address, uint256)\n        external\n        returns (address[] memory, uint256[] memory);\n\n    function isSupportedAsset(address) external view returns (bool);\n}\n"
    },
    "contracts/release/infrastructure/price-feeds/derivatives/feeds/PoolTogetherV4PriceFeed.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"../../../../interfaces/IPoolTogetherV4PrizePool.sol\";\nimport \"../../../../interfaces/IPoolTogetherV4Ticket.sol\";\nimport \"./utils/PeggedDerivativesPriceFeedBase.sol\";\n\n/// @title PoolTogetherV4PriceFeed Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Price source oracle for PoolTogether (v4)\ncontract PoolTogetherV4PriceFeed is PeggedDerivativesPriceFeedBase {\n    constructor(address _fundDeployer) public PeggedDerivativesPriceFeedBase(_fundDeployer) {}\n\n    function __validateDerivative(address _derivative, address _underlying) internal override {\n        super.__validateDerivative(_derivative, _underlying);\n\n        address controller = IPoolTogetherV4Ticket(_derivative).controller();\n        address prizePoolAsset = IPoolTogetherV4PrizePool(controller).getToken();\n\n        require(\n            prizePoolAsset == _underlying,\n            \"__validateDerivative: Invalid ptToken or token provided\"\n        );\n    }\n}\n"
    },
    "contracts/release/infrastructure/price-feeds/derivatives/feeds/utils/PeggedDerivativesPriceFeedBase.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"@openzeppelin/contracts/token/ERC20/ERC20.sol\";\nimport \"../../IDerivativePriceFeed.sol\";\nimport \"./SingleUnderlyingDerivativeRegistryMixin.sol\";\n\n/// @title PeggedDerivativesPriceFeedBase Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Price feed base for multiple derivatives that are pegged 1:1 to their underlyings,\n/// and have the same decimals as their underlying\nabstract contract PeggedDerivativesPriceFeedBase is\n    IDerivativePriceFeed,\n    SingleUnderlyingDerivativeRegistryMixin\n{\n    constructor(address _fundDeployer)\n        public\n        SingleUnderlyingDerivativeRegistryMixin(_fundDeployer)\n    {}\n\n    /// @notice Converts a given amount of a derivative to its underlying asset values\n    /// @param _derivative The derivative to convert\n    /// @param _derivativeAmount The amount of the derivative to convert\n    /// @return underlyings_ The underlying assets for the _derivative\n    /// @return underlyingAmounts_ The amount of each underlying asset for the equivalent derivative amount\n    function calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)\n        external\n        override\n        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)\n    {\n        address underlying = getUnderlyingForDerivative(_derivative);\n        require(underlying != address(0), \"calcUnderlyingValues: Not a supported derivative\");\n\n        underlyings_ = new address[](1);\n        underlyings_[0] = underlying;\n\n        underlyingAmounts_ = new uint256[](1);\n        underlyingAmounts_[0] = _derivativeAmount;\n\n        return (underlyings_, underlyingAmounts_);\n    }\n\n    /// @notice Checks if an asset is supported by the price feed\n    /// @param _asset The asset to check\n    /// @return isSupported_ True if the asset is supported\n    function isSupportedAsset(address _asset) external view override returns (bool isSupported_) {\n        return getUnderlyingForDerivative(_asset) != address(0);\n    }\n\n    /// @dev Provides validation that the derivative and underlying have the same decimals.\n    /// Can be overrode by the inheriting price feed using super() to implement further validation.\n    function __validateDerivative(address _derivative, address _underlying)\n        internal\n        virtual\n        override\n    {\n        require(\n            ERC20(_derivative).decimals() == ERC20(_underlying).decimals(),\n            \"__validateDerivative: Unequal decimals\"\n        );\n    }\n}\n"
    },
    "contracts/release/infrastructure/price-feeds/derivatives/feeds/utils/SingleUnderlyingDerivativeRegistryMixin.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"../../../../../utils/FundDeployerOwnerMixin.sol\";\n\n/// @title SingleUnderlyingDerivativeRegistryMixin Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Mixin for derivative price feeds that handle multiple derivatives\n/// that each have a single underlying asset\nabstract contract SingleUnderlyingDerivativeRegistryMixin is FundDeployerOwnerMixin {\n    event DerivativeAdded(address indexed derivative, address indexed underlying);\n\n    event DerivativeRemoved(address indexed derivative);\n\n    mapping(address => address) private derivativeToUnderlying;\n\n    constructor(address _fundDeployer) public FundDeployerOwnerMixin(_fundDeployer) {}\n\n    /// @notice Adds derivatives with corresponding underlyings to the price feed\n    /// @param _derivatives The derivatives to add\n    /// @param _underlyings The corresponding underlyings to add\n    function addDerivatives(address[] memory _derivatives, address[] memory _underlyings)\n        external\n        virtual\n        onlyFundDeployerOwner\n    {\n        require(_derivatives.length > 0, \"addDerivatives: Empty _derivatives\");\n        require(_derivatives.length == _underlyings.length, \"addDerivatives: Unequal arrays\");\n\n        for (uint256 i; i < _derivatives.length; i++) {\n            require(_derivatives[i] != address(0), \"addDerivatives: Empty derivative\");\n            require(_underlyings[i] != address(0), \"addDerivatives: Empty underlying\");\n            require(\n                getUnderlyingForDerivative(_derivatives[i]) == address(0),\n                \"addDerivatives: Value already set\"\n            );\n\n            __validateDerivative(_derivatives[i], _underlyings[i]);\n\n            derivativeToUnderlying[_derivatives[i]] = _underlyings[i];\n\n            emit DerivativeAdded(_derivatives[i], _underlyings[i]);\n        }\n    }\n\n    /// @notice Removes derivatives from the price feed\n    /// @param _derivatives The derivatives to remove\n    function removeDerivatives(address[] memory _derivatives) external onlyFundDeployerOwner {\n        require(_derivatives.length > 0, \"removeDerivatives: Empty _derivatives\");\n\n        for (uint256 i; i < _derivatives.length; i++) {\n            require(\n                getUnderlyingForDerivative(_derivatives[i]) != address(0),\n                \"removeDerivatives: Value not set\"\n            );\n\n            delete derivativeToUnderlying[_derivatives[i]];\n\n            emit DerivativeRemoved(_derivatives[i]);\n        }\n    }\n\n    /// @dev Optionally allow the inheriting price feed to validate the derivative-underlying pair\n    function __validateDerivative(address, address) internal virtual {\n        // UNIMPLEMENTED\n    }\n\n    ///////////////////\n    // STATE GETTERS //\n    ///////////////////\n\n    /// @notice Gets the underlying asset for a given derivative\n    /// @param _derivative The derivative for which to get the underlying asset\n    /// @return underlying_ The underlying asset\n    function getUnderlyingForDerivative(address _derivative)\n        public\n        view\n        returns (address underlying_)\n    {\n        return derivativeToUnderlying[_derivative];\n    }\n}\n"
    },
    "contracts/release/interfaces/IPoolTogetherV4PrizePool.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\n/// @title IPoolTogetherV4PrizePool interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface IPoolTogetherV4PrizePool {\n    function getToken() external view returns (address);\n\n    function depositToAndDelegate(\n        address,\n        uint256,\n        address\n    ) external;\n\n    function withdrawFrom(address, uint256) external returns (uint256);\n}\n"
    },
    "contracts/release/interfaces/IPoolTogetherV4Ticket.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity ^0.6.12;\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\n\n/// @title IPoolTogetherV4Ticket Interface\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Minimal interface for interactions with PoolTogether tokens (ptTokens)\ninterface IPoolTogetherV4Ticket is IERC20 {\n    function controller() external view returns (address);\n}\n"
    },
    "contracts/release/utils/FundDeployerOwnerMixin.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"../core/fund-deployer/IFundDeployer.sol\";\n\n/// @title FundDeployerOwnerMixin Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice A mixin contract that defers ownership to the owner of FundDeployer\nabstract contract FundDeployerOwnerMixin {\n    address internal immutable FUND_DEPLOYER;\n\n    modifier onlyFundDeployerOwner() {\n        require(\n            msg.sender == getOwner(),\n            \"onlyFundDeployerOwner: Only the FundDeployer owner can call this function\"\n        );\n        _;\n    }\n\n    constructor(address _fundDeployer) public {\n        FUND_DEPLOYER = _fundDeployer;\n    }\n\n    /// @notice Gets the owner of this contract\n    /// @return owner_ The owner\n    /// @dev Ownership is deferred to the owner of the FundDeployer contract\n    function getOwner() public view returns (address owner_) {\n        return IFundDeployer(FUND_DEPLOYER).getOwner();\n    }\n\n    ///////////////////\n    // STATE GETTERS //\n    ///////////////////\n\n    /// @notice Gets the `FUND_DEPLOYER` variable\n    /// @return fundDeployer_ The `FUND_DEPLOYER` variable value\n    function getFundDeployer() public view returns (address fundDeployer_) {\n        return FUND_DEPLOYER;\n    }\n}\n"
    }
  }
}}