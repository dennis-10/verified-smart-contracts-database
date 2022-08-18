{{
  "language": "Solidity",
  "sources": {
    "./contracts/pcv/utils/PCVDepositWrapper.sol": {
      "content": "pragma solidity ^0.8.4;\n\nimport \"../IPCVDepositBalances.sol\";\n\n/**\n  @notice a lightweight contract to wrap old PCV deposits to use the new interface \n  @author Fei Protocol\n  When upgrading the PCVDeposit interface, there are many old contracts which do not support it.\n  The main use case for the new interface is to add read methods for the Collateralization Oracle.\n  Most PCVDeposits resistant balance method is simply returning the balance as a pass-through\n  If the PCVDeposit holds FEI it may be considered as protocol FEI\n\n  This wrapper can be used in the CR oracle which reduces the number of contract upgrades and reduces the complexity and risk of the upgrade\n*/\ncontract PCVDepositWrapper is IPCVDepositBalances {\n   \n    /// @notice the referenced PCV Deposit\n    IPCVDepositBalances public pcvDeposit;\n\n    /// @notice the balance reported in token\n    address public token;\n\n    /// @notice a flag for whether to report the balance as protocol owned FEI\n    bool public isProtocolFeiDeposit;\n\n    constructor(IPCVDepositBalances _pcvDeposit, address _token, bool _isProtocolFeiDeposit) {\n        pcvDeposit = _pcvDeposit;\n        token = _token;\n        isProtocolFeiDeposit = _isProtocolFeiDeposit;\n    }\n\n    /// @notice returns total balance of PCV in the Deposit\n    function balance() public view override returns (uint256) {\n        return pcvDeposit.balance();\n    }\n\n    /// @notice returns the resistant balance and FEI in the deposit\n    function resistantBalanceAndFei() public view override returns (uint256, uint256) {\n        uint256 resistantBalance = balance();\n        uint256 reistantFei = isProtocolFeiDeposit ? resistantBalance : 0;\n        return (resistantBalance, reistantFei);\n    }\n\n    /// @notice display the related token of the balance reported\n    function balanceReportedIn() public view override returns (address) {\n        return token;\n    }\n}"
    },
    "./contracts/pcv/IPCVDepositBalances.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\npragma solidity ^0.8.4;\n\n/// @title a PCV Deposit interface for only balance getters\n/// @author Fei Protocol\ninterface IPCVDepositBalances {\n    \n    // ----------- Getters -----------\n    \n    /// @notice gets the effective balance of \"balanceReportedIn\" token if the deposit were fully withdrawn\n    function balance() external view returns (uint256);\n\n    /// @notice gets the token address in which this deposit returns its balance\n    function balanceReportedIn() external view returns (address);\n\n    /// @notice gets the resistant token balance and protocol owned fei of this deposit\n    function resistantBalanceAndFei() external view returns (uint256, uint256);\n}\n"
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