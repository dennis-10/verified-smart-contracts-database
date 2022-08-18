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
    "contracts/release/extensions/policy-manager/IPolicy.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"./IPolicyManager.sol\";\n\n/// @title Policy Interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface IPolicy {\n    function activateForFund(address _comptrollerProxy) external;\n\n    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings) external;\n\n    function canDisable() external pure returns (bool canDisable_);\n\n    function identifier() external pure returns (string memory identifier_);\n\n    function implementedHooks()\n        external\n        pure\n        returns (IPolicyManager.PolicyHook[] memory implementedHooks_);\n\n    function updateFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)\n        external;\n\n    function validateRule(\n        address _comptrollerProxy,\n        IPolicyManager.PolicyHook _hook,\n        bytes calldata _encodedArgs\n    ) external returns (bool isValid_);\n}\n"
    },
    "contracts/release/extensions/policy-manager/IPolicyManager.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\npragma experimental ABIEncoderV2;\n\n/// @title PolicyManager Interface\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Interface for the PolicyManager\ninterface IPolicyManager {\n    // When updating PolicyHook, also update these functions in PolicyManager:\n    // 1. __getAllPolicyHooks()\n    // 2. __policyHookRestrictsCurrentInvestorActions()\n    enum PolicyHook {\n        PostBuyShares,\n        PostCallOnIntegration,\n        PreTransferShares,\n        RedeemSharesForSpecificAssets,\n        AddTrackedAssets,\n        RemoveTrackedAssets,\n        CreateExternalPosition,\n        PostCallOnExternalPosition,\n        RemoveExternalPosition,\n        ReactivateExternalPosition\n    }\n\n    function validatePolicies(\n        address,\n        PolicyHook,\n        bytes calldata\n    ) external;\n}\n"
    },
    "contracts/release/extensions/policy-manager/policies/new-shareholders/MinMaxInvestmentPolicy.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\npragma experimental ABIEncoderV2;\n\nimport \"../utils/PolicyBase.sol\";\n\n/// @title MinMaxInvestmentPolicy Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice A policy that restricts the amount of the fund's denomination asset that a user can\n/// send in a single call to buy shares in a fund\ncontract MinMaxInvestmentPolicy is PolicyBase {\n    event FundSettingsSet(\n        address indexed comptrollerProxy,\n        uint256 minInvestmentAmount,\n        uint256 maxInvestmentAmount\n    );\n\n    struct FundSettings {\n        uint256 minInvestmentAmount;\n        uint256 maxInvestmentAmount;\n    }\n\n    mapping(address => FundSettings) private comptrollerProxyToFundSettings;\n\n    constructor(address _policyManager) public PolicyBase(_policyManager) {}\n\n    /// @notice Adds the initial policy settings for a fund\n    /// @param _comptrollerProxy The fund's ComptrollerProxy address\n    /// @param _encodedSettings Encoded settings to apply to a fund\n    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)\n        external\n        override\n        onlyPolicyManager\n    {\n        __setFundSettings(_comptrollerProxy, _encodedSettings);\n    }\n\n    /// @notice Whether or not the policy can be disabled\n    /// @return canDisable_ True if the policy can be disabled\n    function canDisable() external pure virtual override returns (bool canDisable_) {\n        return true;\n    }\n\n    /// @notice Provides a constant string identifier for a policy\n    /// @return identifier_ The identifer string\n    function identifier() external pure override returns (string memory identifier_) {\n        return \"MIN_MAX_INVESTMENT\";\n    }\n\n    /// @notice Gets the implemented PolicyHooks for a policy\n    /// @return implementedHooks_ The implemented PolicyHooks\n    function implementedHooks()\n        external\n        pure\n        override\n        returns (IPolicyManager.PolicyHook[] memory implementedHooks_)\n    {\n        implementedHooks_ = new IPolicyManager.PolicyHook[](1);\n        implementedHooks_[0] = IPolicyManager.PolicyHook.PostBuyShares;\n\n        return implementedHooks_;\n    }\n\n    /// @notice Updates the policy settings for a fund\n    /// @param _comptrollerProxy The fund's ComptrollerProxy address\n    /// @param _encodedSettings Encoded settings to apply to a fund\n    function updateFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)\n        external\n        override\n        onlyPolicyManager\n    {\n        __setFundSettings(_comptrollerProxy, _encodedSettings);\n    }\n\n    /// @notice Checks whether a particular condition passes the rule for a particular fund\n    /// @param _comptrollerProxy The fund's ComptrollerProxy address\n    /// @param _investmentAmount The investment amount for which to check the rule\n    /// @return isValid_ True if the rule passes\n    function passesRule(address _comptrollerProxy, uint256 _investmentAmount)\n        public\n        view\n        returns (bool isValid_)\n    {\n        uint256 minInvestmentAmount = comptrollerProxyToFundSettings[_comptrollerProxy]\n            .minInvestmentAmount;\n        uint256 maxInvestmentAmount = comptrollerProxyToFundSettings[_comptrollerProxy]\n            .maxInvestmentAmount;\n\n        // Both minInvestmentAmount and maxInvestmentAmount can be 0 in order to close the fund\n        // temporarily\n        if (minInvestmentAmount == 0) {\n            return _investmentAmount <= maxInvestmentAmount;\n        } else if (maxInvestmentAmount == 0) {\n            return _investmentAmount >= minInvestmentAmount;\n        }\n        return\n            _investmentAmount >= minInvestmentAmount && _investmentAmount <= maxInvestmentAmount;\n    }\n\n    /// @notice Apply the rule with the specified parameters of a PolicyHook\n    /// @param _comptrollerProxy The fund's ComptrollerProxy address\n    /// @param _encodedArgs Encoded args with which to validate the rule\n    /// @return isValid_ True if the rule passes\n    /// @dev onlyPolicyManager validation not necessary, as state is not updated and no events are fired\n    function validateRule(\n        address _comptrollerProxy,\n        IPolicyManager.PolicyHook,\n        bytes calldata _encodedArgs\n    ) external override returns (bool isValid_) {\n        (, uint256 investmentAmount, , ) = __decodePostBuySharesValidationData(_encodedArgs);\n\n        return passesRule(_comptrollerProxy, investmentAmount);\n    }\n\n    /// @dev Helper to set the policy settings for a fund\n    /// @param _comptrollerProxy The fund's ComptrollerProxy address\n    /// @param _encodedSettings Encoded settings to apply to a fund\n    function __setFundSettings(address _comptrollerProxy, bytes memory _encodedSettings) private {\n        (uint256 minInvestmentAmount, uint256 maxInvestmentAmount) = abi.decode(\n            _encodedSettings,\n            (uint256, uint256)\n        );\n\n        require(\n            maxInvestmentAmount == 0 || minInvestmentAmount < maxInvestmentAmount,\n            \"__setFundSettings: minInvestmentAmount must be less than maxInvestmentAmount\"\n        );\n\n        comptrollerProxyToFundSettings[_comptrollerProxy]\n            .minInvestmentAmount = minInvestmentAmount;\n        comptrollerProxyToFundSettings[_comptrollerProxy]\n            .maxInvestmentAmount = maxInvestmentAmount;\n\n        emit FundSettingsSet(_comptrollerProxy, minInvestmentAmount, maxInvestmentAmount);\n    }\n\n    ///////////////////\n    // STATE GETTERS //\n    ///////////////////\n\n    /// @notice Gets the min and max investment amount for a given fund\n    /// @param _comptrollerProxy The ComptrollerProxy of the fund\n    /// @return fundSettings_ The fund settings\n    function getFundSettings(address _comptrollerProxy)\n        external\n        view\n        returns (FundSettings memory fundSettings_)\n    {\n        return comptrollerProxyToFundSettings[_comptrollerProxy];\n    }\n}\n"
    },
    "contracts/release/extensions/policy-manager/policies/utils/PolicyBase.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"../../IPolicy.sol\";\n\n/// @title PolicyBase Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Abstract base contract for all policies\nabstract contract PolicyBase is IPolicy {\n    address internal immutable POLICY_MANAGER;\n\n    modifier onlyPolicyManager {\n        require(msg.sender == POLICY_MANAGER, \"Only the PolicyManager can make this call\");\n        _;\n    }\n\n    constructor(address _policyManager) public {\n        POLICY_MANAGER = _policyManager;\n    }\n\n    /// @notice Validates and initializes a policy as necessary prior to fund activation\n    /// @dev Unimplemented by default, can be overridden by the policy\n    function activateForFund(address) external virtual override {\n        return;\n    }\n\n    /// @notice Whether or not the policy can be disabled\n    /// @return canDisable_ True if the policy can be disabled\n    /// @dev False by default, can be overridden by the policy\n    function canDisable() external pure virtual override returns (bool canDisable_) {\n        return false;\n    }\n\n    /// @notice Updates the policy settings for a fund\n    /// @dev Disallowed by default, can be overridden by the policy\n    function updateFundSettings(address, bytes calldata) external virtual override {\n        revert(\"updateFundSettings: Updates not allowed for this policy\");\n    }\n\n    //////////////////////////////\n    // VALIDATION DATA DECODING //\n    //////////////////////////////\n\n    /// @dev Helper to parse validation arguments from encoded data for AddTrackedAssets policy hook\n    function __decodeAddTrackedAssetsValidationData(bytes memory _validationData)\n        internal\n        pure\n        returns (address caller_, address[] memory assets_)\n    {\n        return abi.decode(_validationData, (address, address[]));\n    }\n\n    /// @dev Helper to parse validation arguments from encoded data for CreateExternalPosition policy hook\n    function __decodeCreateExternalPositionValidationData(bytes memory _validationData)\n        internal\n        pure\n        returns (\n            address caller_,\n            uint256 typeId_,\n            bytes memory initializationData_\n        )\n    {\n        return abi.decode(_validationData, (address, uint256, bytes));\n    }\n\n    /// @dev Helper to parse validation arguments from encoded data for PreTransferShares policy hook\n    function __decodePreTransferSharesValidationData(bytes memory _validationData)\n        internal\n        pure\n        returns (\n            address sender_,\n            address recipient_,\n            uint256 amount_\n        )\n    {\n        return abi.decode(_validationData, (address, address, uint256));\n    }\n\n    /// @dev Helper to parse validation arguments from encoded data for PostBuyShares policy hook\n    function __decodePostBuySharesValidationData(bytes memory _validationData)\n        internal\n        pure\n        returns (\n            address buyer_,\n            uint256 investmentAmount_,\n            uint256 sharesIssued_,\n            uint256 gav_\n        )\n    {\n        return abi.decode(_validationData, (address, uint256, uint256, uint256));\n    }\n\n    /// @dev Helper to parse validation arguments from encoded data for PostCallOnExternalPosition policy hook\n    function __decodePostCallOnExternalPositionValidationData(bytes memory _validationData)\n        internal\n        pure\n        returns (\n            address caller_,\n            address externalPosition_,\n            address[] memory assetsToTransfer_,\n            uint256[] memory amountsToTransfer_,\n            address[] memory assetsToReceive_,\n            bytes memory encodedActionData_\n        )\n    {\n        return\n            abi.decode(\n                _validationData,\n                (address, address, address[], uint256[], address[], bytes)\n            );\n    }\n\n    /// @dev Helper to parse validation arguments from encoded data for PostCallOnIntegration policy hook\n    function __decodePostCallOnIntegrationValidationData(bytes memory _validationData)\n        internal\n        pure\n        returns (\n            address caller_,\n            address adapter_,\n            bytes4 selector_,\n            address[] memory incomingAssets_,\n            uint256[] memory incomingAssetAmounts_,\n            address[] memory spendAssets_,\n            uint256[] memory spendAssetAmounts_\n        )\n    {\n        return\n            abi.decode(\n                _validationData,\n                (address, address, bytes4, address[], uint256[], address[], uint256[])\n            );\n    }\n\n    /// @dev Helper to parse validation arguments from encoded data for ReactivateExternalPosition policy hook\n    function __decodeReactivateExternalPositionValidationData(bytes memory _validationData)\n        internal\n        pure\n        returns (address caller_, address externalPosition_)\n    {\n        return abi.decode(_validationData, (address, address));\n    }\n\n    /// @dev Helper to parse validation arguments from encoded data for RedeemSharesForSpecificAssets policy hook\n    function __decodeRedeemSharesForSpecificAssetsValidationData(bytes memory _validationData)\n        internal\n        pure\n        returns (\n            address redeemer_,\n            address recipient_,\n            uint256 sharesToRedeemPostFees_,\n            address[] memory assets_,\n            uint256[] memory assetAmounts_,\n            uint256 gavPreRedeem_\n        )\n    {\n        return\n            abi.decode(\n                _validationData,\n                (address, address, uint256, address[], uint256[], uint256)\n            );\n    }\n\n    /// @dev Helper to parse validation arguments from encoded data for RemoveExternalPosition policy hook\n    function __decodeRemoveExternalPositionValidationData(bytes memory _validationData)\n        internal\n        pure\n        returns (address caller_, address externalPosition_)\n    {\n        return abi.decode(_validationData, (address, address));\n    }\n\n    /// @dev Helper to parse validation arguments from encoded data for RemoveTrackedAssets policy hook\n    function __decodeRemoveTrackedAssetsValidationData(bytes memory _validationData)\n        internal\n        pure\n        returns (address caller_, address[] memory assets_)\n    {\n        return abi.decode(_validationData, (address, address[]));\n    }\n\n    ///////////////////\n    // STATE GETTERS //\n    ///////////////////\n\n    /// @notice Gets the `POLICY_MANAGER` variable value\n    /// @return policyManager_ The `POLICY_MANAGER` variable value\n    function getPolicyManager() external view returns (address policyManager_) {\n        return POLICY_MANAGER;\n    }\n}\n"
    }
  }
}}