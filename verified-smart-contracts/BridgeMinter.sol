{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
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
    "contracts/solc-0.8.9/IController.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// solhint-disable-next-line\npragma solidity 0.8.9;\n\ninterface IController {\n    function setContractInfo(\n        bytes32 _id,\n        address _contractAddress,\n        bytes20 _gitCommitHash\n    ) external;\n\n    function updateController(bytes32 _id, address _controller) external;\n\n    function getContract(bytes32 _id) external view returns (address);\n\n    function owner() external view returns (address);\n\n    function paused() external view returns (bool);\n}\n"
    },
    "contracts/solc-0.8.9/IManager.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// solhint-disable-next-line\npragma solidity 0.8.9;\n\ninterface IManager {\n    event SetController(address controller);\n    event ParameterUpdate(string param);\n\n    function setController(address _controller) external;\n}\n"
    },
    "contracts/solc-0.8.9/Manager.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// solhint-disable-next-line\npragma solidity 0.8.9;\n\nimport \"./IManager.sol\";\nimport \"./IController.sol\";\n\ncontract Manager is IManager {\n    // Controller that contract is registered with\n    IController public controller;\n\n    // Check if sender is controller\n    modifier onlyController() {\n        _onlyController();\n        _;\n    }\n\n    // Check if sender is controller owner\n    modifier onlyControllerOwner() {\n        _onlyControllerOwner();\n        _;\n    }\n\n    constructor(address _controller) {\n        controller = IController(_controller);\n    }\n\n    /**\n     * @notice Set controller. Only callable by current controller\n     * @param _controller Controller contract address\n     */\n    function setController(address _controller) external onlyController {\n        controller = IController(_controller);\n\n        emit SetController(_controller);\n    }\n\n    function _onlyController() private view {\n        require(msg.sender == address(controller), \"caller must be Controller\");\n    }\n\n    function _onlyControllerOwner() private view {\n        require(msg.sender == controller.owner(), \"caller must be Controller owner\");\n    }\n}\n"
    },
    "contracts/token/BridgeMinter.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// solhint-disable-next-line\npragma solidity 0.8.9;\n\nimport \"../solc-0.8.9/Manager.sol\";\n\ninterface IBridgeMinterToken {\n    function transfer(address _to, uint256 _amount) external;\n\n    function mint(address _to, uint256 _amount) external;\n\n    function transferOwnership(address _owner) external;\n\n    function balanceOf(address _addr) external view returns (uint256);\n}\n\ncontract BridgeMinter is Manager {\n    address public l1MigratorAddr;\n    address public l1LPTGatewayAddr;\n\n    event L1MigratorUpdate(address l1MigratorAddr);\n    event L1LPTGatewayUpdate(address l1LPTGatewayAddr);\n\n    modifier onlyL1Migrator() {\n        require(msg.sender == l1MigratorAddr, \"NOT_L1_MIGRATOR\");\n        _;\n    }\n\n    modifier onlyL1LPTGateway() {\n        require(msg.sender == l1LPTGatewayAddr, \"NOT_L1_LPT_GATEWAY\");\n        _;\n    }\n\n    constructor(\n        address _controller,\n        address _l1MigratorAddr,\n        address _l1LPTGatewayAddr\n    ) Manager(_controller) {\n        l1MigratorAddr = _l1MigratorAddr;\n        l1LPTGatewayAddr = _l1LPTGatewayAddr;\n    }\n\n    /**\n     * @notice Set L1Migrator address. Only callable by Controller owner\n     * @param _l1MigratorAddr L1Migrator address\n     */\n    function setL1Migrator(address _l1MigratorAddr) external onlyControllerOwner {\n        l1MigratorAddr = _l1MigratorAddr;\n\n        emit L1MigratorUpdate(_l1MigratorAddr);\n    }\n\n    /**\n     * @notice Set L1LPTGateway address. Only callable by Controller owner\n     * @param _l1LPTGatewayAddr L1LPTGateway address\n     */\n    function setL1LPTGateway(address _l1LPTGatewayAddr) external onlyControllerOwner {\n        l1LPTGatewayAddr = _l1LPTGatewayAddr;\n\n        emit L1LPTGatewayUpdate(_l1LPTGatewayAddr);\n    }\n\n    /**\n     * @notice Migrate to a new Minter. Only callable by Controller owner\n     * @param _newMinterAddr New Minter address\n     */\n    function migrateToNewMinter(address _newMinterAddr) external onlyControllerOwner {\n        require(\n            _newMinterAddr != address(this) && _newMinterAddr != address(0),\n            \"BridgeMinter#migrateToNewMinter: INVALID_MINTER\"\n        );\n\n        IBridgeMinterToken token = livepeerToken();\n        // Transfer ownership of token to new Minter\n        token.transferOwnership(_newMinterAddr);\n        // Transfer current Minter's LPT balance to new Minter\n        token.transfer(_newMinterAddr, token.balanceOf(address(this)));\n        // Transfer current Minter's ETH balance to new Minter\n        // call() should be safe from re-entrancy here because the Controller owner and _newMinterAddr are trusted\n        (bool ok, ) = _newMinterAddr.call{ value: address(this).balance }(\"\");\n        require(ok, \"BridgeMinter#migrateToNewMinter: FAIL_CALL\");\n    }\n\n    /**\n     * @notice Send contract's ETH to L1Migrator. Only callable by L1Migrator\n     * @return Amount of ETH sent\n     */\n    function withdrawETHToL1Migrator() external onlyL1Migrator returns (uint256) {\n        uint256 balance = address(this).balance;\n\n        // call() should be safe from re-entrancy here because the L1Migrator and l1MigratorAddr are trusted\n        (bool ok, ) = l1MigratorAddr.call{ value: balance }(\"\");\n        require(ok, \"BridgeMinter#withdrawETHToL1Migrator: FAIL_CALL\");\n\n        return balance;\n    }\n\n    /**\n     * @notice Send contract's LPT to L1Migrator. Only callable by L1Migrator\n     * @return Amount of LPT sent\n     */\n    function withdrawLPTToL1Migrator() external onlyL1Migrator returns (uint256) {\n        IBridgeMinterToken token = livepeerToken();\n\n        uint256 balance = token.balanceOf(address(this));\n\n        token.transfer(l1MigratorAddr, balance);\n\n        return balance;\n    }\n\n    /**\n     * @notice Mint LPT to address. Only callable by L1LPTGateway\n     * @dev Relies on L1LPTGateway for minting rules\n     * @param _to Address to receive LPT\n     * @param _amount Amount of LPT to mint\n     */\n    function bridgeMint(address _to, uint256 _amount) external onlyL1LPTGateway {\n        livepeerToken().mint(_to, _amount);\n    }\n\n    /**\n     * @notice Deposit ETH. Required for migrateToNewMinter() from older Minter implementation\n     */\n    function depositETH() external payable returns (bool) {\n        return true;\n    }\n\n    /**\n     * @notice Returns Controller address. Required for migrateToNewMinter() from older Minter implementation\n     * @return Controller address\n     */\n    function getController() public view returns (address) {\n        return address(controller);\n    }\n\n    /**\n     * @dev Returns IBridgeMinterToken interface\n     */\n    function livepeerToken() private view returns (IBridgeMinterToken) {\n        return IBridgeMinterToken(controller.getContract(keccak256(\"LivepeerToken\")));\n    }\n}\n"
    }
  }
}}