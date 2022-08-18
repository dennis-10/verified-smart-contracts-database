{"BatchTransfer.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./IERC165.sol\";\nimport \"./IERC1155.sol\";\nimport \"./IERC721.sol\";\nimport \"./IERC721Enumerable.sol\";\n\n/**\n * Simple contract to enable batched transfers of ERC721 and ERC1155 collections between addresses.\n */\ncontract BatchTransfer {\n\n    event BatchTransferred(uint256 indexed tokensTransferred, uint256 indexed lastTokenTransferred);\n\n    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;\n\n    /**\n     * Transfers all of the given tokens in this collection between addresses.\n     */ \n    function batchTransferAllERC1155(address collection, uint256 tokenId, address destination) external {\n        IERC1155 erc1155 = IERC1155(collection);\n        erc1155.safeTransferFrom(msg.sender, destination, tokenId, erc1155.balanceOf(msg.sender, tokenId), \"\");\n    }\n\n    /**\n     * Transfers the specified amount of the given tokens in this collection between addresses.\n     */ \n    function batchTransferERC1155(address collection, uint256 tokenId, uint256 tokenValue, address destination) external {\n        IERC1155 erc1155 = IERC1155(collection);\n        erc1155.safeTransferFrom(msg.sender, destination, tokenId, tokenValue, \"\");\n    }\n\n    /**\n     * Transfers all items in this collection which are owned by the caller to the destination address.\n     */\n    function batchTransferAllERC721(address collection, address destination) external {\n        batchTransferSomeERC721(collection, destination, 0, type(uint256).max);\n    }\n\n    /**\n     * Transfers all items in this collection which are owned by the caller to the destination address.\n     *\n     * If the contract implements ERC721Enumerable this call will directly look up the tokens for the calling\n     * address.  Otherwise it will search all tokens, optionally starting at `startID`.\n     */\n    function batchTransferSomeERC721(address collection, address destination, uint256 startId, uint256 max) public {\n        IERC721 erc721 = IERC721(collection);\n        uint256 avail = erc721.balanceOf(msg.sender);\n        uint256 currentToken;\n        uint256 numberToTransfer = avail;\n        if (max \u003c avail) numberToTransfer = max;\n\n        if (erc721.supportsInterface(_INTERFACE_ID_ERC721_ENUMERABLE)) {\n            IERC721Enumerable enumerable = IERC721Enumerable(collection);\n            for (uint256 i = numberToTransfer; i \u003e 0; i--) {\n                currentToken = enumerable.tokenOfOwnerByIndex(msg.sender, 0);\n                erc721.safeTransferFrom(msg.sender, destination, currentToken);\n            }\n        } else {\n            uint256 counter = startId;\n            uint256 remaining = numberToTransfer;\n            while (remaining \u003e 0) {\n                if (erc721.ownerOf(counter) == msg.sender) {\n                    currentToken = counter;\n                    erc721.safeTransferFrom(msg.sender, destination, counter);\n                    --remaining;\n                }\n                counter++;\n            }\n        }\n\n        emit BatchTransferred(numberToTransfer, currentToken);\n    }   \n\n    /**\n     * Transfers the specified items in this collection to the destination address.\n    */\n    function batchTransferERC721(address collection, address destination, uint256[] calldata tokenIds) external {\n        for (uint i = 0; i \u003c tokenIds.length; i++) {\n            IERC721 erc721 = IERC721(collection);\n            erc721.safeTransferFrom(msg.sender, destination, tokenIds[i]);\n        }\n    }\n\n    /**\n     * Transfers the specified item in this collection to the destination address.\n    */\n    function transferERC721(address collection, address destination, uint256 tokenId) external {\n        IERC721 erc721 = IERC721(collection);\n        erc721.safeTransferFrom(msg.sender, destination, tokenId);\n    }\n}\n\n"},"IERC1155.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./IERC165.sol\";\n\n/**\n * @dev Required interface of an ERC1155 compliant contract, as defined in the\n * https://eips.ethereum.org/EIPS/eip-1155[EIP].\n *\n * _Available since v3.1._\n */\ninterface IERC1155 is IERC165 {\n    /**\n     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.\n     */\n    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);\n\n    /**\n     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all\n     * transfers.\n     */\n    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);\n\n    /**\n     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to\n     * `approved`.\n     */\n    event ApprovalForAll(address indexed account, address indexed operator, bool approved);\n\n    /**\n     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.\n     *\n     * If an {URI} event was emitted for `id`, the standard\n     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value\n     * returned by {IERC1155MetadataURI-uri}.\n     */\n    event URI(string value, uint256 indexed id);\n\n    /**\n     * @dev Returns the amount of tokens of token type `id` owned by `account`.\n     *\n     * Requirements:\n     *\n     * - `account` cannot be the zero address.\n     */\n    function balanceOf(address account, uint256 id) external view returns (uint256);\n\n    /**\n     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.\n     *\n     * Requirements:\n     *\n     * - `accounts` and `ids` must have the same length.\n     */\n    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);\n\n    /**\n     * @dev Grants or revokes permission to `operator` to transfer the caller\u0027s tokens, according to `approved`,\n     *\n     * Emits an {ApprovalForAll} event.\n     *\n     * Requirements:\n     *\n     * - `operator` cannot be the caller.\n     */\n    function setApprovalForAll(address operator, bool approved) external;\n\n    /**\n     * @dev Returns true if `operator` is approved to transfer ``account``\u0027s tokens.\n     *\n     * See {setApprovalForAll}.\n     */\n    function isApprovedForAll(address account, address operator) external view returns (bool);\n\n    /**\n     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.\n     *\n     * Emits a {TransferSingle} event.\n     *\n     * Requirements:\n     *\n     * - `to` cannot be the zero address.\n     * - If the caller is not `from`, it must be have been approved to spend ``from``\u0027s tokens via {setApprovalForAll}.\n     * - `from` must have a balance of tokens of type `id` of at least `amount`.\n     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the\n     * acceptance magic value.\n     */\n    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;\n\n    /**\n     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.\n     *\n     * Emits a {TransferBatch} event.\n     *\n     * Requirements:\n     *\n     * - `ids` and `amounts` must have the same length.\n     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the\n     * acceptance magic value.\n     */\n    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;\n}\n\n"},"IERC165.sol":{"content":"// SPDX-License-Identifier: None\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC165 standard, as defined in the\n * [EIP](https://eips.ethereum.org/EIPS/eip-165).\n *\n * Implementers can declare support of contract interfaces, which can then be\n * queried by others (`ERC165Checker`).\n *\n * For an implementation, see `ERC165`.\n */\ninterface IERC165 {\n    /**\n     * @dev Returns true if this contract implements the interface defined by\n     * `interfaceId`. See the corresponding\n     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)\n     * to learn more about how these ids are created.\n     *\n     * This function call must use less than 30 000 gas.\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n\n"},"IERC721.sol":{"content":"// SPDX-License-Identifier: None\n\npragma solidity ^0.8.0;\n\nimport \"./IERC165.sol\";\n\nabstract contract IERC721 is IERC165 {\n    function balanceOf(address owner) public virtual view returns (uint256 balance);\n    function ownerOf(uint256 tokenId) public virtual view returns (address owner);\n    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual;\n    function getApproved(uint256 tokenId) public virtual view returns (address operator);\n    function isApprovedForAll(address owner, address operator) public virtual view returns (bool);\n}\n\n"},"IERC721Enumerable.sol":{"content":"// SPDX-License-Identifier: None\n\npragma solidity ^0.8.0;\n\nimport \"./IERC721.sol\";\n\n/**\n * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension\n * @dev See https://eips.ethereum.org/EIPS/eip-721\n */\nabstract contract IERC721Enumerable is IERC721 {\n    function totalSupply() public virtual view returns (uint256);\n    function tokenOfOwnerByIndex(address owner, uint256 index) public virtual view returns (uint256 tokenId);\n    function tokenByIndex(uint256 index) public virtual view returns (uint256);\n}\n\n"}}