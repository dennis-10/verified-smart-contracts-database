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
    "contracts/persistent/protocol-fee-reserve/ProtocolFeeReserveProxy.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"./utils/ProtocolFeeProxyConstants.sol\";\nimport \"./utils/ProxiableProtocolFeeReserveLib.sol\";\n\n/// @title ProtocolFeeReserveProxy Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice A proxy contract for a protocol fee reserve, slightly modified from EIP-1822\n/// @dev Adapted from the recommended implementation of a Proxy in EIP-1822, updated for solc 0.6.12,\n/// and using the EIP-1967 storage slot for the proxiable implementation.\n/// See: https://eips.ethereum.org/EIPS/eip-1822\n/// See: https://eips.ethereum.org/EIPS/eip-1967\ncontract ProtocolFeeReserveProxy is ProtocolFeeProxyConstants {\n    constructor(bytes memory _constructData, address _protocolFeeReserveLib) public {\n        // Validate constants\n        require(\n            EIP_1822_PROXIABLE_UUID == bytes32(keccak256(\"mln.proxiable.protocolFeeReserveLib\")),\n            \"constructor: Invalid EIP_1822_PROXIABLE_UUID\"\n        );\n        require(\n            EIP_1967_SLOT == bytes32(uint256(keccak256(\"eip1967.proxy.implementation\")) - 1),\n            \"constructor: Invalid EIP_1967_SLOT\"\n        );\n\n        require(\n            ProxiableProtocolFeeReserveLib(_protocolFeeReserveLib).proxiableUUID() ==\n                EIP_1822_PROXIABLE_UUID,\n            \"constructor: _protocolFeeReserveLib not compatible\"\n        );\n\n        assembly {\n            sstore(EIP_1967_SLOT, _protocolFeeReserveLib)\n        }\n\n        (bool success, bytes memory returnData) = _protocolFeeReserveLib.delegatecall(\n            _constructData\n        );\n        require(success, string(returnData));\n    }\n\n    fallback() external payable {\n        assembly {\n            let contractLogic := sload(EIP_1967_SLOT)\n            calldatacopy(0x0, 0x0, calldatasize())\n            let success := delegatecall(\n                sub(gas(), 10000),\n                contractLogic,\n                0x0,\n                calldatasize(),\n                0,\n                0\n            )\n            let retSz := returndatasize()\n            returndatacopy(0, 0, retSz)\n            switch success\n                case 0 {\n                    revert(0, retSz)\n                }\n                default {\n                    return(0, retSz)\n                }\n        }\n    }\n}\n"
    },
    "contracts/persistent/protocol-fee-reserve/utils/ProtocolFeeProxyConstants.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\n/// @title ProtocolFeeProxyConstants Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Constant values used in ProtocolFee proxy-related contracts\nabstract contract ProtocolFeeProxyConstants {\n    // `bytes32(keccak256('mln.proxiable.protocolFeeReserveLib'))`\n    bytes32\n        internal constant EIP_1822_PROXIABLE_UUID = 0xbc966524590ce702cc9340e80d86ea9095afa6b8eecbb5d6213f576332239181;\n    // `bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)`\n    bytes32\n        internal constant EIP_1967_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;\n}\n"
    },
    "contracts/persistent/protocol-fee-reserve/utils/ProxiableProtocolFeeReserveLib.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\nimport \"./ProtocolFeeProxyConstants.sol\";\n\npragma solidity 0.6.12;\n\n/// @title ProxiableProtocolFeeReserveLib Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice A contract that defines the upgrade behavior for ProtocolFeeReserveLib instances\n/// @dev The recommended implementation of the target of a proxy according to EIP-1822 and EIP-1967\n/// See: https://eips.ethereum.org/EIPS/eip-1822\n/// See: https://eips.ethereum.org/EIPS/eip-1967\nabstract contract ProxiableProtocolFeeReserveLib is ProtocolFeeProxyConstants {\n    /// @dev Updates the target of the proxy to be the contract at _nextProtocolFeeReserveLib\n    function __updateCodeAddress(address _nextProtocolFeeReserveLib) internal {\n        require(\n            ProxiableProtocolFeeReserveLib(_nextProtocolFeeReserveLib).proxiableUUID() ==\n                bytes32(EIP_1822_PROXIABLE_UUID),\n            \"__updateCodeAddress: _nextProtocolFeeReserveLib not compatible\"\n        );\n        assembly {\n            sstore(EIP_1967_SLOT, _nextProtocolFeeReserveLib)\n        }\n    }\n\n    /// @notice Returns a unique bytes32 hash for ProtocolFeeReserveLib instances\n    /// @return uuid_ The bytes32 hash representing the UUID\n    function proxiableUUID() public pure returns (bytes32 uuid_) {\n        return EIP_1822_PROXIABLE_UUID;\n    }\n}\n"
    }
  }
}}