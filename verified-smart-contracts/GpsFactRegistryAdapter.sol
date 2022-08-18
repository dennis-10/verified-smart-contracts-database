{"GpsFactRegistryAdapter.sol":{"content":"/*\n  Copyright 2019-2022 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.11;\n\nimport \"Identity.sol\";\nimport \"IQueryableFactRegistry.sol\";\n\n/*\n  The GpsFactRegistryAdapter contract is used as an adapter between a Dapp contract and a GPS fact\n  registry. An isValid(fact) query is answered by querying the GPS contract about\n  new_fact := keccak256(programHash, fact).\n\n  The goal of this contract is to simplify the verifier upgradability logic in the Dapp contract\n  by making the upgrade flow the same regardless of whether the update is to the program hash or\n  the gpsContractAddress.\n*/\ncontract GpsFactRegistryAdapter is IQueryableFactRegistry, Identity {\n    IQueryableFactRegistry public gpsContract;\n    uint256 public programHash;\n\n    constructor(IQueryableFactRegistry gpsStatementContract, uint256 programHash_) public {\n        gpsContract = gpsStatementContract;\n        programHash = programHash_;\n    }\n\n    function identify() external pure virtual override returns (string memory) {\n        return \"StarkWare_GpsFactRegistryAdapter_2020_1\";\n    }\n\n    /*\n      Checks if a fact has been verified.\n    */\n    function isValid(bytes32 fact) external view override returns (bool) {\n        return gpsContract.isValid(keccak256(abi.encode(programHash, fact)));\n    }\n\n    /*\n      Indicates whether at least one fact was registered.\n    */\n    function hasRegisteredFact() external view override returns (bool) {\n        return gpsContract.hasRegisteredFact();\n    }\n}\n"},"Identity.sol":{"content":"/*\n  Copyright 2019-2022 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.11;\n\ninterface Identity {\n    /*\n      Allows a caller, typically another contract,\n      to ensure that the provided address is of the expected type and version.\n    */\n    function identify() external pure returns (string memory);\n}\n"},"IFactRegistry.sol":{"content":"/*\n  Copyright 2019-2022 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.11;\n\n/*\n  The Fact Registry design pattern is a way to separate cryptographic verification from the\n  business logic of the contract flow.\n\n  A fact registry holds a hash table of verified \"facts\" which are represented by a hash of claims\n  that the registry hash check and found valid. This table may be queried by accessing the\n  isValid() function of the registry with a given hash.\n\n  In addition, each fact registry exposes a registry specific function for submitting new claims\n  together with their proofs. The information submitted varies from one registry to the other\n  depending of the type of fact requiring verification.\n\n  For further reading on the Fact Registry design pattern see this\n  `StarkWare blog post \u003chttps://medium.com/starkware/the-fact-registry-a64aafb598b6\u003e`_.\n*/\ninterface IFactRegistry {\n    /*\n      Returns true if the given fact was previously registered in the contract.\n    */\n    function isValid(bytes32 fact) external view returns (bool);\n}\n"},"IQueryableFactRegistry.sol":{"content":"/*\n  Copyright 2019-2022 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.11;\n\nimport \"IFactRegistry.sol\";\n\n/*\n  Extends the IFactRegistry interface with a query method that indicates\n  whether the fact registry has successfully registered any fact or is still empty of such facts.\n*/\ninterface IQueryableFactRegistry is IFactRegistry {\n    /*\n      Returns true if at least one fact has been registered.\n    */\n    function hasRegisteredFact() external view returns (bool);\n}\n"}}