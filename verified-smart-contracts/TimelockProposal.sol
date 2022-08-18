{{
  "language": "Solidity",
  "sources": {
    "TimelockProposal.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity 0.8.6;\n\ninterface IProxy {\n  function upgradeTo(address newImplementation) external;\n}\n\ncontract TimelockProposal {\n\n  function execute() external {\n\n    IProxy proxy = IProxy(0xc4347dbda0078d18073584602CF0C1572541bb15);\n\n    address veToken = 0x1d74408fc603B9b130535d7cF2009B6809E042Ff;\n\n    proxy.upgradeTo(veToken);\n  }\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
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
  }
}}