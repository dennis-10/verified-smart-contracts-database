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
    "contracts/bridge/StakingRelayVerifier.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0\npragma solidity ^0.8.2;\n\n\ncontract StakingRelayVerifier {\n    event RelayAddressVerified(uint160 eth_addr, int8 workchain_id, uint256 addr_body);\n\n    function verify_relay_staker_address(int8 workchain_id, uint256 address_body) external {\n        emit RelayAddressVerified(uint160(msg.sender), workchain_id, address_body);\n    }\n}\n"
    }
  }
}}