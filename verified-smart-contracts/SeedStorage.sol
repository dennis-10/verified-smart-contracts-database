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
      "enabled": false,
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
    "@openzeppelin/contracts/access/AccessControl.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (access/AccessControl.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IAccessControl.sol\";\nimport \"../utils/Context.sol\";\nimport \"../utils/Strings.sol\";\nimport \"../utils/introspection/ERC165.sol\";\n\n/**\n * @dev Contract module that allows children to implement role-based access\n * control mechanisms. This is a lightweight version that doesn't allow enumerating role\n * members except through off-chain means by accessing the contract event logs. Some\n * applications may benefit from on-chain enumerability, for those cases see\n * {AccessControlEnumerable}.\n *\n * Roles are referred to by their `bytes32` identifier. These should be exposed\n * in the external API and be unique. The best way to achieve this is by\n * using `public constant` hash digests:\n *\n * ```\n * bytes32 public constant MY_ROLE = keccak256(\"MY_ROLE\");\n * ```\n *\n * Roles can be used to represent a set of permissions. To restrict access to a\n * function call, use {hasRole}:\n *\n * ```\n * function foo() public {\n *     require(hasRole(MY_ROLE, msg.sender));\n *     ...\n * }\n * ```\n *\n * Roles can be granted and revoked dynamically via the {grantRole} and\n * {revokeRole} functions. Each role has an associated admin role, and only\n * accounts that have a role's admin role can call {grantRole} and {revokeRole}.\n *\n * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means\n * that only accounts with this role will be able to grant or revoke other\n * roles. More complex role relationships can be created by using\n * {_setRoleAdmin}.\n *\n * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to\n * grant and revoke this role. Extra precautions should be taken to secure\n * accounts that have been granted it.\n */\nabstract contract AccessControl is Context, IAccessControl, ERC165 {\n    struct RoleData {\n        mapping(address => bool) members;\n        bytes32 adminRole;\n    }\n\n    mapping(bytes32 => RoleData) private _roles;\n\n    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;\n\n    /**\n     * @dev Modifier that checks that an account has a specific role. Reverts\n     * with a standardized message including the required role.\n     *\n     * The format of the revert reason is given by the following regular expression:\n     *\n     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/\n     *\n     * _Available since v4.1._\n     */\n    modifier onlyRole(bytes32 role) {\n        _checkRole(role, _msgSender());\n        _;\n    }\n\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);\n    }\n\n    /**\n     * @dev Returns `true` if `account` has been granted `role`.\n     */\n    function hasRole(bytes32 role, address account) public view override returns (bool) {\n        return _roles[role].members[account];\n    }\n\n    /**\n     * @dev Revert with a standard message if `account` is missing `role`.\n     *\n     * The format of the revert reason is given by the following regular expression:\n     *\n     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/\n     */\n    function _checkRole(bytes32 role, address account) internal view {\n        if (!hasRole(role, account)) {\n            revert(\n                string(\n                    abi.encodePacked(\n                        \"AccessControl: account \",\n                        Strings.toHexString(uint160(account), 20),\n                        \" is missing role \",\n                        Strings.toHexString(uint256(role), 32)\n                    )\n                )\n            );\n        }\n    }\n\n    /**\n     * @dev Returns the admin role that controls `role`. See {grantRole} and\n     * {revokeRole}.\n     *\n     * To change a role's admin, use {_setRoleAdmin}.\n     */\n    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {\n        return _roles[role].adminRole;\n    }\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * If `account` had not been already granted `role`, emits a {RoleGranted}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {\n        _grantRole(role, account);\n    }\n\n    /**\n     * @dev Revokes `role` from `account`.\n     *\n     * If `account` had been granted `role`, emits a {RoleRevoked} event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {\n        _revokeRole(role, account);\n    }\n\n    /**\n     * @dev Revokes `role` from the calling account.\n     *\n     * Roles are often managed via {grantRole} and {revokeRole}: this function's\n     * purpose is to provide a mechanism for accounts to lose their privileges\n     * if they are compromised (such as when a trusted device is misplaced).\n     *\n     * If the calling account had been revoked `role`, emits a {RoleRevoked}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must be `account`.\n     */\n    function renounceRole(bytes32 role, address account) public virtual override {\n        require(account == _msgSender(), \"AccessControl: can only renounce roles for self\");\n\n        _revokeRole(role, account);\n    }\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * If `account` had not been already granted `role`, emits a {RoleGranted}\n     * event. Note that unlike {grantRole}, this function doesn't perform any\n     * checks on the calling account.\n     *\n     * [WARNING]\n     * ====\n     * This function should only be called from the constructor when setting\n     * up the initial roles for the system.\n     *\n     * Using this function in any other way is effectively circumventing the admin\n     * system imposed by {AccessControl}.\n     * ====\n     *\n     * NOTE: This function is deprecated in favor of {_grantRole}.\n     */\n    function _setupRole(bytes32 role, address account) internal virtual {\n        _grantRole(role, account);\n    }\n\n    /**\n     * @dev Sets `adminRole` as ``role``'s admin role.\n     *\n     * Emits a {RoleAdminChanged} event.\n     */\n    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {\n        bytes32 previousAdminRole = getRoleAdmin(role);\n        _roles[role].adminRole = adminRole;\n        emit RoleAdminChanged(role, previousAdminRole, adminRole);\n    }\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * Internal function without access restriction.\n     */\n    function _grantRole(bytes32 role, address account) internal virtual {\n        if (!hasRole(role, account)) {\n            _roles[role].members[account] = true;\n            emit RoleGranted(role, account, _msgSender());\n        }\n    }\n\n    /**\n     * @dev Revokes `role` from `account`.\n     *\n     * Internal function without access restriction.\n     */\n    function _revokeRole(bytes32 role, address account) internal virtual {\n        if (hasRole(role, account)) {\n            _roles[role].members[account] = false;\n            emit RoleRevoked(role, account, _msgSender());\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/access/AccessControlEnumerable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (access/AccessControlEnumerable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IAccessControlEnumerable.sol\";\nimport \"./AccessControl.sol\";\nimport \"../utils/structs/EnumerableSet.sol\";\n\n/**\n * @dev Extension of {AccessControl} that allows enumerating the members of each role.\n */\nabstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {\n    using EnumerableSet for EnumerableSet.AddressSet;\n\n    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;\n\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);\n    }\n\n    /**\n     * @dev Returns one of the accounts that have `role`. `index` must be a\n     * value between 0 and {getRoleMemberCount}, non-inclusive.\n     *\n     * Role bearers are not sorted in any particular way, and their ordering may\n     * change at any point.\n     *\n     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure\n     * you perform all queries on the same block. See the following\n     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]\n     * for more information.\n     */\n    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {\n        return _roleMembers[role].at(index);\n    }\n\n    /**\n     * @dev Returns the number of accounts that have `role`. Can be used\n     * together with {getRoleMember} to enumerate all bearers of a role.\n     */\n    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {\n        return _roleMembers[role].length();\n    }\n\n    /**\n     * @dev Overload {_grantRole} to track enumerable memberships\n     */\n    function _grantRole(bytes32 role, address account) internal virtual override {\n        super._grantRole(role, account);\n        _roleMembers[role].add(account);\n    }\n\n    /**\n     * @dev Overload {_revokeRole} to track enumerable memberships\n     */\n    function _revokeRole(bytes32 role, address account) internal virtual override {\n        super._revokeRole(role, account);\n        _roleMembers[role].remove(account);\n    }\n}\n"
    },
    "@openzeppelin/contracts/access/IAccessControl.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (access/IAccessControl.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev External interface of AccessControl declared to support ERC165 detection.\n */\ninterface IAccessControl {\n    /**\n     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`\n     *\n     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite\n     * {RoleAdminChanged} not being emitted signaling this.\n     *\n     * _Available since v3.1._\n     */\n    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);\n\n    /**\n     * @dev Emitted when `account` is granted `role`.\n     *\n     * `sender` is the account that originated the contract call, an admin role\n     * bearer except when using {AccessControl-_setupRole}.\n     */\n    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);\n\n    /**\n     * @dev Emitted when `account` is revoked `role`.\n     *\n     * `sender` is the account that originated the contract call:\n     *   - if using `revokeRole`, it is the admin role bearer\n     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)\n     */\n    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);\n\n    /**\n     * @dev Returns `true` if `account` has been granted `role`.\n     */\n    function hasRole(bytes32 role, address account) external view returns (bool);\n\n    /**\n     * @dev Returns the admin role that controls `role`. See {grantRole} and\n     * {revokeRole}.\n     *\n     * To change a role's admin, use {AccessControl-_setRoleAdmin}.\n     */\n    function getRoleAdmin(bytes32 role) external view returns (bytes32);\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * If `account` had not been already granted `role`, emits a {RoleGranted}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function grantRole(bytes32 role, address account) external;\n\n    /**\n     * @dev Revokes `role` from `account`.\n     *\n     * If `account` had been granted `role`, emits a {RoleRevoked} event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function revokeRole(bytes32 role, address account) external;\n\n    /**\n     * @dev Revokes `role` from the calling account.\n     *\n     * Roles are often managed via {grantRole} and {revokeRole}: this function's\n     * purpose is to provide a mechanism for accounts to lose their privileges\n     * if they are compromised (such as when a trusted device is misplaced).\n     *\n     * If the calling account had been granted `role`, emits a {RoleRevoked}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must be `account`.\n     */\n    function renounceRole(bytes32 role, address account) external;\n}\n"
    },
    "@openzeppelin/contracts/access/IAccessControlEnumerable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (access/IAccessControlEnumerable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IAccessControl.sol\";\n\n/**\n * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.\n */\ninterface IAccessControlEnumerable is IAccessControl {\n    /**\n     * @dev Returns one of the accounts that have `role`. `index` must be a\n     * value between 0 and {getRoleMemberCount}, non-inclusive.\n     *\n     * Role bearers are not sorted in any particular way, and their ordering may\n     * change at any point.\n     *\n     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure\n     * you perform all queries on the same block. See the following\n     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]\n     * for more information.\n     */\n    function getRoleMember(bytes32 role, uint256 index) external view returns (address);\n\n    /**\n     * @dev Returns the number of accounts that have `role`. Can be used\n     * together with {getRoleMember} to enumerate all bearers of a role.\n     */\n    function getRoleMemberCount(bytes32 role) external view returns (uint256);\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Strings.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (utils/Strings.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev String operations.\n */\nlibrary Strings {\n    bytes16 private constant _HEX_SYMBOLS = \"0123456789abcdef\";\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` decimal representation.\n     */\n    function toString(uint256 value) internal pure returns (string memory) {\n        // Inspired by OraclizeAPI's implementation - MIT licence\n        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol\n\n        if (value == 0) {\n            return \"0\";\n        }\n        uint256 temp = value;\n        uint256 digits;\n        while (temp != 0) {\n            digits++;\n            temp /= 10;\n        }\n        bytes memory buffer = new bytes(digits);\n        while (value != 0) {\n            digits -= 1;\n            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));\n            value /= 10;\n        }\n        return string(buffer);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.\n     */\n    function toHexString(uint256 value) internal pure returns (string memory) {\n        if (value == 0) {\n            return \"0x00\";\n        }\n        uint256 temp = value;\n        uint256 length = 0;\n        while (temp != 0) {\n            length++;\n            temp >>= 8;\n        }\n        return toHexString(value, length);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.\n     */\n    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {\n        bytes memory buffer = new bytes(2 * length + 2);\n        buffer[0] = \"0\";\n        buffer[1] = \"x\";\n        for (uint256 i = 2 * length + 1; i > 1; --i) {\n            buffer[i] = _HEX_SYMBOLS[value & 0xf];\n            value >>= 4;\n        }\n        require(value == 0, \"Strings: hex length insufficient\");\n        return string(buffer);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/introspection/ERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (utils/introspection/ERC165.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IERC165.sol\";\n\n/**\n * @dev Implementation of the {IERC165} interface.\n *\n * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check\n * for the additional interface id that will be supported. For example:\n *\n * ```solidity\n * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);\n * }\n * ```\n *\n * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.\n */\nabstract contract ERC165 is IERC165 {\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n        return interfaceId == type(IERC165).interfaceId;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/introspection/IERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC165 standard, as defined in the\n * https://eips.ethereum.org/EIPS/eip-165[EIP].\n *\n * Implementers can declare support of contract interfaces, which can then be\n * queried by others ({ERC165Checker}).\n *\n * For an implementation, see {ERC165}.\n */\ninterface IERC165 {\n    /**\n     * @dev Returns true if this contract implements the interface defined by\n     * `interfaceId`. See the corresponding\n     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]\n     * to learn more about how these ids are created.\n     *\n     * This function call must use less than 30 000 gas.\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"
    },
    "@openzeppelin/contracts/utils/structs/EnumerableSet.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (utils/structs/EnumerableSet.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Library for managing\n * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive\n * types.\n *\n * Sets have the following properties:\n *\n * - Elements are added, removed, and checked for existence in constant time\n * (O(1)).\n * - Elements are enumerated in O(n). No guarantees are made on the ordering.\n *\n * ```\n * contract Example {\n *     // Add the library methods\n *     using EnumerableSet for EnumerableSet.AddressSet;\n *\n *     // Declare a set state variable\n *     EnumerableSet.AddressSet private mySet;\n * }\n * ```\n *\n * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)\n * and `uint256` (`UintSet`) are supported.\n */\nlibrary EnumerableSet {\n    // To implement this library for multiple types with as little code\n    // repetition as possible, we write it in terms of a generic Set type with\n    // bytes32 values.\n    // The Set implementation uses private functions, and user-facing\n    // implementations (such as AddressSet) are just wrappers around the\n    // underlying Set.\n    // This means that we can only create new EnumerableSets for types that fit\n    // in bytes32.\n\n    struct Set {\n        // Storage of set values\n        bytes32[] _values;\n        // Position of the value in the `values` array, plus 1 because index 0\n        // means a value is not in the set.\n        mapping(bytes32 => uint256) _indexes;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function _add(Set storage set, bytes32 value) private returns (bool) {\n        if (!_contains(set, value)) {\n            set._values.push(value);\n            // The value is stored at length-1, but we add 1 to all indexes\n            // and use 0 as a sentinel value\n            set._indexes[value] = set._values.length;\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function _remove(Set storage set, bytes32 value) private returns (bool) {\n        // We read and store the value's index to prevent multiple reads from the same storage slot\n        uint256 valueIndex = set._indexes[value];\n\n        if (valueIndex != 0) {\n            // Equivalent to contains(set, value)\n            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in\n            // the array, and then remove the last element (sometimes called as 'swap and pop').\n            // This modifies the order of the array, as noted in {at}.\n\n            uint256 toDeleteIndex = valueIndex - 1;\n            uint256 lastIndex = set._values.length - 1;\n\n            if (lastIndex != toDeleteIndex) {\n                bytes32 lastvalue = set._values[lastIndex];\n\n                // Move the last value to the index where the value to delete is\n                set._values[toDeleteIndex] = lastvalue;\n                // Update the index for the moved value\n                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex\n            }\n\n            // Delete the slot where the moved value was stored\n            set._values.pop();\n\n            // Delete the index for the deleted slot\n            delete set._indexes[value];\n\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function _contains(Set storage set, bytes32 value) private view returns (bool) {\n        return set._indexes[value] != 0;\n    }\n\n    /**\n     * @dev Returns the number of values on the set. O(1).\n     */\n    function _length(Set storage set) private view returns (uint256) {\n        return set._values.length;\n    }\n\n    /**\n     * @dev Returns the value stored at position `index` in the set. O(1).\n     *\n     * Note that there are no guarantees on the ordering of values inside the\n     * array, and it may change when more values are added or removed.\n     *\n     * Requirements:\n     *\n     * - `index` must be strictly less than {length}.\n     */\n    function _at(Set storage set, uint256 index) private view returns (bytes32) {\n        return set._values[index];\n    }\n\n    /**\n     * @dev Return the entire set in an array\n     *\n     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed\n     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that\n     * this function has an unbounded cost, and using it as part of a state-changing function may render the function\n     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.\n     */\n    function _values(Set storage set) private view returns (bytes32[] memory) {\n        return set._values;\n    }\n\n    // Bytes32Set\n\n    struct Bytes32Set {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {\n        return _add(set._inner, value);\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {\n        return _remove(set._inner, value);\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {\n        return _contains(set._inner, value);\n    }\n\n    /**\n     * @dev Returns the number of values in the set. O(1).\n     */\n    function length(Bytes32Set storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n    /**\n     * @dev Returns the value stored at position `index` in the set. O(1).\n     *\n     * Note that there are no guarantees on the ordering of values inside the\n     * array, and it may change when more values are added or removed.\n     *\n     * Requirements:\n     *\n     * - `index` must be strictly less than {length}.\n     */\n    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {\n        return _at(set._inner, index);\n    }\n\n    /**\n     * @dev Return the entire set in an array\n     *\n     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed\n     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that\n     * this function has an unbounded cost, and using it as part of a state-changing function may render the function\n     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.\n     */\n    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {\n        return _values(set._inner);\n    }\n\n    // AddressSet\n\n    struct AddressSet {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(AddressSet storage set, address value) internal returns (bool) {\n        return _add(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(AddressSet storage set, address value) internal returns (bool) {\n        return _remove(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(AddressSet storage set, address value) internal view returns (bool) {\n        return _contains(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Returns the number of values in the set. O(1).\n     */\n    function length(AddressSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n    /**\n     * @dev Returns the value stored at position `index` in the set. O(1).\n     *\n     * Note that there are no guarantees on the ordering of values inside the\n     * array, and it may change when more values are added or removed.\n     *\n     * Requirements:\n     *\n     * - `index` must be strictly less than {length}.\n     */\n    function at(AddressSet storage set, uint256 index) internal view returns (address) {\n        return address(uint160(uint256(_at(set._inner, index))));\n    }\n\n    /**\n     * @dev Return the entire set in an array\n     *\n     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed\n     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that\n     * this function has an unbounded cost, and using it as part of a state-changing function may render the function\n     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.\n     */\n    function values(AddressSet storage set) internal view returns (address[] memory) {\n        bytes32[] memory store = _values(set._inner);\n        address[] memory result;\n\n        assembly {\n            result := store\n        }\n\n        return result;\n    }\n\n    // UintSet\n\n    struct UintSet {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(UintSet storage set, uint256 value) internal returns (bool) {\n        return _add(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(UintSet storage set, uint256 value) internal returns (bool) {\n        return _remove(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(UintSet storage set, uint256 value) internal view returns (bool) {\n        return _contains(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Returns the number of values on the set. O(1).\n     */\n    function length(UintSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n    /**\n     * @dev Returns the value stored at position `index` in the set. O(1).\n     *\n     * Note that there are no guarantees on the ordering of values inside the\n     * array, and it may change when more values are added or removed.\n     *\n     * Requirements:\n     *\n     * - `index` must be strictly less than {length}.\n     */\n    function at(UintSet storage set, uint256 index) internal view returns (uint256) {\n        return uint256(_at(set._inner, index));\n    }\n\n    /**\n     * @dev Return the entire set in an array\n     *\n     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed\n     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that\n     * this function has an unbounded cost, and using it as part of a state-changing function may render the function\n     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.\n     */\n    function values(UintSet storage set) internal view returns (uint256[] memory) {\n        bytes32[] memory store = _values(set._inner);\n        uint256[] memory result;\n\n        assembly {\n            result := store\n        }\n\n        return result;\n    }\n}\n"
    },
    "contracts/randomness/SeedStorage.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\n/// @title RaidParty Seed Storage\n\n/**\n *   ___      _    _ ___          _\n *  | _ \\__ _(_)__| | _ \\__ _ _ _| |_ _  _\n *  |   / _` | / _` |  _/ _` | '_|  _| || |\n *  |_|_\\__,_|_\\__,_|_| \\__,_|_|  \\__|\\_, |\n *                                    |__/\n */\n\npragma solidity ^0.8.0;\n\nimport \"@openzeppelin/contracts/access/AccessControlEnumerable.sol\";\n\ncontract SeedStorage is AccessControlEnumerable {\n    bytes32 public constant WRITE_ROLE = keccak256(\"WRITE_ROLE\");\n\n    mapping(bytes32 => uint256) private _randomness;\n\n    constructor(address admin) {\n        _setupRole(DEFAULT_ADMIN_ROLE, admin);\n        _setupRole(WRITE_ROLE, admin);\n    }\n\n    function getRandomness(bytes32 key) external view returns (uint256) {\n        return _randomness[key];\n    }\n\n    function setRandomness(bytes32 key, uint256 value)\n        external\n        onlyRole(WRITE_ROLE)\n    {\n        require(\n            _randomness[key] == 0,\n            \"SeedStorage::setRandomness: value already set at id\"\n        );\n        _randomness[key] = value;\n    }\n}\n"
    }
  }
}}