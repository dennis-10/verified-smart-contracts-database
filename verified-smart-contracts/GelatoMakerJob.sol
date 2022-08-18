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
    "contracts/GelatoMakerJob.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n//solhint-disable compiler-version\npragma solidity 0.8.11;\nimport {GelatoBytes} from \"./gelato/GelatoBytes.sol\";\n\ninterface ISequencer {\n    struct WorkableJob {\n        address job;\n        bool canWork;\n        bytes args;\n    }\n\n    function getNextJobs(\n        bytes32 network,\n        uint256 startIndex,\n        uint256 endIndexExcl\n    ) external returns (WorkableJob[] memory);\n\n    function numJobs() external view returns (uint256);\n}\n\ncontract GelatoMakerJob {\n    using GelatoBytes for bytes;\n\n    address public immutable pokeMe;\n\n    constructor(address _pokeMe) {\n        pokeMe = _pokeMe;\n    }\n\n    //solhint-disable code-complexity\n    //solhint-disable function-max-lines\n    function checker(\n        address _sequencer,\n        bytes32 _network,\n        uint256 _startIndex,\n        uint256 _endIndex\n    ) external returns (bool, bytes memory) {\n        ISequencer sequencer = ISequencer(_sequencer);\n        uint256 numJobs = sequencer.numJobs();\n\n        if (numJobs == 0)\n            return (false, bytes(\"GelatoMakerJob: No jobs listed\"));\n        if (_startIndex >= numJobs) {\n            bytes memory msg1 = bytes.concat(\n                \"GelatoMakerJob: Only jobs available up to index \",\n                _toBytes(numJobs - 1)\n            );\n\n            bytes memory msg2 = bytes.concat(\n                \", inputted startIndex is \",\n                _toBytes(_startIndex)\n            );\n            return (false, bytes.concat(msg1, msg2));\n        }\n\n        uint256 endIndex = _endIndex > numJobs ? numJobs : _endIndex;\n\n        ISequencer.WorkableJob[] memory jobs = ISequencer(_sequencer)\n            .getNextJobs(_network, _startIndex, endIndex);\n\n        uint256 numWorkable;\n        for (uint256 i; i < jobs.length; i++) {\n            if (jobs[i].canWork) numWorkable++;\n        }\n\n        if (numWorkable == 0)\n            return (false, bytes(\"GelatoMakerJob: No workable jobs\"));\n\n        ISequencer.WorkableJob[]\n            memory workableJobs = new ISequencer.WorkableJob[](numWorkable);\n\n        uint256 wIndex;\n        for (uint256 i; i < jobs.length; i++) {\n            if (jobs[i].canWork) {\n                workableJobs[wIndex] = jobs[i];\n                wIndex++;\n            }\n        }\n\n        bytes memory execPayload = abi.encodeWithSelector(\n            this.doJobs.selector,\n            workableJobs\n        );\n\n        return (true, execPayload);\n    }\n\n    function doJobs(ISequencer.WorkableJob[] calldata _jobs) external {\n        require(msg.sender == pokeMe, \"GelatoMakerJob: Only PokeMe\");\n\n        for (uint256 i; i < _jobs.length; i++) {\n            _doJob(_jobs[i].job, _jobs[i].args);\n        }\n    }\n\n    function _doJob(address _job, bytes memory _args) internal {\n        (bool success, bytes memory returnData) = _job.call(_args);\n        if (!success) returnData.revertWithError(\"GelatoMakerJob: \");\n    }\n\n    function _toBytes(uint256 x) private pure returns (bytes memory b) {\n        b = new bytes(32);\n        assembly {\n            mstore(add(b, 32), x)\n        }\n    }\n}\n"
    },
    "contracts/gelato/GelatoBytes.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n//solhint-disable compiler-version\npragma solidity 0.8.11;\n\nlibrary GelatoBytes {\n    function calldataSliceSelector(bytes calldata _bytes)\n        internal\n        pure\n        returns (bytes4 selector)\n    {\n        selector =\n            _bytes[0] |\n            (bytes4(_bytes[1]) >> 8) |\n            (bytes4(_bytes[2]) >> 16) |\n            (bytes4(_bytes[3]) >> 24);\n    }\n\n    function memorySliceSelector(bytes memory _bytes)\n        internal\n        pure\n        returns (bytes4 selector)\n    {\n        selector =\n            _bytes[0] |\n            (bytes4(_bytes[1]) >> 8) |\n            (bytes4(_bytes[2]) >> 16) |\n            (bytes4(_bytes[3]) >> 24);\n    }\n\n    function revertWithError(bytes memory _bytes, string memory _tracingInfo)\n        internal\n        pure\n    {\n        // 68: 32-location, 32-length, 4-ErrorSelector, UTF-8 err\n        if (_bytes.length % 32 == 4) {\n            bytes4 selector;\n            assembly {\n                selector := mload(add(0x20, _bytes))\n            }\n            if (selector == 0x08c379a0) {\n                // Function selector for Error(string)\n                assembly {\n                    _bytes := add(_bytes, 68)\n                }\n                revert(string(abi.encodePacked(_tracingInfo, string(_bytes))));\n            } else {\n                revert(\n                    string(abi.encodePacked(_tracingInfo, \"NoErrorSelector\"))\n                );\n            }\n        } else {\n            revert(\n                string(abi.encodePacked(_tracingInfo, \"UnexpectedReturndata\"))\n            );\n        }\n    }\n\n    function returnError(bytes memory _bytes, string memory _tracingInfo)\n        internal\n        pure\n        returns (string memory)\n    {\n        // 68: 32-location, 32-length, 4-ErrorSelector, UTF-8 err\n        if (_bytes.length % 32 == 4) {\n            bytes4 selector;\n            assembly {\n                selector := mload(add(0x20, _bytes))\n            }\n            if (selector == 0x08c379a0) {\n                // Function selector for Error(string)\n                assembly {\n                    _bytes := add(_bytes, 68)\n                }\n                return string(abi.encodePacked(_tracingInfo, string(_bytes)));\n            } else {\n                return\n                    string(abi.encodePacked(_tracingInfo, \"NoErrorSelector\"));\n            }\n        } else {\n            return\n                string(abi.encodePacked(_tracingInfo, \"UnexpectedReturndata\"));\n        }\n    }\n}\n"
    }
  }
}}