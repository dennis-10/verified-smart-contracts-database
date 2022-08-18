{"Enum.sol":{"content":"// SPDX-License-Identifier: LGPL-3.0-only\npragma solidity \u003e=0.7.0 \u003c0.9.0;\n\ncontract Enum {\n    enum Operation {Call, DelegateCall}\n}\n"},"Executor.sol":{"content":"// SPDX-License-Identifier: LGPL-3.0-only\npragma solidity \u003e=0.7.0 \u003c0.9.0;\nimport \"./Enum.sol\";\n\ncontract Executor {\n    function execute(\n        address to,\n        uint256 value,\n        bytes memory data,\n        Enum.Operation operation,\n        uint256 txGas\n    ) internal returns (bool success) {\n        if (operation == Enum.Operation.DelegateCall) {\n            // solhint-disable-next-line no-inline-assembly\n            assembly {\n                success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)\n            }\n        } else {\n            // solhint-disable-next-line no-inline-assembly\n            assembly {\n                success := call(txGas, to, value, add(data, 0x20), mload(data), 0, 0)\n            }\n        }\n    }\n}\n"},"WalliroSimulateTxAccessor.sol":{"content":"// SPDX-License-Identifier: LGPL-3.0-only\npragma solidity \u003e=0.7.0 \u003c0.9.0;\n\nimport \"./Executor.sol\";\n\ncontract WalliroSimulateTxAccessor is Executor {\n    address private immutable accessorSingleton;\n\n    constructor() {\n        accessorSingleton = address(this);\n    }\n\n    modifier onlyDelegateCall() {\n        require(address(this) != accessorSingleton, \"SimulateTxAccessor should only be called via delegatecall\");\n        _;\n    }\n\n    function simulate(\n        address to,\n        uint256 value,\n        bytes calldata data,\n        Enum.Operation operation\n    )\n        external\n        onlyDelegateCall()\n        returns (\n            uint256 estimate,\n            bool success,\n            bytes memory returnData\n        )\n    {\n        uint256 startGas = gasleft();\n        success = execute(to, value, data, operation, gasleft());\n        estimate = startGas - gasleft();\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            // Load free memory location\n            let ptr := mload(0x40)\n            // We allocate memory for the return data by setting the free memory location to\n            // current free memory location + data size + 32 bytes for data size value\n            mstore(0x40, add(ptr, add(returndatasize(), 0x20)))\n            // Store the size\n            mstore(ptr, returndatasize())\n            // Store the data\n            returndatacopy(add(ptr, 0x20), 0, returndatasize())\n            // Point the return data to the correct memory location\n            returnData := ptr\n        }\n    }\n}\n"}}