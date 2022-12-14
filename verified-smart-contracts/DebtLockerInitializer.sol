{{
  "language": "Solidity",
  "sources": {
    "DebtLockerInitializer.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-or-later\n\npragma solidity =0.8.7;\n\ninterface IMapleGlobalsLike {\n\n   function isValidCollateralAsset(address asset_) external view returns (bool isValid_);\n\n   function isValidLiquidityAsset(address asset_) external view returns (bool isValid_);\n\n}\n\ninterface IMapleLoanLike {\n\n    function collateralAsset() external view returns (address collateralAsset_);\n\n    function fundsAsset() external view returns (address fundsAsset_);\n\n    function principalRequested() external view returns (uint256 principalRequested_);\n\n}\n\ninterface IPoolFactoryLike {\n\n    function globals() external pure returns (address globals_);\n\n}\n\ninterface IPoolLike {\n\n    function superFactory() external view returns (address superFactory_);\n\n}\n\n/// @title DebtLockerInitializer is intended to initialize the storage of a DebtLocker proxy.\ninterface IDebtLockerInitializer {\n\n    function encodeArguments(address loan_, address pool_) external pure returns (bytes memory encodedArguments_);\n\n    function decodeArguments(bytes calldata encodedArguments_) external pure returns (address loan_, address pool_);\n\n}\n\n/// @title DebtLockerStorage maps the storage layout of a DebtLocker.\ncontract DebtLockerStorage {\n\n    address internal _liquidator;\n    address internal _loan;\n    address internal _pool;\n\n    bool internal _repossessed;\n\n    uint256 internal _allowedSlippage;\n    uint256 internal _amountRecovered;\n    uint256 internal _fundsToCapture;\n    uint256 internal _minRatio;\n    uint256 internal _principalRemainingAtLastClaim;\n\n}\n\n/// @title DebtLockerInitializer is intended to initialize the storage of a DebtLocker proxy.\ncontract DebtLockerInitializer is IDebtLockerInitializer, DebtLockerStorage {\n\n    function encodeArguments(address loan_, address pool_) external pure override returns (bytes memory encodedArguments_) {\n        return abi.encode(loan_, pool_);\n    }\n\n    function decodeArguments(bytes calldata encodedArguments_) public pure override returns (address loan_, address pool_) {\n        ( loan_, pool_ ) = abi.decode(encodedArguments_, (address, address));\n    }\n\n    fallback() external {\n        ( address loan_, address pool_ ) = decodeArguments(msg.data);\n\n        IMapleGlobalsLike globals = IMapleGlobalsLike(IPoolFactoryLike(IPoolLike(pool_).superFactory()).globals());\n\n        require(globals.isValidCollateralAsset(IMapleLoanLike(loan_).collateralAsset()), \"DL:I:INVALID_COLLATERAL_ASSET\");\n        require(globals.isValidLiquidityAsset(IMapleLoanLike(loan_).fundsAsset()),       \"DL:I:INVALID_FUNDS_ASSET\");\n\n        _loan = loan_;\n        _pool = pool_;\n\n        _principalRemainingAtLastClaim = IMapleLoanLike(loan_).principalRequested();\n    }\n\n}\n"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    },
    "metadata": {
      "bytecodeHash": "none"
    }
  }
}}