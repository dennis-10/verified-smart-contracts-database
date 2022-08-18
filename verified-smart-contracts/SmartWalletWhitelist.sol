{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 1000000
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
    "contracts/external/SmartWalletChecker.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.7;\n\n/// @notice Interface of the `SmartWalletChecker` contracts of the protocol\ninterface SmartWalletChecker {\n    function check(address) external view returns (bool);\n}\n\n/// @title SmartWalletWhitelist\n/// @author Curve Finance and adapted by Angle Core Team (https://etherscan.io/address/0xca719728ef172d0961768581fdf35cb116e0b7a4#code)\n/// @notice Provides functions to check whether a wallet has been verified or not to own veANGLE\ncontract SmartWalletWhitelist {\n    /// @notice Mapping between addresses and whether they are whitelisted or not\n    mapping(address => bool) public wallets;\n    /// @notice Admin address of the contract\n    address public admin;\n    /// @notice Future admin address of the contract\n    //solhint-disable-next-line\n    address public future_admin;\n    /// @notice Contract which works as this contract and that can whitelist addresses\n    address public checker;\n    /// @notice Future address to become checker\n    //solhint-disable-next-line\n    address public future_checker;\n\n    event ApproveWallet(address indexed _wallet);\n    event RevokeWallet(address indexed _wallet);\n\n    /// @notice Constructor of the contract\n    /// @param _admin Admin address of the contract\n    constructor(address _admin) {\n        require(_admin != address(0), \"0\");\n        admin = _admin;\n    }\n\n    /// @notice Commits to change the admin\n    /// @param _admin New admin of the contract\n    function commitAdmin(address _admin) external {\n        require(msg.sender == admin, \"!admin\");\n        future_admin = _admin;\n    }\n\n    /// @notice Changes the admin to the admin that has been committed\n    function applyAdmin() external {\n        require(msg.sender == admin, \"!admin\");\n        require(future_admin != address(0), \"admin not set\");\n        admin = future_admin;\n    }\n\n    /// @notice Commits to change the checker address\n    /// @param _checker New checker address\n    /// @dev This address can be the zero address in which case there will be no checker\n    function commitSetChecker(address _checker) external {\n        require(msg.sender == admin, \"!admin\");\n        future_checker = _checker;\n    }\n\n    /// @notice Applies the checker previously committed\n    function applySetChecker() external {\n        require(msg.sender == admin, \"!admin\");\n        checker = future_checker;\n    }\n\n    /// @notice Approves a wallet\n    /// @param _wallet Wallet to approve\n    function approveWallet(address _wallet) public {\n        require(msg.sender == admin, \"!admin\");\n        wallets[_wallet] = true;\n\n        emit ApproveWallet(_wallet);\n    }\n\n    /// @notice Revokes a wallet\n    /// @param _wallet Wallet to revoke\n    function revokeWallet(address _wallet) external {\n        require(msg.sender == admin, \"!admin\");\n        wallets[_wallet] = false;\n\n        emit RevokeWallet(_wallet);\n    }\n\n    /// @notice Checks whether a wallet is whitelisted\n    /// @param _wallet Wallet address to check\n    /// @dev This function can also rely on another SmartWalletChecker (a `checker` to see whether the wallet is whitelisted or not)\n    function check(address _wallet) external view returns (bool) {\n        bool _check = wallets[_wallet];\n        if (_check) {\n            return _check;\n        } else {\n            if (checker != address(0)) {\n                return SmartWalletChecker(checker).check(_wallet);\n            }\n        }\n        return false;\n    }\n}\n"
    }
  }
}}