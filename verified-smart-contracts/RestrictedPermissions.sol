{{
  "language": "Solidity",
  "sources": {
    "./contracts/core/RestrictedPermissions.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\npragma solidity ^0.8.4;\n\nimport \"./IPermissionsRead.sol\";\n\n/** \n  @title Restricted Permissions module\n  @author Fei Protocol\n  @notice this contract is used to deprecate certain roles irrevocably on a contract.\n  Particularly, the burner, pcv controller, and governor all revert when called.\n\n  To use, call setCore on the target contract and set to RestrictedPermissions. By revoking the governor, a new Core cannot be set.\n  This enforces that onlyGovernor, onlyBurner, and onlyPCVController actions are irrevocably disabled.\n\n  The mint and guardian rolls pass through to the immutably referenced core contract.\n\n  @dev IMPORTANT: fei() and tribe() calls normally present on Core are not used here, so this contract only works for contracts that don't rely on them.\n*/\ncontract RestrictedPermissions is IPermissionsRead {\n\n    /// @notice passthrough core to reference\n    IPermissionsRead public immutable core;\n\n    constructor(IPermissionsRead _core) {\n        core = _core;\n    }\n\n    /// @notice checks if address is a minter\n    /// @param _address address to check\n    /// @return true _address is a minter\n    function isMinter(address _address) external view override returns (bool) {\n        return core.isMinter(_address);\n    }\n\n    /// @notice checks if address is a guardian\n    /// @param _address address to check\n    /// @return true _address is a guardian\n    function isGuardian(address _address) public view override returns (bool) {\n        return core.isGuardian(_address);\n    }\n\n    // ---------- Deprecated roles for caller ---------\n\n    /// @dev returns false rather than reverting so calls to onlyGuardianOrGovernor don't revert\n    function isGovernor(address) external pure override returns (bool) {\n        return false;\n    }\n\n    function isPCVController(address) external pure override returns (bool) {\n        revert(\"RestrictedPermissions: PCV Controller deprecated for contract\");\n    }\n\n    function isBurner(address) external pure override returns (bool) {\n        revert(\"RestrictedPermissions: Burner deprecated for contract\");\n    }\n}\n"
    },
    "./contracts/core/IPermissionsRead.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\npragma solidity ^0.8.4;\n\n/// @title Permissions Read interface\n/// @author Fei Protocol\ninterface IPermissionsRead {\n    // ----------- Getters -----------\n\n    function isBurner(address _address) external view returns (bool);\n\n    function isMinter(address _address) external view returns (bool);\n\n    function isGovernor(address _address) external view returns (bool);\n\n    function isGuardian(address _address) external view returns (bool);\n\n    function isPCVController(address _address) external view returns (bool);\n}"
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