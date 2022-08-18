{{
  "language": "Solidity",
  "sources": {
    "OracleAggregator.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity 0.8.6;\n\nimport \"IERC20.sol\";\nimport \"IPriceOracle.sol\";\nimport \"SafeOwnable.sol\";\n\ninterface IExternalOracle {\n  function price(address _token) external view returns (uint);\n}\n\ncontract OracleAggregator is IPriceOracle, SafeOwnable {\n\n  address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;\n\n  mapping (address => IExternalOracle) public oracles;\n\n  event SetOracle(address indexed token, address indexed oracle);\n\n  function setOracle(address _token, IExternalOracle _value) external onlyOwner {\n    oracles[_token] = _value;\n    emit SetOracle(_token, address(_value));\n  }\n\n  function tokenPrice(address _token) public view override returns(uint) {\n    if (_token == WETH) { return 1e18; }\n    return oracles[_token].price(_token);\n  }\n\n  // Not used in any code to save gas. But useful for external usage.\n  function convertTokenValues(address _fromToken, address _toToken, uint _amount) external view override returns(uint) {\n    uint priceFrom = tokenPrice(_fromToken) * 1e18 / 10 ** IERC20(_fromToken).decimals();\n    uint priceTo   = tokenPrice(_toToken)   * 1e18 / 10 ** IERC20(_toToken).decimals();\n    return _amount * priceFrom / priceTo;\n  }\n\n  function tokenSupported(address _token) external view override returns(bool) {\n    if (_token == WETH) { return true; }\n    return address(oracles[_token]) != address(0);\n  }\n}\n"
    },
    "IERC20.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity >=0.7.0;\n\ninterface IERC20 {\n  function totalSupply() external view returns (uint);\n  function balanceOf(address account) external view returns(uint);\n  function transfer(address recipient, uint256 amount) external returns(bool);\n  function allowance(address owner, address spender) external view returns(uint);\n  function decimals() external view returns(uint8);\n  function approve(address spender, uint amount) external returns(bool);\n  function transferFrom(address sender, address recipient, uint amount) external returns(bool);\n}"
    },
    "IPriceOracle.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity 0.8.6;\n\ninterface IPriceOracle {\n\n  function tokenPrice(address _token) external view returns(uint);\n  function tokenSupported(address _token) external view returns(bool);\n  function convertTokenValues(address _fromToken, address _toToken, uint _amount) external view returns(uint);\n}\n"
    },
    "SafeOwnable.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity 0.8.6;\n\nimport \"IOwnable.sol\";\n\ncontract SafeOwnable is IOwnable {\n\n  uint public constant RENOUNCE_TIMEOUT = 1 hours;\n\n  address public override owner;\n  address public pendingOwner;\n  uint public renouncedAt;\n\n  event OwnershipTransferInitiated(address indexed previousOwner, address indexed newOwner);\n  event OwnershipTransferConfirmed(address indexed previousOwner, address indexed newOwner);\n\n  constructor() {\n    owner = msg.sender;\n    emit OwnershipTransferConfirmed(address(0), msg.sender);\n  }\n\n  modifier onlyOwner() {\n    require(isOwner(), \"Ownable: caller is not the owner\");\n    _;\n  }\n\n  function isOwner() public view returns (bool) {\n    return msg.sender == owner;\n  }\n\n  function transferOwnership(address _newOwner) external override onlyOwner {\n    require(_newOwner != address(0), \"Ownable: new owner is the zero address\");\n    emit OwnershipTransferInitiated(owner, _newOwner);\n    pendingOwner = _newOwner;\n  }\n\n  function acceptOwnership() external override {\n    require(msg.sender == pendingOwner, \"Ownable: caller is not pending owner\");\n    emit OwnershipTransferConfirmed(msg.sender, pendingOwner);\n    owner = pendingOwner;\n    pendingOwner = address(0);\n  }\n\n  function initiateRenounceOwnership() external onlyOwner {\n    require(renouncedAt == 0, \"Ownable: already initiated\");\n    renouncedAt = block.timestamp;\n  }\n\n  function acceptRenounceOwnership() external onlyOwner {\n    require(renouncedAt > 0, \"Ownable: not initiated\");\n    require(block.timestamp - renouncedAt > RENOUNCE_TIMEOUT, \"Ownable: too early\");\n    owner = address(0);\n    pendingOwner = address(0);\n    renouncedAt = 0;\n  }\n\n  function cancelRenounceOwnership() external onlyOwner {\n    require(renouncedAt > 0, \"Ownable: not initiated\");\n    renouncedAt = 0;\n  }\n}"
    },
    "IOwnable.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity 0.8.6;\n\ninterface IOwnable {\n  function owner() external view returns(address);\n  function transferOwnership(address _newOwner) external;\n  function acceptOwnership() external;\n}"
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