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
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "contracts/release/core/fund-deployer/IFundDeployer.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\n/// @title IFundDeployer Interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface IFundDeployer {\n    function getOwner() external view returns (address);\n\n    function hasReconfigurationRequest(address) external view returns (bool);\n\n    function isAllowedBuySharesOnBehalfCaller(address) external view returns (bool);\n\n    function isAllowedVaultCall(\n        address,\n        bytes4,\n        bytes32\n    ) external view returns (bool);\n}\n"
    },
    "contracts/release/infrastructure/price-feeds/derivatives/IDerivativePriceFeed.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\n/// @title IDerivativePriceFeed Interface\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Simple interface for derivative price source oracle implementations\ninterface IDerivativePriceFeed {\n    function calcUnderlyingValues(address, uint256)\n        external\n        returns (address[] memory, uint256[] memory);\n\n    function isSupportedAsset(address) external view returns (bool);\n}\n"
    },
    "contracts/release/infrastructure/price-feeds/derivatives/feeds/IdlePriceFeed.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"@openzeppelin/contracts/math/SafeMath.sol\";\nimport \"../../../../interfaces/IIdleTokenV4.sol\";\nimport \"../IDerivativePriceFeed.sol\";\nimport \"./utils/SingleUnderlyingDerivativeRegistryMixin.sol\";\n\n/// @title IdlePriceFeed Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Price source oracle for IdleTokens\ncontract IdlePriceFeed is IDerivativePriceFeed, SingleUnderlyingDerivativeRegistryMixin {\n    using SafeMath for uint256;\n\n    uint256 private constant IDLE_TOKEN_UNIT = 10**18;\n\n    constructor(address _fundDeployer)\n        public\n        SingleUnderlyingDerivativeRegistryMixin(_fundDeployer)\n    {}\n\n    /// @notice Converts a given amount of a derivative to its underlying asset values\n    /// @param _derivative The derivative to convert\n    /// @param _derivativeAmount The amount of the derivative to convert\n    /// @return underlyings_ The underlying assets for the _derivative\n    /// @return underlyingAmounts_ The amount of each underlying asset for the equivalent derivative amount\n    function calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)\n        external\n        override\n        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)\n    {\n        underlyings_ = new address[](1);\n        underlyings_[0] = getUnderlyingForDerivative(_derivative);\n        require(underlyings_[0] != address(0), \"calcUnderlyingValues: Unsupported derivative\");\n\n        underlyingAmounts_ = new uint256[](1);\n        underlyingAmounts_[0] = _derivativeAmount.mul(IIdleTokenV4(_derivative).tokenPrice()).div(\n            IDLE_TOKEN_UNIT\n        );\n    }\n\n    /// @notice Checks if an asset is supported by the price feed\n    /// @param _asset The asset to check\n    /// @return isSupported_ True if the asset is supported\n    function isSupportedAsset(address _asset) external view override returns (bool isSupported_) {\n        return getUnderlyingForDerivative(_asset) != address(0);\n    }\n\n    /// @dev Helper to validate the derivative-underlying pair.\n    /// Inherited from SingleUnderlyingDerivativeRegistryMixin.\n    function __validateDerivative(address _derivative, address _underlying) internal override {\n        require(\n            IIdleTokenV4(_derivative).token() == _underlying,\n            \"__validateDerivative: Invalid underlying for IdleToken\"\n        );\n    }\n}\n"
    },
    "contracts/release/infrastructure/price-feeds/derivatives/feeds/utils/SingleUnderlyingDerivativeRegistryMixin.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"../../../../../utils/FundDeployerOwnerMixin.sol\";\n\n/// @title SingleUnderlyingDerivativeRegistryMixin Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Mixin for derivative price feeds that handle multiple derivatives\n/// that each have a single underlying asset\nabstract contract SingleUnderlyingDerivativeRegistryMixin is FundDeployerOwnerMixin {\n    event DerivativeAdded(address indexed derivative, address indexed underlying);\n\n    event DerivativeRemoved(address indexed derivative);\n\n    mapping(address => address) private derivativeToUnderlying;\n\n    constructor(address _fundDeployer) public FundDeployerOwnerMixin(_fundDeployer) {}\n\n    /// @notice Adds derivatives with corresponding underlyings to the price feed\n    /// @param _derivatives The derivatives to add\n    /// @param _underlyings The corresponding underlyings to add\n    function addDerivatives(address[] memory _derivatives, address[] memory _underlyings)\n        external\n        virtual\n        onlyFundDeployerOwner\n    {\n        require(_derivatives.length > 0, \"addDerivatives: Empty _derivatives\");\n        require(_derivatives.length == _underlyings.length, \"addDerivatives: Unequal arrays\");\n\n        for (uint256 i; i < _derivatives.length; i++) {\n            require(_derivatives[i] != address(0), \"addDerivatives: Empty derivative\");\n            require(_underlyings[i] != address(0), \"addDerivatives: Empty underlying\");\n            require(\n                getUnderlyingForDerivative(_derivatives[i]) == address(0),\n                \"addDerivatives: Value already set\"\n            );\n\n            __validateDerivative(_derivatives[i], _underlyings[i]);\n\n            derivativeToUnderlying[_derivatives[i]] = _underlyings[i];\n\n            emit DerivativeAdded(_derivatives[i], _underlyings[i]);\n        }\n    }\n\n    /// @notice Removes derivatives from the price feed\n    /// @param _derivatives The derivatives to remove\n    function removeDerivatives(address[] memory _derivatives) external onlyFundDeployerOwner {\n        require(_derivatives.length > 0, \"removeDerivatives: Empty _derivatives\");\n\n        for (uint256 i; i < _derivatives.length; i++) {\n            require(\n                getUnderlyingForDerivative(_derivatives[i]) != address(0),\n                \"removeDerivatives: Value not set\"\n            );\n\n            delete derivativeToUnderlying[_derivatives[i]];\n\n            emit DerivativeRemoved(_derivatives[i]);\n        }\n    }\n\n    /// @dev Optionally allow the inheriting price feed to validate the derivative-underlying pair\n    function __validateDerivative(address, address) internal virtual {\n        // UNIMPLEMENTED\n    }\n\n    ///////////////////\n    // STATE GETTERS //\n    ///////////////////\n\n    /// @notice Gets the underlying asset for a given derivative\n    /// @param _derivative The derivative for which to get the underlying asset\n    /// @return underlying_ The underlying asset\n    function getUnderlyingForDerivative(address _derivative)\n        public\n        view\n        returns (address underlying_)\n    {\n        return derivativeToUnderlying[_derivative];\n    }\n}\n"
    },
    "contracts/release/interfaces/IIdleTokenV4.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\n\n/// @title IIdleTokenV4 Interface\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Minimal interface for our interactions with IdleToken (V4) contracts\ninterface IIdleTokenV4 {\n    function getGovTokensAmounts(address) external view returns (uint256[] calldata);\n\n    function govTokens(uint256) external view returns (address);\n\n    function mintIdleToken(\n        uint256,\n        bool,\n        address\n    ) external returns (uint256);\n\n    function redeemIdleToken(uint256) external returns (uint256);\n\n    function token() external view returns (address);\n\n    function tokenPrice() external view returns (uint256);\n}\n"
    },
    "contracts/release/utils/FundDeployerOwnerMixin.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"../core/fund-deployer/IFundDeployer.sol\";\n\n/// @title FundDeployerOwnerMixin Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice A mixin contract that defers ownership to the owner of FundDeployer\nabstract contract FundDeployerOwnerMixin {\n    address internal immutable FUND_DEPLOYER;\n\n    modifier onlyFundDeployerOwner() {\n        require(\n            msg.sender == getOwner(),\n            \"onlyFundDeployerOwner: Only the FundDeployer owner can call this function\"\n        );\n        _;\n    }\n\n    constructor(address _fundDeployer) public {\n        FUND_DEPLOYER = _fundDeployer;\n    }\n\n    /// @notice Gets the owner of this contract\n    /// @return owner_ The owner\n    /// @dev Ownership is deferred to the owner of the FundDeployer contract\n    function getOwner() public view returns (address owner_) {\n        return IFundDeployer(FUND_DEPLOYER).getOwner();\n    }\n\n    ///////////////////\n    // STATE GETTERS //\n    ///////////////////\n\n    /// @notice Gets the `FUND_DEPLOYER` variable\n    /// @return fundDeployer_ The `FUND_DEPLOYER` variable value\n    function getFundDeployer() public view returns (address fundDeployer_) {\n        return FUND_DEPLOYER;\n    }\n}\n"
    }
  }
}}