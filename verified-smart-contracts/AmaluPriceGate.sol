{{
  "language": "Solidity",
  "sources": {
    "AmaluPriceGate.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-only\n\npragma solidity 0.8.9;\n\nimport \"IPriceGate.sol\";\n\ncontract AmaluPriceGate is IPriceGate {\n\n    uint public numGates;\n\n    constructor () {}\n\n    function getCost(uint) override external view returns (uint) {\n        return 0;\n    }\n\n    function passThruGate(uint, address) override external payable {}\n}\n"
    },
    "IPriceGate.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-only\n\npragma solidity 0.8.9;\n\ninterface IPriceGate {\n\n    function getCost(uint) external view returns (uint ethCost);\n\n    function passThruGate(uint, address) external payable;\n}\n"
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