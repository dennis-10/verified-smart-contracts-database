{{
  "language": "Solidity",
  "sources": {
    "ZapEthToPreCommit.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-or-later\npragma solidity 0.7.6;\n\nimport \"IERC20.sol\";\nimport \"IWETH.sol\";\nimport \"IPreCommit.sol\";\nimport \"Ownable.sol\";\n\ncontract ZapEthToPreCommit is Ownable {\n    IWETH public immutable weth;\n    IPreCommit public immutable preCommit;\n\n    constructor(address _weth, address _preCommit) {\n        require(_weth != address(0), \"weth = zero address\");\n        require(_preCommit != address(0), \"pre commit = zero address\");\n\n        weth = IWETH(_weth);\n        preCommit = IPreCommit(_preCommit);\n\n        IERC20(_weth).approve(_preCommit, type(uint).max);\n    }\n\n    function zap() external payable {\n        require(msg.value > 0, \"value = 0\");\n        weth.deposit{value: msg.value}();\n        preCommit.commit(msg.sender, msg.value);\n    }\n\n    function recover(address _token) external onlyOwner {\n        if (_token != address(0)) {\n            IERC20(_token).transfer(\n                msg.sender,\n                IERC20(_token).balanceOf(address(this))\n            );\n        } else {\n            payable(msg.sender).transfer(address(this).balance);\n        }\n    }\n}\n"
    },
    "IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "IWETH.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-or-later\npragma solidity 0.7.6;\n\ninterface IWETH {\n    function deposit() external payable;\n}\n"
    },
    "IPreCommit.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-or-later\npragma solidity 0.7.6;\n\ninterface IPreCommit {\n    function commit(address _from, uint _amount) external;\n}\n"
    },
    "Ownable.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-or-later\npragma solidity 0.7.6;\n\nimport \"IOwnable.sol\";\n\ncontract Ownable is IOwnable {\n    event OwnerNominated(address newOwner);\n    event OwnerChanged(address newOwner);\n\n    address public owner;\n    address public nominatedOwner;\n\n    constructor() {\n        owner = msg.sender;\n    }\n\n    modifier onlyOwner() {\n        require(msg.sender == owner, \"not owner\");\n        _;\n    }\n\n    function nominateNewOwner(address _owner) external override onlyOwner {\n        nominatedOwner = _owner;\n        emit OwnerNominated(_owner);\n    }\n\n    function acceptOwnership() external override {\n        require(msg.sender == nominatedOwner, \"not nominated\");\n\n        owner = msg.sender;\n        nominatedOwner = address(0);\n\n        emit OwnerChanged(msg.sender);\n    }\n}\n"
    },
    "IOwnable.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-or-later\npragma solidity 0.7.6;\n\ninterface IOwnable {\n    function nominateNewOwner(address _owner) external;\n    function acceptOwnership() external;\n}"
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