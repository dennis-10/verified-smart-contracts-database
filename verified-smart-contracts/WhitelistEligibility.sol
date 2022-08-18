{{
  "language": "Solidity",
  "sources": {
    "WhitelistEligibility.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-only\n\npragma solidity 0.8.9;\n\nimport \"IEligibility.sol\";\n\ncontract WhitelistEligibility is IEligibility {\n\n    struct Gate {\n        address whitelisted;\n        uint maxWithdrawals;\n        uint numWithdrawals;\n    }\n\n    mapping (uint => Gate) public gates;\n    uint public numGates = 0;\n\n    address public gateMaster;\n    address public management;\n    bool public paused;\n\n    modifier managementOnly() {\n        require (msg.sender == management, 'Only management may call this');\n        _;\n    }\n\n    constructor (address _mgmt, address _gateMaster) {\n        gateMaster = _gateMaster;\n        management = _mgmt;\n    }\n\n    // change the management key\n    function setManagement(address newMgmt) external managementOnly {\n        management = newMgmt;\n    }\n\n    function setPaused(bool _paused) external managementOnly {\n        paused = _paused;\n    }\n\n    function addGate(address whitelisted, uint maxWithdrawals) external managementOnly returns (uint) {\n        numGates += 1;\n        Gate storage gate = gates[numGates];\n        gate.whitelisted = whitelisted;\n        gate.maxWithdrawals = maxWithdrawals;\n        return numGates;\n    }\n\n    function getGate(uint index) external view returns (address, uint, uint) {\n        Gate memory gate = gates[index];\n        return (gate.whitelisted, gate.maxWithdrawals, gate.numWithdrawals);\n    }\n\n    function isEligible(uint index, address recipient, bytes32[] memory) public override view returns (bool eligible) {\n        Gate storage gate = gates[index];\n        return !paused && recipient == gate.whitelisted && gate.numWithdrawals < gate.maxWithdrawals;\n    }\n\n    function passThruGate(uint index, address recipient, bytes32[] memory) external override {\n        require(msg.sender == gateMaster, \"Only gatemaster may call this.\");\n        // close re-entrance gate, prevent double withdrawals\n        require(isEligible(index, recipient, new bytes32[](0)), \"Address is not eligible\");\n\n        Gate storage gate = gates[index];\n        gate.numWithdrawals += 1;\n    }\n}\n"
    },
    "IEligibility.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-only\n\npragma solidity 0.8.9;\n\ninterface IEligibility {\n\n//    function getGate(uint) external view returns (struct Gate)\n//    function addGate(uint...) external\n\n    function isEligible(uint, address, bytes32[] memory) external view returns (bool eligible);\n\n    function passThruGate(uint, address, bytes32[] memory) external;\n}\n"
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