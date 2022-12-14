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
      "enabled": true,
      "runs": 1000
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
    "contracts/core/interfaces/IACLRegistry.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n// Docgen-SOLC: 0.8.0\n\npragma solidity ^0.8.0;\n\n/**\n * @dev External interface of AccessControl declared to support ERC165 detection.\n */\ninterface IACLRegistry {\n  /**\n   * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`\n   *\n   * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite\n   * {RoleAdminChanged} not being emitted signaling this.\n   *\n   * _Available since v3.1._\n   */\n  event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);\n\n  /**\n   * @dev Emitted when `account` is granted `role`.\n   *\n   * `sender` is the account that originated the contract call, an admin role\n   * bearer except when using {AccessControl-_setupRole}.\n   */\n  event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);\n\n  /**\n   * @dev Emitted when `account` is revoked `role`.\n   *\n   * `sender` is the account that originated the contract call:\n   *   - if using `revokeRole`, it is the admin role bearer\n   *   - if using `renounceRole`, it is the role bearer (i.e. `account`)\n   */\n  event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);\n\n  /**\n   * @dev Returns `true` if `account` has been granted `role`.\n   */\n  function hasRole(bytes32 role, address account) external view returns (bool);\n\n  /**\n   * @dev Returns `true` if `account` has been granted `permission`.\n   */\n  function hasPermission(bytes32 permission, address account) external view returns (bool);\n\n  /**\n   * @dev Returns the admin role that controls `role`. See {grantRole} and\n   * {revokeRole}.\n   *\n   * To change a role's admin, use {AccessControl-_setRoleAdmin}.\n   */\n  function getRoleAdmin(bytes32 role) external view returns (bytes32);\n\n  /**\n   * @dev Grants `role` to `account`.\n   *\n   * If `account` had not been already granted `role`, emits a {RoleGranted}\n   * event.\n   *\n   * Requirements:\n   *\n   * - the caller must have ``role``'s admin role.\n   */\n  function grantRole(bytes32 role, address account) external;\n\n  /**\n   * @dev Revokes `role` from `account`.\n   *\n   * If `account` had been granted `role`, emits a {RoleRevoked} event.\n   *\n   * Requirements:\n   *\n   * - the caller must have ``role``'s admin role.\n   */\n  function revokeRole(bytes32 role, address account) external;\n\n  /**\n   * @dev Revokes `role` from the calling account.\n   *\n   * Roles are often managed via {grantRole} and {revokeRole}: this function's\n   * purpose is to provide a mechanism for accounts to lose their privileges\n   * if they are compromised (such as when a trusted device is misplaced).\n   *\n   * If the calling account had been granted `role`, emits a {RoleRevoked}\n   * event.\n   *\n   * Requirements:\n   *\n   * - the caller must be `account`.\n   */\n  function renounceRole(bytes32 role, address account) external;\n\n  function setRoleAdmin(bytes32 role, bytes32 adminRole) external;\n\n  function grantPermission(bytes32 permission, address account) external;\n\n  function revokePermission(bytes32 permission) external;\n\n  function requireApprovedContractOrEOA(address account) external view;\n\n  function requireRole(bytes32 role, address account) external view;\n\n  function requirePermission(bytes32 permission, address account) external view;\n\n  function isRoleAdmin(bytes32 role, address account) external view;\n}\n"
    },
    "contracts/core/interfaces/IContractRegistry.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n// Docgen-SOLC: 0.8.0\n\npragma solidity ^0.8.0;\n\n/**\n * @dev External interface of ContractRegistry.\n */\ninterface IContractRegistry {\n  function getContract(bytes32 _name) external view returns (address);\n}\n"
    },
    "contracts/core/utils/ContractRegistry.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n// Docgen-SOLC: 0.8.0\n\npragma solidity ^0.8.0;\n\nimport \"../interfaces/IACLRegistry.sol\";\nimport \"../interfaces/IContractRegistry.sol\";\n\n/**\n * @dev This Contract holds reference to all our contracts. Every contract A that needs to interact with another contract B calls this contract\n * to ask for the address of B.\n * This allows us to update addresses in one central point and reduces constructing and management overhead.\n */\ncontract ContractRegistry is IContractRegistry {\n  struct Contract {\n    address contractAddress;\n    bytes32 version;\n  }\n\n  /* ========== STATE VARIABLES ========== */\n\n  IACLRegistry public aclRegistry;\n\n  mapping(bytes32 => Contract) public contracts;\n  bytes32[] public contractNames;\n\n  /* ========== EVENTS ========== */\n\n  event ContractAdded(bytes32 _name, address _address, bytes32 _version);\n  event ContractUpdated(bytes32 _name, address _address, bytes32 _version);\n  event ContractDeleted(bytes32 _name);\n\n  /* ========== CONSTRUCTOR ========== */\n\n  constructor(IACLRegistry _aclRegistry) {\n    aclRegistry = _aclRegistry;\n    contracts[keccak256(\"ACLRegistry\")] = Contract({contractAddress: address(_aclRegistry), version: keccak256(\"1\")});\n    contractNames.push(keccak256(\"ACLRegistry\"));\n  }\n\n  /* ========== VIEW FUNCTIONS ========== */\n\n  function getContractNames() external view returns (bytes32[] memory) {\n    return contractNames;\n  }\n\n  function getContract(bytes32 _name) external view override returns (address) {\n    return contracts[_name].contractAddress;\n  }\n\n  /* ========== MUTATIVE FUNCTIONS ========== */\n\n  function addContract(\n    bytes32 _name,\n    address _address,\n    bytes32 _version\n  ) external {\n    aclRegistry.requireRole(keccak256(\"DAO\"), msg.sender);\n    require(contracts[_name].contractAddress == address(0), \"contract already exists\");\n    contracts[_name] = Contract({contractAddress: _address, version: _version});\n    contractNames.push(_name);\n    emit ContractAdded(_name, _address, _version);\n  }\n\n  function updateContract(\n    bytes32 _name,\n    address _newAddress,\n    bytes32 _version\n  ) external {\n    aclRegistry.requireRole(keccak256(\"DAO\"), msg.sender);\n    require(contracts[_name].contractAddress != address(0), \"contract doesnt exist\");\n    contracts[_name] = Contract({contractAddress: _newAddress, version: _version});\n    emit ContractUpdated(_name, _newAddress, _version);\n  }\n\n  function deleteContract(bytes32 _name, uint256 _contractIndex) external {\n    aclRegistry.requireRole(keccak256(\"DAO\"), msg.sender);\n    require(contracts[_name].contractAddress != address(0), \"contract doesnt exist\");\n    require(contractNames[_contractIndex] == _name, \"this is not the contract you are looking for\");\n    delete contracts[_name];\n    delete contractNames[_contractIndex];\n    emit ContractDeleted(_name);\n  }\n}\n"
    }
  }
}}