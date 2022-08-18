{{
  "language": "Solidity",
  "sources": {
    "FeeClaimHelper.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\ninterface VE {\n    function claim(address addr) external returns (uint256);\n}\n\ncontract FeeClaimHelper {\n\n    function claim(address[] calldata feeDistributors, address user) external {\n      for (uint i = 0; i < feeDistributors.length; i++) {\n        VE(feeDistributors[i]).claim(user);\n      }\n    }\n\n}\n"
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