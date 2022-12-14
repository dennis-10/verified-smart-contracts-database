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
      "details": {
        "constantOptimizer": true,
        "cse": true,
        "deduplicate": true,
        "inliner": true,
        "jumpdestRemover": true,
        "orderLiterals": true,
        "peephole": true,
        "yul": true,
        "yulDetails": {
          "optimizerSteps": "dhfoDgvulfnTUtnIf",
          "stackAllocation": true
        }
      },
      "runs": 2000
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
    "contracts/lib/Integers.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\n/**\n * Integers Library updated from https://github.com/willitscale/solidity-util\n *\n * In summary this is a simple library of integer functions which allow a simple\n * conversion to and from strings\n *\n * @author Clement Walter <clement0walter@gmail.com>\n */\nlibrary Integers {\n    /**\n     * To String\n     *\n     * Converts an unsigned integer to the string equivalent value, returned as bytes\n     * Equivalent to javascript's toString(base)\n     *\n     * @param _number The unsigned integer to be converted to a string\n     * @param _base The base to convert the number to\n     * @param  _padding The target length of the string; result will be padded with 0 to reach this length while padding\n     *         of 0 means no padding\n     * @return bytes The resulting ASCII string value\n     */\n    function toString(\n        uint256 _number,\n        uint8 _base,\n        uint8 _padding\n    ) public pure returns (string memory) {\n        uint256 count = 0;\n        uint256 b = _number;\n        while (b != 0) {\n            count++;\n            b /= _base;\n        }\n        if (_number == 0) {\n            count++;\n        }\n        bytes memory res;\n        if (_padding == 0) {\n            res = new bytes(count);\n        } else {\n            res = new bytes(_padding);\n        }\n        for (uint256 i = 0; i < count; ++i) {\n            b = _number % _base;\n            if (b < 10) {\n                res[res.length - i - 1] = bytes1(uint8(b + 48)); // 0-9\n            } else {\n                res[res.length - i - 1] = bytes1(uint8((b % 10) + 65)); // A-F\n            }\n            _number /= _base;\n        }\n\n        for (uint256 i = count; i < _padding; ++i) {\n            res[res.length - i - 1] = hex\"30\"; // 0\n        }\n\n        return string(res);\n    }\n\n    function toString(uint256 _number) public pure returns (string memory) {\n        return toString(_number, 10, 0);\n    }\n\n    function toString(uint256 _number, uint8 _base)\n        public\n        pure\n        returns (string memory)\n    {\n        return toString(_number, _base, 0);\n    }\n\n    /**\n     * Load 16\n     *\n     * Converts two bytes to a 16 bit unsigned integer\n     *\n     * @param _leadingBytes the first byte of the unsigned integer in [256, 65536]\n     * @param _endingBytes the second byte of the unsigned integer in [0, 255]\n     * @return uint16 The resulting integer value\n     */\n    function load16(bytes1 _leadingBytes, bytes1 _endingBytes)\n        public\n        pure\n        returns (uint16)\n    {\n        return\n            (uint16(uint8(_leadingBytes)) << 8) + uint16(uint8(_endingBytes));\n    }\n\n    /**\n     * Load 12\n     *\n     * Converts three bytes into two uint12 integers\n     *\n     * @return (uint16, uint16) The two uint16 values up to 2^12 each\n     */\n    function load12x2(\n        bytes1 first,\n        bytes1 second,\n        bytes1 third\n    ) public pure returns (uint16, uint16) {\n        return (\n            (uint16(uint8(first)) << 4) + (uint16(uint8(second)) >> 4),\n            (uint16(uint8(second & hex\"0f\")) << 8) + uint16(uint8(third))\n        );\n    }\n}\n"
    }
  }
}}