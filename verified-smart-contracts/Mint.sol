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
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @title ERC721 token receiver interface\n * @dev Interface for any contract that wants to support safeTransfers\n * from ERC721 asset contracts.\n */\ninterface IERC721Receiver {\n    /**\n     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}\n     * by `operator` from `from`, this function is called.\n     *\n     * It must return its Solidity selector to confirm the token transfer.\n     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.\n     *\n     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.\n     */\n    function onERC721Received(\n        address operator,\n        address from,\n        uint256 tokenId,\n        bytes calldata data\n    ) external returns (bytes4);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../IERC721Receiver.sol\";\n\n/**\n * @dev Implementation of the {IERC721Receiver} interface.\n *\n * Accepts all token transfers.\n * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.\n */\ncontract ERC721Holder is IERC721Receiver {\n    /**\n     * @dev See {IERC721Receiver-onERC721Received}.\n     *\n     * Always returns `IERC721Receiver.onERC721Received.selector`.\n     */\n    function onERC721Received(\n        address,\n        address,\n        uint256,\n        bytes memory\n    ) public virtual override returns (bytes4) {\n        return this.onERC721Received.selector;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "contracts/Mint.sol": {
      "content": "// SPDX-License-Identifier: Apache-2.0\n\npragma solidity ^0.8.0;\n\nimport \"./Whitelist.sol\";\nimport {ERC721Holder} from \"@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol\";\n\ninterface IToken {\n    function mintHedgie(uint256 tier, bytes32[] calldata merkleProof) external;\n\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) external;\n\n    function tokenOfOwnerByIndex(address owner, uint256 index)\n        external\n        view\n        returns (uint256);\n}\n\ncontract Mint is ERC721Holder, Whitelist {\n    address public _contractAddress;\n    bytes32[] public _merkleProof;\n\n    constructor(address contractAddress, bytes32[] memory merkleProof) {\n        _contractAddress = contractAddress;\n        _merkleProof = merkleProof;\n    }\n\n    function mint(uint256 amount) external onlyWhitelisted {\n        IToken token = IToken(_contractAddress);\n\n        uint256 mintedAmount = amount;\n\n        for (uint256 i = 0; i < amount; i++) {\n            try token.mintHedgie(2, _merkleProof) {\n                continue;\n            } catch {\n                mintedAmount = i;\n                break;\n            }\n        }\n\n        if (mintedAmount > 0) {\n            _withdraw(_getTokenIds(mintedAmount), msg.sender);\n        }\n    }\n\n    function _getTokenIds(uint256 amount) internal returns (uint256[] memory) {\n        IToken token = IToken(_contractAddress);\n        uint256[] memory tokenIds = new uint256[](amount);\n        for (uint256 i = 0; i < amount; i++) {\n            tokenIds[i] = token.tokenOfOwnerByIndex(address(this), i);\n        }\n        return tokenIds;\n    }\n\n    function _withdraw(uint256[] memory tokenIds, address recipient) internal {\n        IToken token = IToken(_contractAddress);\n        for (uint256 i = 0; i < tokenIds.length; i++) {\n            token.safeTransferFrom(address(this), recipient, tokenIds[i]);\n        }\n    }\n\n    function withdraw(uint256[] calldata tokenIds, address recipient)\n        external\n        onlyWhitelisted\n    {\n        _withdraw(tokenIds, recipient);\n    }\n}\n"
    },
    "contracts/Whitelist.sol": {
      "content": "// SPDX-License-Identifier: Apache-2.0\n\npragma solidity ^0.8.0;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\n\ncontract Whitelist is Ownable {\n    mapping(address => bool) whitelist;\n    event AddedToWhitelist(address indexed account);\n    event RemovedFromWhitelist(address indexed account);\n\n    modifier onlyWhitelisted() {\n        require(isWhitelisted(msg.sender), \"Address not whitelisted\");\n        _;\n    }\n\n    function addToWhitelist(address[] calldata _addresses) public onlyOwner {\n        for (uint256 i = 0; i < _addresses.length; i++) {\n            whitelist[_addresses[i]] = true;\n            emit AddedToWhitelist(_addresses[i]);\n        }\n    }\n\n    function removeFromWhitelist(address _address) public onlyOwner {\n        whitelist[_address] = false;\n        emit RemovedFromWhitelist(_address);\n    }\n\n    function isWhitelisted(address _address) public view returns (bool) {\n        return whitelist[_address];\n    }\n}\n"
    }
  }
}}