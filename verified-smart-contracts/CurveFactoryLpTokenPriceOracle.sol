{{
  "language": "Solidity",
  "sources": {
    "./contracts/fuse-contracts/contracts/oracles/CurveFactoryLpTokenPriceOracle.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.6.12;\n\nimport \"@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol\";\n\nimport \"../external/compound/CErc20.sol\";\n\nimport \"../external/curve/ICurveFactoryRegistry.sol\";\nimport \"../external/curve/ICurvePool.sol\";\n\nimport \"./BasePriceOracle.sol\";\n\ninterface ERC20Upgradeable {\n    function decimals() external view returns(uint8);\n}\n\n/**\n * @title CurveFactoryLpTokenPriceOracle\n * @author David Lucid <david@rari.capital> (https://github.com/davidlucid)\n * @notice CurveFactoryLpTokenPriceOracle is a price oracle for Curve LP tokens (using the sender as a root oracle).\n * @dev Implements the `PriceOracle` interface used by Fuse pools (and Compound v2).\n */\ncontract CurveFactoryLpTokenPriceOracle is PriceOracle, BasePriceOracle {\n    using SafeMathUpgradeable for uint256;\n\n    /**\n     * @notice Get the LP token price price for an underlying token address.\n     * @param underlying The underlying token address for which to get the price (set to zero address for ETH).\n     * @return Price denominated in ETH (scaled by 1e18).\n     */\n    function price(address underlying) external override view returns (uint) {\n        return _price(underlying);\n    }\n\n    /**\n     * @notice Returns the price in ETH of the token underlying `cToken`.\n     * @dev Implements the `PriceOracle` interface for Fuse pools (and Compound v2).\n     * @return Price in ETH of the token underlying `cToken`, scaled by `10 ** (36 - underlyingDecimals)`.\n     */\n    function getUnderlyingPrice(CToken cToken) external override view returns (uint) {\n        address underlying = CErc20(address(cToken)).underlying();\n        // Comptroller needs prices to be scaled by 1e(36 - decimals)\n        // Since `_price` returns prices scaled by 18 decimals, we must scale them by 1e(36 - 18 - decimals)\n        return _price(underlying).mul(1e18).div(10 ** uint256(ERC20Upgradeable(underlying).decimals()));\n    }\n\n    /**\n     * @dev Fetches the fair LP token/ETH price from Curve, with 18 decimals of precision.\n     * Source: https://github.com/AlphaFinanceLab/homora-v2/blob/master/contracts/oracle/CurveOracle.sol\n     * @param pool pool LP token\n     */\n    function _price(address pool) internal view returns (uint) {\n        address[] memory tokens = underlyingTokens[pool];\n        require(tokens.length != 0, \"LP token is not registered.\");\n        uint256 minPx = uint256(-1);\n        uint256 n = tokens.length;\n\n        for (uint256 i = 0; i < n; i++) {\n            address ulToken = tokens[i];\n            uint256 tokenPx = BasePriceOracle(msg.sender).price(ulToken);\n            if (tokenPx < minPx) minPx = tokenPx;\n        }\n\n        require(minPx != uint256(-1), \"No minimum underlying token price found.\");      \n        return minPx.mul(ICurvePool(pool).get_virtual_price()).div(1e18); // Use min underlying token prices\n    }\n\n    /**\n     * @dev The Curve registry.\n     */\n    ICurveFactoryRegistry public constant registry = ICurveFactoryRegistry(0xB9fC157394Af804a3578134A6585C0dc9cc990d4);\n\n    /**\n     * @dev Maps Curve LP token addresses to underlying token addresses.\n     */\n    mapping(address => address[]) public underlyingTokens;\n\n    /**\n     * @dev Maps Curve LP token addresses to pool addresses.\n     */\n    mapping(address => address) public poolOf;\n\n    /**\n     * @dev Register the pool given LP token address and set the pool info.\n     * Source: https://github.com/AlphaFinanceLab/homora-v2/blob/master/contracts/oracle/CurveOracle.sol\n     * @param pool pool LP token\n     */\n    function registerPool(address pool) external {\n        uint n = registry.get_n_coins(pool);\n        require(n != 0, \"n\");\n        address[4] memory tokens = registry.get_coins(pool);\n        for (uint256 i = 0; i < n; i++) underlyingTokens[pool].push(tokens[i]);\n    }\n}\n"
    },
    "./contracts/fuse-contracts/contracts/external/compound/CErc20.sol": {
      "content": "// SPDX-License-Identifier: BSD-3-Clause\npragma solidity 0.6.12;\n\nimport \"./CToken.sol\";\n\n/**\n * @title Compound's CErc20 Contract\n * @notice CTokens which wrap an EIP-20 underlying\n * @author Compound\n */\ninterface CErc20 is CToken {\n    function underlying() external view returns (address);\n    function liquidateBorrow(address borrower, uint repayAmount, CToken cTokenCollateral) external returns (uint);\n}\n"
    },
    "./contracts/fuse-contracts/contracts/external/compound/CToken.sol": {
      "content": "// SPDX-License-Identifier: BSD-3-Clause\npragma solidity 0.6.12;\n\n/**\n * @title Compound's CToken Contract\n * @notice Abstract base for CTokens\n * @author Compound\n */\ninterface CToken {\n    function admin() external view returns (address);\n    function adminHasRights() external view returns (bool);\n    function fuseAdminHasRights() external view returns (bool);\n    function symbol() external view returns (string memory);\n    function comptroller() external view returns (address);\n    function adminFeeMantissa() external view returns (uint256);\n    function fuseFeeMantissa() external view returns (uint256);\n    function reserveFactorMantissa() external view returns (uint256);\n    function totalReserves() external view returns (uint);\n    function totalAdminFees() external view returns (uint);\n    function totalFuseFees() external view returns (uint);\n\n    function isCToken() external view returns (bool);\n    function isCEther() external view returns (bool);\n\n    function balanceOf(address owner) external view returns (uint);\n    function balanceOfUnderlying(address owner) external returns (uint);\n    function borrowRatePerBlock() external view returns (uint);\n    function supplyRatePerBlock() external view returns (uint);\n    function totalBorrowsCurrent() external returns (uint);\n    function borrowBalanceStored(address account) external view returns (uint);\n    function exchangeRateStored() external view returns (uint);\n    function getCash() external view returns (uint);\n\n    function redeem(uint redeemTokens) external returns (uint);\n    function redeemUnderlying(uint redeemAmount) external returns (uint);\n}\n"
    },
    "./contracts/fuse-contracts/contracts/external/curve/ICurveFactoryRegistry.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.6.12;\n\ninterface ICurveFactoryRegistry {\n    function get_n_coins(address lp) external view returns (uint);\n    function get_coins(address pool) external view returns (address[4] memory);\n}\n"
    },
    "./contracts/fuse-contracts/contracts/external/curve/ICurvePool.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.6.12;\n\ninterface ICurvePool {\n    function get_virtual_price() external view returns (uint);\n    function remove_liquidity_one_coin(uint256 _token_amount, int128 i, uint256 min_amount) external;\n    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256);\n}\n"
    },
    "./contracts/fuse-contracts/contracts/oracles/BasePriceOracle.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.6.12;\n\nimport \"../external/compound/PriceOracle.sol\";\n\n/**\n * @title BasePriceOracle\n * @notice Returns prices of underlying tokens directly without the caller having to specify a cToken address.\n * @dev Implements the `PriceOracle` interface.\n * @author David Lucid <david@rari.capital> (https://github.com/davidlucid)\n */\ninterface BasePriceOracle is PriceOracle {\n    /**\n     * @notice Get the price of an underlying asset.\n     * @param underlying The underlying asset to get the price of.\n     * @return The underlying asset price in ETH as a mantissa (scaled by 1e18).\n     * Zero means the price is unavailable.\n     */\n    function price(address underlying) external view returns (uint);\n}\n"
    },
    "./contracts/fuse-contracts/contracts/external/compound/PriceOracle.sol": {
      "content": "// SPDX-License-Identifier: BSD-3-Clause\npragma solidity 0.6.12;\n\nimport \"./CToken.sol\";\n\ninterface PriceOracle {\n    /**\n      * @notice Get the underlying price of a cToken asset\n      * @param cToken The cToken to get the underlying price of\n      * @return The underlying asset price mantissa (scaled by 1e18).\n      *  Zero means the price is unavailable.\n      */\n    function getUnderlyingPrice(CToken cToken) external view returns (uint);\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev Wrappers over Solidity's arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it's recommended to use it always.\n */\nlibrary SafeMathUpgradeable {\n    /**\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        uint256 c = a + b;\n        if (c < a) return (false, 0);\n        return (true, c);\n    }\n\n    /**\n     * @dev Returns the substraction of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b > a) return (false, 0);\n        return (true, a - b);\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the\n        // benefit is lost if 'b' is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) return (true, 0);\n        uint256 c = a * b;\n        if (c / a != b) return (false, 0);\n        return (true, c);\n    }\n\n    /**\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b == 0) return (false, 0);\n        return (true, a / b);\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b == 0) return (false, 0);\n        return (true, a % b);\n    }\n\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity's `+` operator.\n     *\n     * Requirements:\n     *\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c >= a, \"SafeMath: addition overflow\");\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b <= a, \"SafeMath: subtraction overflow\");\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity's `*` operator.\n     *\n     * Requirements:\n     *\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        if (a == 0) return 0;\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b > 0, \"SafeMath: division by zero\");\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting when dividing by zero.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b > 0, \"SafeMath: modulo by zero\");\n        return a % b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {trySub}.\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b <= a, errorMessage);\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryDiv}.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b > 0, errorMessage);\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting with custom message when dividing by zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryMod}.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b > 0, errorMessage);\n        return a % b;\n    }\n}\n"
    }
  },
  "settings": {
    "metadata": {
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  }
}}