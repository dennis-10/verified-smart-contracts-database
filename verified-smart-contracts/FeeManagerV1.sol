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
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "contracts/core/FeeManager/FeeManagerV1.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"./../IRadarBridgeFeeManager.sol\";\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\n\ncontract FeeManagerV1 is IRadarBridgeFeeManager {\n    mapping(address => uint256) private maxTokenFee;\n    uint256 constant FEE_BASE = 1000000;\n    address private owner;\n\n    uint256 private percentageFee;\n\n    modifier onlyOwner() {\n        require(msg.sender == owner, \"Unauthorized\");\n        _;\n    }\n\n    constructor (\n        uint256 _percentageFee,\n        address[] memory _tokens,\n        uint256[] memory _maxFees\n    ) {\n        require(_percentageFee < FEE_BASE, \"Fee too big\");\n        require(_tokens.length == _maxFees.length, \"Invalid maxFees data\");\n\n        owner = msg.sender;\n        percentageFee = _percentageFee;\n        for(uint8 i = 0; i < _tokens.length; i++) {\n            maxTokenFee[_tokens[i]] = _maxFees[i];\n        }\n    }\n\n    // DAO Functions\n    function passOwnership(address _newOwner) external onlyOwner {\n        owner = _newOwner;\n    }\n\n    function changePercentageFee(uint256 _newFee) external onlyOwner {\n        require(_newFee < FEE_BASE, \"Fee too big\");\n        percentageFee = _newFee;\n    }\n\n    function changeTokenMaxFee(address _token, uint256 _maxFee) external onlyOwner {\n        maxTokenFee[_token] = _maxFee;\n    }\n\n    function withdrawTokens(address _token, uint256 _amount, address _receiver) external onlyOwner {\n        uint256 _bal = IERC20(_token).balanceOf(address(this));\n        uint256 _withdrawAmount = _amount;\n        if (_withdrawAmount > _bal) {\n            _withdrawAmount = _bal;\n        }\n\n        IERC20(_token).transfer(_receiver, _withdrawAmount);\n    }\n\n    // Fee Manager Functions\n\n    function getBridgeFee(address _token, address, uint256 _amount, bytes32, address) external override view returns (uint256) {\n        uint256 _percFee = percentageFee;\n\n        if (((_amount * _percFee) / FEE_BASE) > maxTokenFee[_token]) {\n            if (_amount != 0) {\n                _percFee = (maxTokenFee[_token] * FEE_BASE) / _amount;\n            } else {\n                _percFee = 0;\n            }\n        }\n\n        return _percFee;\n    }\n\n    function getFeeBase() external override view returns (uint256) {\n        return FEE_BASE;\n    }\n\n    // State Getters\n    function getFixedPercRate() external view returns (uint256) {\n        return percentageFee;\n    }\n\n    function getMaxFeeForToken(address _token) external view returns (uint256) {\n        return maxTokenFee[_token];\n    }\n\n    function getOwner() external view returns (address) {\n        return owner;\n    }\n}"
    },
    "contracts/core/IRadarBridgeFeeManager.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\ninterface IRadarBridgeFeeManager {\n    function getBridgeFee(address _token, address _sender, uint256 _amount, bytes32 _destChain, address _destAddress) external view returns (uint256);\n\n    function getFeeBase() external view returns (uint256);\n}"
    }
  }
}}