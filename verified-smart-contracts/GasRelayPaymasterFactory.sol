{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
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
        "jumpdestRemover": true,
        "orderLiterals": true,
        "peephole": true,
        "yul": false
      },
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
    "contracts/persistent/dispatcher/IDispatcher.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\n/// @title IDispatcher Interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface IDispatcher {\n    function cancelMigration(address _vaultProxy, bool _bypassFailure) external;\n\n    function claimOwnership() external;\n\n    function deployVaultProxy(\n        address _vaultLib,\n        address _owner,\n        address _vaultAccessor,\n        string calldata _fundName\n    ) external returns (address vaultProxy_);\n\n    function executeMigration(address _vaultProxy, bool _bypassFailure) external;\n\n    function getCurrentFundDeployer() external view returns (address currentFundDeployer_);\n\n    function getFundDeployerForVaultProxy(address _vaultProxy)\n        external\n        view\n        returns (address fundDeployer_);\n\n    function getMigrationRequestDetailsForVaultProxy(address _vaultProxy)\n        external\n        view\n        returns (\n            address nextFundDeployer_,\n            address nextVaultAccessor_,\n            address nextVaultLib_,\n            uint256 executableTimestamp_\n        );\n\n    function getMigrationTimelock() external view returns (uint256 migrationTimelock_);\n\n    function getNominatedOwner() external view returns (address nominatedOwner_);\n\n    function getOwner() external view returns (address owner_);\n\n    function getSharesTokenSymbol() external view returns (string memory sharesTokenSymbol_);\n\n    function getTimelockRemainingForMigrationRequest(address _vaultProxy)\n        external\n        view\n        returns (uint256 secondsRemaining_);\n\n    function hasExecutableMigrationRequest(address _vaultProxy)\n        external\n        view\n        returns (bool hasExecutableRequest_);\n\n    function hasMigrationRequest(address _vaultProxy)\n        external\n        view\n        returns (bool hasMigrationRequest_);\n\n    function removeNominatedOwner() external;\n\n    function setCurrentFundDeployer(address _nextFundDeployer) external;\n\n    function setMigrationTimelock(uint256 _nextTimelock) external;\n\n    function setNominatedOwner(address _nextNominatedOwner) external;\n\n    function setSharesTokenSymbol(string calldata _nextSymbol) external;\n\n    function signalMigration(\n        address _vaultProxy,\n        address _nextVaultAccessor,\n        address _nextVaultLib,\n        bool _bypassFailure\n    ) external;\n}\n"
    },
    "contracts/release/infrastructure/gas-relayer/GasRelayPaymasterFactory.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"../../../persistent/dispatcher/IDispatcher.sol\";\nimport \"../../utils/beacon-proxy/BeaconProxyFactory.sol\";\n\n/// @title GasRelayPaymasterFactory Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Factory contract that deploys paymaster proxies for gas relaying\ncontract GasRelayPaymasterFactory is BeaconProxyFactory {\n    address private immutable DISPATCHER;\n\n    constructor(address _dispatcher, address _paymasterLib)\n        public\n        BeaconProxyFactory(_paymasterLib)\n    {\n        DISPATCHER = _dispatcher;\n    }\n\n    /// @notice Gets the contract owner\n    /// @return owner_ The contract owner\n    function getOwner() public view override returns (address owner_) {\n        return IDispatcher(getDispatcher()).getOwner();\n    }\n\n    ///////////////////\n    // STATE GETTERS //\n    ///////////////////\n\n    /// @notice Gets the `DISPATCHER` variable\n    /// @return dispatcher_ The `DISPATCHER` variable value\n    function getDispatcher() public view returns (address dispatcher_) {\n        return DISPATCHER;\n    }\n}\n"
    },
    "contracts/release/utils/beacon-proxy/BeaconProxy.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"./IBeacon.sol\";\n\n/// @title BeaconProxy Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice A proxy contract that uses the beacon pattern for instant upgrades\ncontract BeaconProxy {\n    address private immutable BEACON;\n\n    constructor(bytes memory _constructData, address _beacon) public {\n        BEACON = _beacon;\n\n        (bool success, bytes memory returnData) = IBeacon(_beacon).getCanonicalLib().delegatecall(\n            _constructData\n        );\n        require(success, string(returnData));\n    }\n\n    // solhint-disable-next-line no-complex-fallback\n    fallback() external payable {\n        address contractLogic = IBeacon(BEACON).getCanonicalLib();\n        assembly {\n            calldatacopy(0x0, 0x0, calldatasize())\n            let success := delegatecall(\n                sub(gas(), 10000),\n                contractLogic,\n                0x0,\n                calldatasize(),\n                0,\n                0\n            )\n            let retSz := returndatasize()\n            returndatacopy(0, 0, retSz)\n            switch success\n                case 0 {\n                    revert(0, retSz)\n                }\n                default {\n                    return(0, retSz)\n                }\n        }\n    }\n\n    receive() external payable {}\n}\n"
    },
    "contracts/release/utils/beacon-proxy/BeaconProxyFactory.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"./BeaconProxy.sol\";\nimport \"./IBeaconProxyFactory.sol\";\n\n/// @title BeaconProxyFactory Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Factory contract that deploys beacon proxies\nabstract contract BeaconProxyFactory is IBeaconProxyFactory {\n    event CanonicalLibSet(address nextCanonicalLib);\n\n    event ProxyDeployed(address indexed caller, address proxy, bytes constructData);\n\n    address private canonicalLib;\n\n    constructor(address _canonicalLib) public {\n        __setCanonicalLib(_canonicalLib);\n    }\n\n    /// @notice Deploys a new proxy instance\n    /// @param _constructData The constructor data with which to call `init()` on the deployed proxy\n    /// @return proxy_ The proxy address\n    function deployProxy(bytes memory _constructData) public override returns (address proxy_) {\n        proxy_ = address(new BeaconProxy(_constructData, address(this)));\n\n        emit ProxyDeployed(msg.sender, proxy_, _constructData);\n\n        return proxy_;\n    }\n\n    /// @notice Gets the canonical lib used by all proxies\n    /// @return canonicalLib_ The canonical lib\n    function getCanonicalLib() public view override returns (address canonicalLib_) {\n        return canonicalLib;\n    }\n\n    /// @notice Gets the contract owner\n    /// @return owner_ The contract owner\n    function getOwner() public view virtual returns (address owner_);\n\n    /// @notice Sets the next canonical lib used by all proxies\n    /// @param _nextCanonicalLib The next canonical lib\n    function setCanonicalLib(address _nextCanonicalLib) public override {\n        require(\n            msg.sender == getOwner(),\n            \"setCanonicalLib: Only the owner can call this function\"\n        );\n\n        __setCanonicalLib(_nextCanonicalLib);\n    }\n\n    /// @dev Helper to set the next canonical lib\n    function __setCanonicalLib(address _nextCanonicalLib) internal {\n        canonicalLib = _nextCanonicalLib;\n\n        emit CanonicalLibSet(_nextCanonicalLib);\n    }\n}\n"
    },
    "contracts/release/utils/beacon-proxy/IBeacon.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\n/// @title IBeacon interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface IBeacon {\n    function getCanonicalLib() external view returns (address);\n}\n"
    },
    "contracts/release/utils/beacon-proxy/IBeaconProxyFactory.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\nimport \"./IBeacon.sol\";\n\npragma solidity 0.6.12;\n\n/// @title IBeaconProxyFactory interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface IBeaconProxyFactory is IBeacon {\n    function deployProxy(bytes memory _constructData) external returns (address proxy_);\n\n    function setCanonicalLib(address _canonicalLib) external;\n}\n"
    }
  }
}}