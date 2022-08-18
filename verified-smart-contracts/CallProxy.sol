{"BlockDirectCall.sol":{"content":"/*\n  Copyright 2019-2022 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\n/*\n  This contract provides means to block direct call of an external function.\n  A derived contract (e.g. MainDispatcherBase) should decorate sensitive functions with the\n  notCalledDirectly modifier, thereby preventing it from being called directly, and allowing only calling\n  using delegate_call.\n\n  This Guard contract uses pseudo-random slot, So each deployed contract would have its own guard.\n*/\nabstract contract BlockDirectCall {\n    bytes32 immutable UNIQUE_SAFEGUARD_SLOT; // NOLINT naming-convention.\n\n    constructor() internal {\n        // The slot is pseudo-random to allow hierarchy of contracts with guarded functions.\n        bytes32 slot = keccak256(abi.encode(this, block.timestamp, gasleft()));\n        UNIQUE_SAFEGUARD_SLOT = slot;\n        assembly {\n            sstore(slot, 42)\n        }\n    }\n\n    modifier notCalledDirectly() {\n        {\n            // Prevent too many local variables in stack.\n            uint256 safeGuardValue;\n            bytes32 slot = UNIQUE_SAFEGUARD_SLOT;\n            assembly {\n                safeGuardValue := sload(slot)\n            }\n            require(safeGuardValue == 0, \"DIRECT_CALL_DISALLOWED\");\n        }\n        _;\n    }\n}\n"},"CallProxy.sol":{"content":"/*\n  Copyright 2019-2022 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\nimport \"IFactRegistry.sol\";\nimport \"StorageSlots.sol\";\nimport \"BlockDirectCall.sol\";\nimport \"Common.sol\";\n\n/**\n  CallProxy is a \u0027call\u0027 based proxy.\n  It is a facade to a real implementation,\n  only that unlike the Proxy pattern, it uses call and not delegatecall,\n  so that the state is recorded on the called contract.\n\n  This contract is expected to be placed behind the regular proxy,\n  thus:\n  1. Implementation address is stored in a hashed slot (other than proxy\u0027s one...).\n  2. No state variable is allowed in low address ranges.\n  3. Setting of implementation is done in initialize.\n  4. isFrozen and initialize are implemented, to be compliant with Proxy.\n\n  This implementation is intentionally minimal,\n  and has no management or governance.\n  The assumption is that if a different implementation is needed, it will be performed\n  in an upgradeTo a new deployed CallProxy, pointing to a new implementation.\n*/\n// NOLINTNEXTLINE locked-ether.\ncontract CallProxy is BlockDirectCall, StorageSlots {\n    using Addresses for address;\n\n    string public constant CALL_PROXY_VERSION = \"3.1.0\";\n\n    // Proxy client - initialize \u0026 isFrozen.\n    // NOLINTNEXTLINE: external-function.\n    function isFrozen() public pure returns (bool) {\n        return false;\n    }\n\n    /*\n      This function is called by the Proxy upon activating an implementation.\n      The data passed in to this function contains the implementation address,\n      and if applicable, an address of an EIC (ExternalInitializerContract) and its data.\n\n      The expected data format is as following:\n\n      Case I (no EIC):\n        data.length == 64.\n        [0 :32] implementation address\n        [32:64] Zero address.\n\n      Case II (EIC):\n        data length \u003e= 64\n        [0 :32] implementation address\n        [32:64] EIC address\n        [64:  ] EIC init data.\n    */\n    function initialize(bytes calldata data) external notCalledDirectly {\n        require(data.length \u003e= 64, \"INCORRECT_DATA_SIZE\");\n        (address impl, address eic) = abi.decode(data, (address, address));\n        require(impl.isContract(), \"ADDRESS_NOT_CONTRACT\");\n        setCallProxyImplementation(impl);\n        if (eic != address(0x0)) {\n            callExternalInitializer(eic, data[64:]);\n        } else {\n            require(data.length == 64, \"INVALID_INIT_DATA\");\n        }\n    }\n\n    function callExternalInitializer(address externalInitializerAddr, bytes calldata eicData)\n        private\n    {\n        require(externalInitializerAddr.isContract(), \"EIC_NOT_A_CONTRACT\");\n\n        // NOLINTNEXTLINE: low-level-calls, controlled-delegatecall.\n        (bool success, bytes memory returndata) = externalInitializerAddr.delegatecall(\n            abi.encodeWithSelector(this.initialize.selector, eicData)\n        );\n        require(success, string(returndata));\n        require(returndata.length == 0, string(returndata));\n    }\n\n    /*\n      Returns the call proxy implementation address.\n    */\n    function callProxyImplementation() public view returns (address _implementation) {\n        bytes32 slot = CALL_PROXY_IMPL_SLOT;\n        assembly {\n            _implementation := sload(slot)\n        }\n    }\n\n    /*\n      Sets the call proxy implementation address.\n    */\n    function setCallProxyImplementation(address newImplementation) private {\n        bytes32 slot = CALL_PROXY_IMPL_SLOT;\n        assembly {\n            sstore(slot, newImplementation)\n        }\n    }\n\n    /*\n      An explicit isValid entry point, used to make isValid a part of the ABI and visible\n      on Etherscan (and alike).\n    */\n    function isValid(bytes32 fact) external view returns (bool) {\n        return IFactRegistry(callProxyImplementation()).isValid(fact);\n    }\n\n    /*\n      This entry point serves only transactions with empty calldata. (i.e. pure value transfer tx).\n      We don\u0027t expect to receive such, thus block them.\n    */\n    receive() external payable {\n        revert(\"CONTRACT_NOT_EXPECTED_TO_RECEIVE\");\n    }\n\n    /*\n      Contract\u0027s default function. Pass execution to the implementation contract (using call).\n      It returns back to the external caller whatever the implementation called code returns.\n    */\n    fallback() external payable {\n        // NOLINT locked-ether.\n        address _implementation = callProxyImplementation();\n        require(_implementation != address(0x0), \"MISSING_IMPLEMENTATION\");\n        uint256 value = msg.value;\n        assembly {\n            // Copy msg.data. We take full control of memory in this inline assembly\n            // block because it will not return to Solidity code. We overwrite the\n            // Solidity scratch pad at memory position 0.\n            calldatacopy(0, 0, calldatasize())\n\n            // Call the implementation.\n            // out and outsize are 0 for now, as we don\u0027t know the out size yet.\n            let result := call(gas(), _implementation, value, 0, calldatasize(), 0, 0)\n\n            // Copy the returned data.\n            returndatacopy(0, 0, returndatasize())\n\n            switch result\n            // delegatecall returns 0 on error.\n            case 0 {\n                revert(0, returndatasize())\n            }\n            default {\n                return(0, returndatasize())\n            }\n        }\n    }\n}\n"},"Common.sol":{"content":"/*\n  Copyright 2019-2022 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\n/*\n  Common Utility librarries.\n  I. Addresses (extending address).\n*/\nlibrary Addresses {\n    function isContract(address account) internal view returns (bool) {\n        uint256 size;\n        assembly {\n            size := extcodesize(account)\n        }\n        return size \u003e 0;\n    }\n\n    function performEthTransfer(address recipient, uint256 amount) internal {\n        (bool success, ) = recipient.call{value: amount}(\"\"); // NOLINT: low-level-calls.\n        require(success, \"ETH_TRANSFER_FAILED\");\n    }\n\n    /*\n      Safe wrapper around ERC20/ERC721 calls.\n      This is required because many deployed ERC20 contracts don\u0027t return a value.\n      See https://github.com/ethereum/solidity/issues/4116.\n    */\n    function safeTokenContractCall(address tokenAddress, bytes memory callData) internal {\n        require(isContract(tokenAddress), \"BAD_TOKEN_ADDRESS\");\n        // NOLINTNEXTLINE: low-level-calls.\n        (bool success, bytes memory returndata) = tokenAddress.call(callData);\n        require(success, string(returndata));\n\n        if (returndata.length \u003e 0) {\n            require(abi.decode(returndata, (bool)), \"TOKEN_OPERATION_FAILED\");\n        }\n    }\n\n    /*\n      Validates that the passed contract address is of a real contract,\n      and that its id hash (as infered fromn identify()) matched the expected one.\n    */\n    function validateContractId(address contractAddress, bytes32 expectedIdHash) internal {\n        require(isContract(contractAddress), \"ADDRESS_NOT_CONTRACT\");\n        (bool success, bytes memory returndata) = contractAddress.call( // NOLINT: low-level-calls.\n            abi.encodeWithSignature(\"identify()\")\n        );\n        require(success, \"FAILED_TO_IDENTIFY_CONTRACT\");\n        string memory realContractId = abi.decode(returndata, (string));\n        require(\n            keccak256(abi.encodePacked(realContractId)) == expectedIdHash,\n            \"UNEXPECTED_CONTRACT_IDENTIFIER\"\n        );\n    }\n\n    /*\n      Similar to safeTokenContractCall, but always ignores the return value.\n\n      Assumes some other method is used to detect the failures\n      (e.g. balance is checked before and after the call).\n    */\n    function uncheckedTokenContractCall(address tokenAddress, bytes memory callData) internal {\n        // NOLINTNEXTLINE: low-level-calls.\n        (bool success, bytes memory returndata) = tokenAddress.call(callData);\n        require(success, string(returndata));\n    }\n}\n\n/*\n  II. StarkExTypes - Common data types.\n*/\nlibrary StarkExTypes {\n    // Structure representing a list of verifiers (validity/availability).\n    // A statement is valid only if all the verifiers in the list agree on it.\n    // Adding a verifier to the list is immediate - this is used for fast resolution of\n    // any soundness issues.\n    // Removing from the list is time-locked, to ensure that any user of the system\n    // not content with the announced removal has ample time to leave the system before it is\n    // removed.\n    struct ApprovalChainData {\n        address[] list;\n        // Represents the time after which the verifier with the given address can be removed.\n        // Removal of the verifier with address A is allowed only in the case the value\n        // of unlockedForRemovalTime[A] != 0 and unlockedForRemovalTime[A] \u003c (current time).\n        mapping(address =\u003e uint256) unlockedForRemovalTime;\n    }\n}\n"},"IFactRegistry.sol":{"content":"/*\n  Copyright 2019-2022 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\n/*\n  The Fact Registry design pattern is a way to separate cryptographic verification from the\n  business logic of the contract flow.\n\n  A fact registry holds a hash table of verified \"facts\" which are represented by a hash of claims\n  that the registry hash check and found valid. This table may be queried by accessing the\n  isValid() function of the registry with a given hash.\n\n  In addition, each fact registry exposes a registry specific function for submitting new claims\n  together with their proofs. The information submitted varies from one registry to the other\n  depending of the type of fact requiring verification.\n\n  For further reading on the Fact Registry design pattern see this\n  `StarkWare blog post \u003chttps://medium.com/starkware/the-fact-registry-a64aafb598b6\u003e`_.\n*/\ninterface IFactRegistry {\n    /*\n      Returns true if the given fact was previously registered in the contract.\n    */\n    function isValid(bytes32 fact) external view returns (bool);\n}\n"},"StorageSlots.sol":{"content":"/*\n  Copyright 2019-2022 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\n/**\n  StorageSlots holds the arbitrary storage slots used throughout the Proxy pattern.\n  Storage address slots are a mechanism to define an arbitrary location, that will not be\n  overlapped by the logical contracts.\n*/\ncontract StorageSlots {\n    // Storage slot with the address of the current implementation.\n    // The address of the slot is keccak256(\"StarkWare2019.implemntation-slot\").\n    // We need to keep this variable stored outside of the commonly used space,\n    // so that it\u0027s not overrun by the logical implementation (the proxied contract).\n    bytes32 internal constant IMPLEMENTATION_SLOT =\n        0x177667240aeeea7e35eabe3a35e18306f336219e1386f7710a6bf8783f761b24;\n\n    // Storage slot with the address of the call-proxy current implementation.\n    // The address of the slot is keccak256(\"\u0027StarkWare2020.CallProxy.Implemntation.Slot\u0027\").\n    // We need to keep this variable stored outside of the commonly used space.\n    // so that it\u0027s not overrun by the logical implementation (the proxied contract).\n    bytes32 internal constant CALL_PROXY_IMPL_SLOT =\n        0x7184681641399eb4ad2fdb92114857ee6ff239f94ad635a1779978947b8843be;\n\n    // This storage slot stores the finalization flag.\n    // Once the value stored in this slot is set to non-zero\n    // the proxy blocks implementation upgrades.\n    // The current implementation is then referred to as Finalized.\n    // Web3.solidityKeccak([\u0027string\u0027], [\"StarkWare2019.finalization-flag-slot\"]).\n    bytes32 internal constant FINALIZED_STATE_SLOT =\n        0x7d433c6f837e8f93009937c466c82efbb5ba621fae36886d0cac433c5d0aa7d2;\n\n    // Storage slot to hold the upgrade delay (time-lock).\n    // The intention of this slot is to allow modification using an EIC.\n    // Web3.solidityKeccak([\u0027string\u0027], [\u0027StarkWare.Upgradibility.Delay.Slot\u0027]).\n    bytes32 public constant UPGRADE_DELAY_SLOT =\n        0xc21dbb3089fcb2c4f4c6a67854ab4db2b0f233ea4b21b21f912d52d18fc5db1f;\n}\n"}}