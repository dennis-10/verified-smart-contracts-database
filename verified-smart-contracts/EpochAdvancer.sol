{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "berlin",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 2
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
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _setOwner(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _setOwner(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _setOwner(newOwner);\n    }\n\n    function _setOwner(address newOwner) private {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "contracts/EpochAdvancer.sol": {
      "content": "// SPDX-License-Identifier: Apache-2.0\npragma solidity 0.8.6;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"./interfaces/ISmartAlpha.sol\";\n\ncontract EpochAdvancer is Ownable {\n    address[] public pools;\n    uint256 public numberOfPools;\n\n    uint256 public gasPerPool; // on mainnet it should be about 400_000\n\n    constructor(address[] memory addrs, uint256 _gasPerPool){\n        gasPerPool = _gasPerPool;\n        if (addrs.length > 0) {\n            addPools(addrs);\n        }\n    }\n\n    function addPool(address poolAddress) public onlyOwner {\n        require(poolAddress != address(0), \"invalid address\");\n\n        pools.push(poolAddress);\n        numberOfPools++;\n    }\n\n    function removePool(address poolAddress) public onlyOwner {\n        require(poolAddress != address(0), \"invalid address\");\n\n        for (uint256 i = 0; i < numberOfPools; i++) {\n            if (pools[i] == poolAddress) {\n                pools[i] = pools[pools.length - 1];\n                pools.pop();\n                numberOfPools--;\n                return;\n            }\n        }\n    }\n\n    function addPools(address[] memory addrs) public onlyOwner {\n        require(addrs.length > 0, \"invalid array\");\n\n        for (uint256 i = 0; i < addrs.length; i++) {\n            addPool(addrs[i]);\n        }\n    }\n\n    function removePools(address[] memory addrs) public onlyOwner {\n        require(addrs.length > 0, \"invalid array\");\n\n        for (uint256 i = 0; i < addrs.length; i++) {\n            removePool(addrs[i]);\n        }\n    }\n\n    function setGasPerPool(uint256 _newGasPerPool) public onlyOwner {\n        gasPerPool = _newGasPerPool;\n    }\n\n    function advanceEpochs() public {\n        for (uint256 i = 0; i < pools.length; i++) {\n            ISmartAlpha sa = ISmartAlpha(pools[i]);\n\n            if (sa.getCurrentEpoch() > sa.epoch()) {\n                if (gasleft() < gasPerPool) {\n                    break;\n                }\n\n                sa.advanceEpoch();\n            }\n        }\n    }\n\n    function getPools() public view returns (address[] memory) {\n        address[] memory result = new address[](pools.length);\n\n        for (uint256 i = 0; i < pools.length; i++) {\n            result[i] = pools[i];\n        }\n\n        return result;\n    }\n\n    function checkUpkeep(bytes calldata /* checkData */) external view returns (bool, bytes memory) {\n        bool upkeepNeeded;\n\n        for (uint256 i = 0; i < pools.length; i++) {\n            ISmartAlpha sa = ISmartAlpha(pools[i]);\n\n            if (sa.getCurrentEpoch() > sa.epoch()) {\n                upkeepNeeded = true;\n                break;\n            }\n        }\n\n        return (upkeepNeeded, \"\");\n    }\n\n    function performUpkeep(bytes calldata /* performData */) external {\n        advanceEpochs();\n    }\n}\n"
    },
    "contracts/interfaces/ISmartAlpha.sol": {
      "content": "// SPDX-License-Identifier: Apache-2.0\npragma solidity 0.8.6;\n\ninterface ISmartAlpha {\n    function epoch() external view returns (uint256);\n    function getCurrentEpoch() external view returns (uint256);\n    function advanceEpoch() external;\n}\n"
    }
  }
}}