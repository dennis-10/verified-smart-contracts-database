{{
  "language": "Solidity",
  "sources": {
    "contracts/AccessControl.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nabstract contract AccessControl {\n  address internal _admin;\n  address internal _owner;\n\n  modifier onlyAdmin() {\n    require(msg.sender == _admin, \"unauthorized\");\n    _;\n  }\n\n  modifier onlyOwner() {\n    require(msg.sender == _owner, \"unauthorized\");\n    _;\n  }\n\n  function changeAdmin(address newAdmin) external onlyOwner {\n    _admin = newAdmin;\n  }\n\n  function changeOwner(address newOwner) external onlyOwner {\n    _owner = newOwner;\n  }\n\n  function owner() external view returns (address) {\n    return _owner;\n  }\n}\n"
    },
    "contracts/interfaces/IERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC165 standard, as defined in the\n * https://eips.ethereum.org/EIPS/eip-165[EIP].\n *\n * Implementers can declare support of contract interfaces, which can then be\n * queried by others ({ERC165Checker}).\n *\n * For an implementation, see {ERC165}.\n */\ninterface IERC165 {\n  /**\n   * @dev Returns true if this contract implements the interface defined by\n   * `interfaceId`. See the corresponding\n   * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]\n   * to learn more about how these ids are created.\n   *\n   * This function call must use less than 30 000 gas.\n   */\n  function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"
    },
    "contracts/interfaces/IERC721.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Required interface of an ERC721 compliant contract.\n */\ninterface IERC721 {\n  /** Events */\n\n  /**\n   * @dev Emitted when `tokenId` token is transferred from `from` to `to`.\n   */\n  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);\n\n  /**\n   * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.\n   */\n  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);\n\n  /**\n   * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.\n   */\n  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);\n\n  /** Views */\n\n  /**\n   * @dev Returns the number of tokens in ``owner``'s account.\n   */\n  function balanceOf(address owner) external view returns (uint256 balance);\n\n  /**\n   * @dev Returns the account approved for `tokenId` token.\n   *\n   * Requirements:\n   *\n   * - `tokenId` must exist.\n   */\n  function getApproved(uint256 tokenId) external view returns (address operator);\n\n  /**\n   * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.\n   *\n   * See {setApprovalForAll}\n   */\n  function isApprovedForAll(address owner, address operator) external view returns (bool);\n\n  /**\n   * @dev Returns the owner of the `tokenId` token.\n   *\n   * Requirements:\n   *\n   * - `tokenId` must exist.\n   */\n  function ownerOf(uint256 tokenId) external view returns (address owner);\n\n  /** Mutators */\n\n  /**\n   * @dev Gives permission to `to` to transfer `tokenId` token to another account.\n   * The approval is cleared when the token is transferred.\n   *\n   * Only a single account can be approved at a time, so approving the zero address clears previous approvals.\n   *\n   * Requirements:\n   *\n   * - The caller must own the token or be an approved operator.\n   * - `tokenId` must exist.\n   *\n   * Emits an {Approval} event.\n   */\n  function approve(address to, uint256 tokenId) external;\n\n  /**\n   * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients\n   * are aware of the ERC721 protocol to prevent tokens from being forever locked.\n   *\n   * Requirements:\n   *\n   * - `from` cannot be the zero address.\n   * - `to` cannot be the zero address.\n   * - `tokenId` token must exist and be owned by `from`.\n   * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.\n   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n   *\n   * Emits a {Transfer} event.\n   */\n  function safeTransferFrom(\n    address from,\n    address to,\n    uint256 tokenId\n  ) external;\n\n  /**\n   * @dev Safely transfers `tokenId` token from `from` to `to`.\n   *\n   * Requirements:\n   *\n   * - `from` cannot be the zero address.\n   * - `to` cannot be the zero address.\n   * - `tokenId` token must exist and be owned by `from`.\n   * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n   *\n   * Emits a {Transfer} event.\n   */\n  function safeTransferFrom(\n    address from,\n    address to,\n    uint256 tokenId,\n    bytes calldata data\n  ) external;\n\n  /**\n   * @dev Approve or remove `operator` as an operator for the caller.\n   * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.\n   *\n   * Requirements:\n   *\n   * - The `operator` cannot be the caller.\n   *\n   * Emits an {ApprovalForAll} event.\n   */\n  function setApprovalForAll(address operator, bool approved) external;\n\n  /**\n   * @dev Transfers `tokenId` token from `from` to `to`.\n   *\n   * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.\n   *\n   * Requirements:\n   *\n   * - `from` cannot be the zero address.\n   * - `to` cannot be the zero address.\n   * - `tokenId` token must be owned by `from`.\n   * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n   *\n   * Emits a {Transfer} event.\n   */\n  function transferFrom(\n    address from,\n    address to,\n    uint256 tokenId\n  ) external;\n}\n"
    },
    "contracts/interfaces/IERC721Metadata.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @title ERC-721 Non-Fungible Token Standard, optional metadata extension\n * @dev See https://eips.ethereum.org/EIPS/eip-721\n */\ninterface IERC721Metadata {\n  /**\n   * @dev Returns the token collection name.\n   */\n  function name() external view returns (string memory);\n\n  /**\n   * @dev Returns the token collection symbol.\n   */\n  function symbol() external view returns (string memory);\n\n  /**\n   * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.\n   */\n  function tokenURI(uint256 tokenId) external view returns (string memory);\n}\n"
    },
    "contracts/interfaces/IERC721Receiver.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @title ERC721 token receiver interface\n * @dev Interface for any contract that wants to support safeTransfers\n * from ERC721 asset contracts.\n */\ninterface IERC721Receiver {\n  /**\n   * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}\n   * by `operator` from `from`, this function is called.\n   *\n   * It must return its Solidity selector to confirm the token transfer.\n   * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.\n   *\n   * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.\n   */\n  function onERC721Received(\n    address operator,\n    address from,\n    uint256 tokenId,\n    bytes calldata data\n  ) external returns (bytes4);\n}\n"
    },
    "contracts/NFTCollectionV2.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./AccessControl.sol\";\nimport \"./interfaces/IERC165.sol\";\nimport \"./interfaces/IERC721.sol\";\nimport \"./interfaces/IERC721Metadata.sol\";\nimport \"./interfaces/IERC721Receiver.sol\";\n\nabstract contract NFTCollectionV2 is AccessControl, IERC165, IERC721, IERC721Metadata {\n  /** @dev IERC721 Fields */\n\n  mapping(address => uint256) internal _balances;\n  mapping(address => mapping(address => bool)) internal _operatorApprovals;\n  mapping(uint256 => address) internal _owners;\n  mapping(uint256 => address) internal _tokenApprovals;\n\n  /** @dev IERC721Enumerable */\n\n  uint256 internal _totalSupply;\n\n  string internal _baseURI;\n\n  /** @dev IERC165 Views */\n\n  /**\n   * @dev See {IERC165-supportsInterface}.\n   */\n  function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {\n    return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721Metadata).interfaceId;\n  }\n\n  /** @dev IERC721 Views */\n\n  /**\n   * @dev Returns the number of tokens in ``owner``'s account.\n   */\n  function balanceOf(address owner_) external view override returns (uint256 balance) {\n    return _balances[owner_];\n  }\n\n  /**\n   * @dev Returns the account approved for `tokenId` token.\n   *\n   * Requirements:\n   *\n   * - `tokenId` must exist.\n   */\n  function getApproved(uint256 tokenId) external view override returns (address operator) {\n    return _tokenApprovals[tokenId];\n  }\n\n  /**\n   * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.\n   *\n   * See {setApprovalForAll}\n   */\n  function isApprovedForAll(address owner_, address operator) external view override returns (bool) {\n    return _operatorApprovals[owner_][operator];\n  }\n\n  /**\n   * @dev Returns the owner of the `tokenId` token.\n   *\n   * Requirements:\n   *\n   * - `tokenId` must exist.\n   */\n  function ownerOf(uint256 tokenId) external view override returns (address) {\n    return _owners[tokenId];\n  }\n\n  /** @dev IERC721 Mutators */\n\n  /**\n   * @dev Gives permission to `to` to transfer `tokenId` token to another account.\n   * The approval is cleared when the token is transferred.\n   *\n   * Only a single account can be approved at a time, so approving the zero address clears previous approvals.\n   *\n   * Requirements:\n   *\n   * - The caller must own the token or be an approved operator.\n   * - `tokenId` must exist.\n   *\n   * Emits an {Approval} event.\n   */\n  function approve(address to, uint256 tokenId) external override {\n    address owner_ = _owners[tokenId];\n\n    require(to != owner_, \"caller may not approve themself\");\n    require(msg.sender == owner_ || _operatorApprovals[owner_][msg.sender], \"unauthorized\");\n\n    _approve(to, tokenId);\n  }\n\n  /**\n   * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients\n   * are aware of the ERC721 protocol to prevent tokens from being forever locked.\n   *\n   * Requirements:\n   *\n   * - `from` cannot be the zero address.\n   * - `to` cannot be the zero address.\n   * - `tokenId` token must exist and be owned by `from`.\n   * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.\n   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n   *\n   * Emits a {Transfer} event.\n   */\n  function safeTransferFrom(\n    address from,\n    address to,\n    uint256 tokenId\n  ) external override {\n    _ensureApprovedOrOwner(msg.sender, tokenId);\n    _transfer(from, to, tokenId);\n\n    if (_isContract(to)) {\n      IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, \"\");\n    }\n  }\n\n  /**\n   * @dev Safely transfers `tokenId` token from `from` to `to`.\n   *\n   * Requirements:\n   *\n   * - `from` cannot be the zero address.\n   * - `to` cannot be the zero address.\n   * - `tokenId` token must exist and be owned by `from`.\n   * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n   *\n   * Emits a {Transfer} event.\n   */\n  function safeTransferFrom(\n    address from,\n    address to,\n    uint256 tokenId,\n    bytes calldata data\n  ) external override {\n    _ensureApprovedOrOwner(msg.sender, tokenId);\n    _transfer(from, to, tokenId);\n\n    if (_isContract(to)) {\n      IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data);\n    }\n  }\n\n  /**\n   * @dev Approve or remove `operator` as an operator for the caller.\n   * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.\n   *\n   * Requirements:\n   *\n   * - The `operator` cannot be the caller.\n   *\n   * Emits an {ApprovalForAll} event.\n   */\n  function setApprovalForAll(address operator, bool approved) external override {\n    require(operator != msg.sender, \"caller may not approve themself\");\n\n    _operatorApprovals[msg.sender][operator] = approved;\n\n    emit ApprovalForAll(msg.sender, operator, approved);\n  }\n\n  /**\n   * @dev Transfers `tokenId` token from `from` to `to`.\n   *\n   * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.\n   *\n   * Requirements:\n   *\n   * - `from` cannot be the zero address.\n   * - `to` cannot be the zero address.\n   * - `tokenId` token must be owned by `from`.\n   * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n   *\n   * Emits a {Transfer} event.\n   */\n  function transferFrom(\n    address from,\n    address to,\n    uint256 tokenId\n  ) external override {\n    _ensureApprovedOrOwner(msg.sender, tokenId);\n    _transfer(from, to, tokenId);\n  }\n\n  /** IERC721Metadata Views */\n\n  function tokenURI(uint256 tokenId) external view override returns (string memory) {\n    return string(abi.encodePacked(_baseURI, _toString(tokenId), \".json\"));\n  }\n\n  /** Useful Methods */\n\n  function changeBaseURI(string memory newURI) external onlyAdmin {\n    _baseURI = newURI;\n  }\n\n  function totalSupply() external view returns (uint256) {\n    return _totalSupply;\n  }\n\n  /** Helpers */\n\n  /**\n   * @dev Approve `to` to operate on `tokenId`\n   *\n   * Emits a {Approval} event.\n   */\n  function _approve(address to, uint256 tokenId) private {\n    _tokenApprovals[tokenId] = to;\n\n    emit Approval(_owners[tokenId], to, tokenId);\n  }\n\n  function _ensureApprovedOrOwner(address spender, uint256 tokenId) private view {\n    address owner_ = _owners[tokenId];\n\n    require(\n      spender == owner_ || spender == _tokenApprovals[tokenId] || _operatorApprovals[owner_][spender],\n      \"unauthorized\"\n    );\n  }\n\n  /**\n   * @dev Converts a `uint256` to its ASCII `string` decimal representation.\n   */\n  function _toString(uint256 value) internal pure returns (string memory) {\n    if (value == 0) {\n      return \"0\";\n    }\n    uint256 temp = value;\n    uint256 digits;\n    while (temp != 0) {\n      digits++;\n      temp /= 10;\n    }\n    bytes memory buffer = new bytes(digits);\n    while (value != 0) {\n      digits -= 1;\n      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));\n      value /= 10;\n    }\n    return string(buffer);\n  }\n\n  function _isContract(address account) internal view returns (bool) {\n    // This method relies on extcodesize, which returns 0 for contracts in\n    // construction, since the code is only stored at the end of the\n    // constructor execution.\n\n    uint256 size;\n\n    assembly {\n      size := extcodesize(account)\n    }\n\n    return size > 0;\n  }\n\n  /**\n   * @dev Transfers `tokenId` from `from` to `to`.\n   *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.\n   *\n   * Requirements:\n   *\n   * - `to` cannot be the zero address.\n   * - `tokenId` token must be owned by `from`.\n   *\n   * Emits a {Transfer} event.\n   */\n  function _transfer(\n    address from,\n    address to,\n    uint256 tokenId\n  ) private {\n    require(_owners[tokenId] == from, \"transfer of token that is not own\");\n    require(to != address(0), \"transfer to the zero address\");\n\n    // Clear approvals from the previous owner\n    _approve(address(0), tokenId);\n\n    _balances[from] -= 1;\n    _balances[to] += 1;\n    _owners[tokenId] = to;\n\n    emit Transfer(from, to, tokenId);\n  }\n}\n"
    },
    "contracts/FanEpackCollection.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.9;\n\nimport \"./AuthorizedV2.sol\";\nimport \"./NFTCollectionV2.sol\";\n\ncontract FanEpackCollection is AuthorizedV2, NFTCollectionV2 {\n  /** Fields */\n\n  bytes32 private immutable _claimSeparator;\n\n  mapping(address => uint256) private _claimed;\n\n  constructor(address authority_, string memory baseURI_) {\n    _admin = msg.sender;\n    _owner = msg.sender;\n\n    _authority = authority_;\n    _baseURI = baseURI_;\n\n    _claimSeparator = keccak256(\"Claim(address account,uint256 earned)\");\n  }\n\n  /** @dev IERC721Metadata Views */\n\n  /**\n   * @dev Returns the token collection name.\n   */\n  function name() external pure override returns (string memory) {\n    return \"FanEpack Collection\";\n  }\n\n  /**\n   * @dev Returns the token collection symbol.\n   */\n  function symbol() external pure override returns (string memory) {\n    return \"FEC\";\n  }\n\n  /** @dev Admin */\n\n  function changeAuthority(address newAuthority) external onlyAdmin {\n    _authority = newAuthority;\n  }\n\n  /** @dev Claim */\n\n  function claimed(address wallet) external view returns (uint256) {\n    return _claimed[wallet];\n  }\n\n  function claim(\n    uint256 quantity,\n    uint256 earned,\n    uint8 v,\n    bytes32 r,\n    bytes32 s\n  ) external {\n    require(verify(keccak256(abi.encode(_claimSeparator, msg.sender, earned)), v, r, s), \"invalid message\");\n    require(quantity + _claimed[msg.sender] <= earned, \"more than earned\");\n\n    for (uint256 i = 1; i <= quantity; i++) {\n      _owners[_totalSupply + i] = msg.sender;\n\n      emit Transfer(address(0), msg.sender, _totalSupply + i);\n    }\n\n    _balances[msg.sender] += quantity;\n    _claimed[msg.sender] += quantity;\n    _totalSupply += quantity;\n  }\n}\n"
    },
    "contracts/AuthorizedV2.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nabstract contract AuthorizedV2 {\n  bytes32 internal immutable _domainSeparator;\n\n  address internal _authority;\n\n  constructor() {\n    bytes32 typeHash = keccak256(\"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)\");\n\n    _domainSeparator = keccak256(\n      abi.encode(typeHash, keccak256(bytes(\"MetaFans\")), keccak256(bytes(\"1.0.0\")), block.chainid, address(this))\n    );\n  }\n\n  function verify(\n    bytes32 hash,\n    uint8 v,\n    bytes32 r,\n    bytes32 s\n  ) internal view returns (bool) {\n    return _authority == ecrecover(keccak256(abi.encodePacked(\"\\x19\\x01\", _domainSeparator, hash)), v, r, s);\n  }\n}\n"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 10000
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  }
}}