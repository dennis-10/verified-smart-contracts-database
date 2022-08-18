{{
  "language": "Solidity",
  "sources": {
    "./contracts/pcv/utils/ERC20PCVDepositWrapper.sol": {
      "content": "pragma solidity ^0.8.4;\n\nimport \"../IPCVDepositBalances.sol\";\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\n\n/**\n  @notice a lightweight contract to wrap ERC20 holding PCV contracts\n  @author Fei Protocol\n  When upgrading the PCVDeposit interface, there are many old contracts which do not support it.\n  The main use case for the new interface is to add read methods for the Collateralization Oracle.\n  Most PCVDeposits resistant balance method is simply returning the balance as a pass-through\n  If the PCVDeposit holds FEI it may be considered as protocol FEI\n\n  This wrapper can be used in the CR oracle which reduces the number of contract upgrades and reduces the complexity and risk of the upgrade\n*/\ncontract ERC20PCVDepositWrapper is IPCVDepositBalances {\n    \n    /// @notice the referenced token deposit\n    address public tokenDeposit;\n\n    /// @notice the balance reported in token\n    IERC20 public token;\n\n    /// @notice a flag for whether to report the balance as protocol owned FEI\n    bool public isProtocolFeiDeposit;\n\n    constructor(address _tokenDeposit, IERC20 _token, bool _isProtocolFeiDeposit) {\n        tokenDeposit = _tokenDeposit;\n        token = _token;\n        isProtocolFeiDeposit = _isProtocolFeiDeposit;\n    }\n\n    /// @notice returns total balance of PCV in the Deposit\n    function balance() public view override returns (uint256) {\n        return token.balanceOf(tokenDeposit);\n    }\n\n    /// @notice returns the resistant balance and FEI in the deposit\n    function resistantBalanceAndFei() public view override returns (uint256, uint256) {\n        uint256 resistantBalance = balance();\n        uint256 reistantFei = isProtocolFeiDeposit ? resistantBalance : 0;\n        return (resistantBalance, reistantFei);\n    }\n\n    /// @notice display the related token of the balance reported\n    function balanceReportedIn() public view override returns (address) {\n        return address(token);\n    }\n}"
    },
    "./contracts/pcv/IPCVDepositBalances.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\npragma solidity ^0.8.4;\n\n/// @title a PCV Deposit interface for only balance getters\n/// @author Fei Protocol\ninterface IPCVDepositBalances {\n    \n    // ----------- Getters -----------\n    \n    /// @notice gets the effective balance of \"balanceReportedIn\" token if the deposit were fully withdrawn\n    function balance() external view returns (uint256);\n\n    /// @notice gets the token address in which this deposit returns its balance\n    function balanceReportedIn() external view returns (address);\n\n    /// @notice gets the resistant token balance and protocol owned fei of this deposit\n    function resistantBalanceAndFei() external view returns (uint256, uint256);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
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