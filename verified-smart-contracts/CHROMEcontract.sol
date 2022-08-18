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
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _setOwner(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _setOwner(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _setOwner(newOwner);\n    }\n\n    function _setOwner(address newOwner) private {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC721/IERC721.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../../utils/introspection/IERC165.sol\";\n\n/**\n * @dev Required interface of an ERC721 compliant contract.\n */\ninterface IERC721 is IERC165 {\n    /**\n     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);\n\n    /**\n     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.\n     */\n    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);\n\n    /**\n     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.\n     */\n    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);\n\n    /**\n     * @dev Returns the number of tokens in ``owner``'s account.\n     */\n    function balanceOf(address owner) external view returns (uint256 balance);\n\n    /**\n     * @dev Returns the owner of the `tokenId` token.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     */\n    function ownerOf(uint256 tokenId) external view returns (address owner);\n\n    /**\n     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients\n     * are aware of the ERC721 protocol to prevent tokens from being forever locked.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must exist and be owned by `from`.\n     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) external;\n\n    /**\n     * @dev Transfers `tokenId` token from `from` to `to`.\n     *\n     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must be owned by `from`.\n     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) external;\n\n    /**\n     * @dev Gives permission to `to` to transfer `tokenId` token to another account.\n     * The approval is cleared when the token is transferred.\n     *\n     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.\n     *\n     * Requirements:\n     *\n     * - The caller must own the token or be an approved operator.\n     * - `tokenId` must exist.\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address to, uint256 tokenId) external;\n\n    /**\n     * @dev Returns the account approved for `tokenId` token.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     */\n    function getApproved(uint256 tokenId) external view returns (address operator);\n\n    /**\n     * @dev Approve or remove `operator` as an operator for the caller.\n     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.\n     *\n     * Requirements:\n     *\n     * - The `operator` cannot be the caller.\n     *\n     * Emits an {ApprovalForAll} event.\n     */\n    function setApprovalForAll(address operator, bool _approved) external;\n\n    /**\n     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.\n     *\n     * See {setApprovalForAll}\n     */\n    function isApprovedForAll(address owner, address operator) external view returns (bool);\n\n    /**\n     * @dev Safely transfers `tokenId` token from `from` to `to`.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must exist and be owned by `from`.\n     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId,\n        bytes calldata data\n    ) external;\n}\n"
    },
    "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @title ERC721 token receiver interface\n * @dev Interface for any contract that wants to support safeTransfers\n * from ERC721 asset contracts.\n */\ninterface IERC721Receiver {\n    /**\n     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}\n     * by `operator` from `from`, this function is called.\n     *\n     * It must return its Solidity selector to confirm the token transfer.\n     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.\n     *\n     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.\n     */\n    function onERC721Received(\n        address operator,\n        address from,\n        uint256 tokenId,\n        bytes calldata data\n    ) external returns (bytes4);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../IERC721.sol\";\n\n/**\n * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension\n * @dev See https://eips.ethereum.org/EIPS/eip-721\n */\ninterface IERC721Enumerable is IERC721 {\n    /**\n     * @dev Returns the total amount of tokens stored by the contract.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.\n     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.\n     */\n    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);\n\n    /**\n     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.\n     * Use along with {totalSupply} to enumerate all tokens.\n     */\n    function tokenByIndex(uint256 index) external view returns (uint256);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../IERC721.sol\";\n\n/**\n * @title ERC-721 Non-Fungible Token Standard, optional metadata extension\n * @dev See https://eips.ethereum.org/EIPS/eip-721\n */\ninterface IERC721Metadata is IERC721 {\n    /**\n     * @dev Returns the token collection name.\n     */\n    function name() external view returns (string memory);\n\n    /**\n     * @dev Returns the token collection symbol.\n     */\n    function symbol() external view returns (string memory);\n\n    /**\n     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.\n     */\n    function tokenURI(uint256 tokenId) external view returns (string memory);\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Strings.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev String operations.\n */\nlibrary Strings {\n    bytes16 private constant _HEX_SYMBOLS = \"0123456789abcdef\";\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` decimal representation.\n     */\n    function toString(uint256 value) internal pure returns (string memory) {\n        // Inspired by OraclizeAPI's implementation - MIT licence\n        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol\n\n        if (value == 0) {\n            return \"0\";\n        }\n        uint256 temp = value;\n        uint256 digits;\n        while (temp != 0) {\n            digits++;\n            temp /= 10;\n        }\n        bytes memory buffer = new bytes(digits);\n        while (value != 0) {\n            digits -= 1;\n            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));\n            value /= 10;\n        }\n        return string(buffer);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.\n     */\n    function toHexString(uint256 value) internal pure returns (string memory) {\n        if (value == 0) {\n            return \"0x00\";\n        }\n        uint256 temp = value;\n        uint256 length = 0;\n        while (temp != 0) {\n            length++;\n            temp >>= 8;\n        }\n        return toHexString(value, length);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.\n     */\n    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {\n        bytes memory buffer = new bytes(2 * length + 2);\n        buffer[0] = \"0\";\n        buffer[1] = \"x\";\n        for (uint256 i = 2 * length + 1; i > 1; --i) {\n            buffer[i] = _HEX_SYMBOLS[value & 0xf];\n            value >>= 4;\n        }\n        require(value == 0, \"Strings: hex length insufficient\");\n        return string(buffer);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev These functions deal with verification of Merkle Trees proofs.\n *\n * The proofs can be generated using the JavaScript library\n * https://github.com/miguelmota/merkletreejs[merkletreejs].\n * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.\n *\n * See `test/utils/cryptography/MerkleProof.test.js` for some examples.\n */\nlibrary MerkleProof {\n    /**\n     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree\n     * defined by `root`. For this, a `proof` must be provided, containing\n     * sibling hashes on the branch from the leaf to the root of the tree. Each\n     * pair of leaves and each pair of pre-images are assumed to be sorted.\n     */\n    function verify(\n        bytes32[] memory proof,\n        bytes32 root,\n        bytes32 leaf\n    ) internal pure returns (bool) {\n        bytes32 computedHash = leaf;\n\n        for (uint256 i = 0; i < proof.length; i++) {\n            bytes32 proofElement = proof[i];\n\n            if (computedHash <= proofElement) {\n                // Hash(current computed hash + current element of the proof)\n                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));\n            } else {\n                // Hash(current element of the proof + current computed hash)\n                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));\n            }\n        }\n\n        // Check if the computed hash (root) is equal to the provided root\n        return computedHash == root;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/introspection/ERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./IERC165.sol\";\n\n/**\n * @dev Implementation of the {IERC165} interface.\n *\n * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check\n * for the additional interface id that will be supported. For example:\n *\n * ```solidity\n * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);\n * }\n * ```\n *\n * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.\n */\nabstract contract ERC165 is IERC165 {\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n        return interfaceId == type(IERC165).interfaceId;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/introspection/IERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC165 standard, as defined in the\n * https://eips.ethereum.org/EIPS/eip-165[EIP].\n *\n * Implementers can declare support of contract interfaces, which can then be\n * queried by others ({ERC165Checker}).\n *\n * For an implementation, see {ERC165}.\n */\ninterface IERC165 {\n    /**\n     * @dev Returns true if this contract implements the interface defined by\n     * `interfaceId`. See the corresponding\n     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]\n     * to learn more about how these ids are created.\n     *\n     * This function call must use less than 30 000 gas.\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"
    },
    "src/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.6;\n\nlibrary Address {\n    function isContract(address account) internal view returns (bool) {\n        uint size;\n        assembly {\n            size := extcodesize(account)\n        }\n        return size > 0;\n    }\n}"
    },
    "src/CHROMEcontract.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.6;\n\nimport \"@openzeppelin/contracts/utils/cryptography/MerkleProof.sol\";\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"./ERC721Enumerable.sol\";\n\ncontract CHROMEcontract is ERC721Enumerable, Ownable {\n\n    bytes32 public whitelistMerkleRoot;\n    \n    address public UnemploymentOffice; \n    address public partner;\n    \n    string public baseURI;\n    string public CHROMEKID_PROVENANCE = \"\";\n\n    mapping(address => uint) public presaleMints;\n    \n    uint256 public constant MAX_KIDS = 3334;\n    uint256 public constant KIDS_PER_TX = 11; \n    uint256 public constant KID_PRICE = 0.03 ether; \n    \n    bool public presaleLive = true;\n    bool public saleLive = false;\n    bool public REVEALED = false;    \n\n    constructor(\n        string memory _baseURI,\n        address _unemployment,\n        address _partner\n        )\n        ERC721(\"CHROME kids\", \"CHROME\") payable {\n            baseURI = _baseURI;\n            UnemploymentOffice = payable(_unemployment);\n            partner = payable(_partner);\n        }\n    \n\n    function presaleMint(uint256 _mintAmount, bytes32[] calldata proof) external payable {\n        require(presaleLive, \"Presale Closed\");\n        require(_verify(_leaf(msg.sender), proof), \"Invalid proof\");\n        require(presaleMints[msg.sender] + _mintAmount < 4, \"No more than 3 presale mints per wallet\");\n        require( KID_PRICE * _mintAmount == msg.value, \"Invalid amount of ETH bruh.\");\n        \n        presaleMints[msg.sender] += _mintAmount;\n        uint256 totalSupply = _owners.length;\n        for (uint256 i = 0; i < _mintAmount; i++) {\n          _mint(_msgSender(), totalSupply + i);\n        }\n    }\n    \n    function publicMint(uint256 _mintAmount) public payable {\n        uint256 totalSupply = _owners.length;\n        require(saleLive, \"Public sale is not active\");\n        require(totalSupply + _mintAmount < MAX_KIDS, \"Transaction will exceed supply\");\n        require(_mintAmount < KIDS_PER_TX, \"Exceeded max per transaction\");\n        require(_mintAmount * KID_PRICE == msg.value, \"Not enough ETH bruh.\");\n  \n        for (uint256 i = 0; i < _mintAmount; i++) {\n          _mint(_msgSender(), totalSupply + i);\n        }\n    }\n\n    function gift(address[] calldata receivers) external onlyOwner { \n        uint256 totalSupply = _owners.length;   \n        require(totalSupply + receivers.length < MAX_KIDS, \"Transaction will exceed supply\");  \n        for (uint256 i = 0; i < receivers.length; i++) {\n            _mint(receivers[i], totalSupply + i);\n        }\n    }\n\n    function _mint(address to, uint256 tokenId) internal virtual override {\n        _owners.push(to);\n        emit Transfer(address(0), to, tokenId);\n    }\n\n    function _leaf(address account) internal pure returns (bytes32) {\n        return keccak256(abi.encodePacked(account));\n    }\n\n    function _verify(bytes32 leaf, bytes32[] memory proof) internal view returns (bool) {\n        return MerkleProof.verify(proof, whitelistMerkleRoot, leaf);\n    }\n\n    function setBaseURI(string memory _newBaseURI) public onlyOwner {\n        baseURI = _newBaseURI;\n    }\n\n    function tokenURI(uint256 _tokenId) public view override returns (string memory){\n        require(\n          _exists(_tokenId),\n          \"ERC721Metadata: URI query for nonexistent token\"\n        );\n\n        string memory currentBaseURI = baseURI;\n        if (REVEALED == false) {\n            return bytes(currentBaseURI).length > 0\n            ? string(abi.encodePacked(currentBaseURI, \"hidden\", \".json\"))\n            : \"\";\n        } else {\n            return bytes(currentBaseURI).length > 0\n            ? string(abi.encodePacked(currentBaseURI, Strings.toString(_tokenId), \".json\"))\n            : \"\";\n        }\n  \n    }\n\n    function burn(uint256 tokenId) public { \n        require(_isApprovedOrOwner(_msgSender(), tokenId), \"Not approved to burn.\");\n        _burn(tokenId);\n    }\n\n    function walletOfOwner(address _owner) public view returns (uint256[] memory) {\n        uint256 tokenCount = balanceOf(_owner);\n        if (tokenCount == 0) return new uint256[](0);\n\n        uint256[] memory tokensId = new uint256[](tokenCount);\n        for (uint256 i; i < tokenCount; i++) {\n            tokensId[i] = tokenOfOwnerByIndex(_owner, i);\n        }\n        return tokensId;\n    }\n\n    function isOwnerOf(address account, uint256[] calldata _tokenIds) external view returns (bool){\n        for(uint256 i; i < _tokenIds.length; ++i ){\n            if(_owners[_tokenIds[i]] != account)\n                return false;\n        }\n\n        return true;\n    }\n\n    function setProvenanceHash(string memory provenanceHash) public onlyOwner {\n        CHROMEKID_PROVENANCE = provenanceHash;\n    }\n\n    function setWhitelistMerkleRoot(bytes32 _whitelistMerkleRoot) external onlyOwner {\n        whitelistMerkleRoot = _whitelistMerkleRoot;\n    }\n\n    function reveal() public onlyOwner() {\n        REVEALED = !REVEALED;\n    }\n\n    function flipPresaleState() public onlyOwner {\n        !presaleLive ? presaleLive = true : presaleLive = false;\n    }\n\n    function flipSaleState() public onlyOwner {\n        saleLive = !saleLive;\n    }\n\n    function withdraw() public onlyOwner {\n\n        (bool cool, ) = payable(partner).call{value: address(this).balance * 10 / 100}(\"\");\n        require(cool, \"Couldnt do it\");\n\n        (bool success, ) = payable(UnemploymentOffice).call{value: address(this).balance}(\"\");\n        require(success, \"Fail\");\n    }    \n\n}"
    },
    "src/ERC721.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\n//pragma solidity >=0.7.0 <0.9.0;\npragma solidity ^0.8.6;\n\nimport \"@openzeppelin/contracts/token/ERC721/IERC721.sol\";\nimport \"@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol\";\nimport \"@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol\";\nimport \"@openzeppelin/contracts/utils/Context.sol\";\nimport \"@openzeppelin/contracts/utils/Strings.sol\";\nimport \"@openzeppelin/contracts/utils/introspection/ERC165.sol\";\nimport \"./Address.sol\";\n\nabstract contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {\n    using Address for address;\n    using Strings for uint256;\n    \n    string private _name;\n    string private _symbol;\n\n    // Mapping from token ID to owner address\n    address[] internal _owners;\n\n    mapping(uint256 => address) private _tokenApprovals;\n    mapping(address => mapping(address => bool)) private _operatorApprovals;\n\n    /**\n     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.\n     */\n    constructor(string memory name_, string memory symbol_) {\n        _name = name_;\n        _symbol = symbol_;\n    }\n\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId)\n        public\n        view\n        virtual\n        override(ERC165, IERC165)\n        returns (bool)\n    {\n        return\n            interfaceId == type(IERC721).interfaceId ||\n            interfaceId == type(IERC721Metadata).interfaceId ||\n            super.supportsInterface(interfaceId);\n    }\n\n    /**\n     * @dev See {IERC721-balanceOf}.\n     */\n    function balanceOf(address owner) \n        public \n        view \n        virtual \n        override \n        returns (uint) \n    {\n        require(owner != address(0), \"ERC721: balance query for the zero address\");\n\n        uint count;\n        for( uint i; i < _owners.length; ++i ){\n          if( owner == _owners[i] )\n            ++count;\n        }\n        return count;\n    }\n\n    /**\n     * @dev See {IERC721-ownerOf}.\n     */\n    function ownerOf(uint256 tokenId)\n        public\n        view\n        virtual\n        override\n        returns (address)\n    {\n        address owner = _owners[tokenId];\n        require(\n            owner != address(0),\n            \"ERC721: owner query for nonexistent token\"\n        );\n        return owner;\n    }\n\n    /**\n     * @dev See {IERC721Metadata-name}.\n     */\n    function name() public view virtual override returns (string memory) {\n        return _name;\n    }\n\n    /**\n     * @dev See {IERC721Metadata-symbol}.\n     */\n    function symbol() public view virtual override returns (string memory) {\n        return _symbol;\n    }\n\n    /**\n     * @dev See {IERC721-approve}.\n     */\n    function approve(address to, uint256 tokenId) public virtual override {\n        address owner = ERC721.ownerOf(tokenId);\n        require(to != owner, \"ERC721: approval to current owner\");\n\n        require(\n            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),\n            \"ERC721: approve caller is not owner nor approved for all\"\n        );\n\n        _approve(to, tokenId);\n    }\n\n    /**\n     * @dev See {IERC721-getApproved}.\n     */\n    function getApproved(uint256 tokenId)\n        public\n        view\n        virtual\n        override\n        returns (address)\n    {\n        require(\n            _exists(tokenId),\n            \"ERC721: approved query for nonexistent token\"\n        );\n\n        return _tokenApprovals[tokenId];\n    }\n\n    /**\n     * @dev See {IERC721-setApprovalForAll}.\n     */\n    function setApprovalForAll(address operator, bool approved)\n        public\n        virtual\n        override\n    {\n        require(operator != _msgSender(), \"ERC721: approve to caller\");\n\n        _operatorApprovals[_msgSender()][operator] = approved;\n        emit ApprovalForAll(_msgSender(), operator, approved);\n    }\n\n    /**\n     * @dev See {IERC721-isApprovedForAll}.\n     */\n    function isApprovedForAll(address owner, address operator)\n        public\n        view\n        virtual\n        override\n        returns (bool)\n    {\n        return _operatorApprovals[owner][operator];\n    }\n\n    /**\n     * @dev See {IERC721-transferFrom}.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) public virtual override {\n        //solhint-disable-next-line max-line-length\n        require(\n            _isApprovedOrOwner(_msgSender(), tokenId),\n            \"ERC721: transfer caller is not owner nor approved\"\n        );\n\n        _transfer(from, to, tokenId);\n    }\n\n    /**\n     * @dev See {IERC721-safeTransferFrom}.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) public virtual override {\n        safeTransferFrom(from, to, tokenId, \"\");\n    }\n\n    /**\n     * @dev See {IERC721-safeTransferFrom}.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId,\n        bytes memory _data\n    ) public virtual override {\n        require(\n            _isApprovedOrOwner(_msgSender(), tokenId),\n            \"ERC721: transfer caller is not owner nor approved\"\n        );\n        _safeTransfer(from, to, tokenId, _data);\n    }\n\n    /**\n     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients\n     * are aware of the ERC721 protocol to prevent tokens from being forever locked.\n     *\n     * `_data` is additional data, it has no specified format and it is sent in call to `to`.\n     *\n     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.\n     * implement alternative mechanisms to perform token transfer, such as signature-based.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must exist and be owned by `from`.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function _safeTransfer(\n        address from,\n        address to,\n        uint256 tokenId,\n        bytes memory _data\n    ) internal virtual {\n        _transfer(from, to, tokenId);\n        require(\n            _checkOnERC721Received(from, to, tokenId, _data),\n            \"ERC721: transfer to non ERC721Receiver implementer\"\n        );\n    }\n\n    /**\n     * @dev Returns whether `tokenId` exists.\n     *\n     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.\n     *\n     * Tokens start existing when they are minted (`_mint`),\n     * and stop existing when they are burned (`_burn`).\n     */\n    function _exists(uint256 tokenId) internal view virtual returns (bool) {\n        return tokenId < _owners.length && _owners[tokenId] != address(0);\n    }\n\n    /**\n     * @dev Returns whether `spender` is allowed to manage `tokenId`.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     */\n    function _isApprovedOrOwner(address spender, uint256 tokenId)\n        internal\n        view\n        virtual\n        returns (bool)\n    {\n        require(\n            _exists(tokenId),\n            \"ERC721: operator query for nonexistent token\"\n        );\n        address owner = ERC721.ownerOf(tokenId);\n        return (spender == owner ||\n            getApproved(tokenId) == spender ||\n            isApprovedForAll(owner, spender));\n    }\n\n    /**\n     * @dev Safely mints `tokenId` and transfers it to `to`.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must not exist.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function _safeMint(address to, uint256 tokenId) internal virtual {\n        _safeMint(to, tokenId, \"\");\n    }\n\n    /**\n     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is\n     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.\n     */\n    function _safeMint(\n        address to,\n        uint256 tokenId,\n        bytes memory _data\n    ) internal virtual {\n        _mint(to, tokenId);\n        require(\n            _checkOnERC721Received(address(0), to, tokenId, _data),\n            \"ERC721: transfer to non ERC721Receiver implementer\"\n        );\n    }\n\n    /**\n     * @dev Mints `tokenId` and transfers it to `to`.\n     *\n     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible\n     *\n     * Requirements:\n     *\n     * - `tokenId` must not exist.\n     * - `to` cannot be the zero address.\n     *\n     * Emits a {Transfer} event.\n     */\n    function _mint(address to, uint256 tokenId) internal virtual {\n        require(to != address(0), \"ERC721: mint to the zero address\");\n        require(!_exists(tokenId), \"ERC721: token already minted\");\n\n        _beforeTokenTransfer(address(0), to, tokenId);\n        _owners.push(to);\n\n        emit Transfer(address(0), to, tokenId);\n    }\n\n    /**\n     * @dev Destroys `tokenId`.\n     * The approval is cleared when the token is burned.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     *\n     * Emits a {Transfer} event.\n     */\n    function _burn(uint256 tokenId) internal virtual {\n        address owner = ERC721.ownerOf(tokenId);\n\n        _beforeTokenTransfer(owner, address(0), tokenId);\n\n        // Clear approvals\n        _approve(address(0), tokenId);\n        _owners[tokenId] = address(0);\n\n        emit Transfer(owner, address(0), tokenId);\n    }\n\n    /**\n     * @dev Transfers `tokenId` from `from` to `to`.\n     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.\n     *\n     * Requirements:\n     *\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must be owned by `from`.\n     *\n     * Emits a {Transfer} event.\n     */\n    function _transfer(\n        address from,\n        address to,\n        uint256 tokenId\n    ) internal virtual {\n        require(\n            ERC721.ownerOf(tokenId) == from,\n            \"ERC721: transfer of token that is not own\"\n        );\n        require(to != address(0), \"ERC721: transfer to the zero address\");\n\n        _beforeTokenTransfer(from, to, tokenId);\n\n        // Clear approvals from the previous owner\n        _approve(address(0), tokenId);\n        _owners[tokenId] = to;\n\n        emit Transfer(from, to, tokenId);\n    }\n\n    /**\n     * @dev Approve `to` to operate on `tokenId`\n     *\n     * Emits a {Approval} event.\n     */\n    function _approve(address to, uint256 tokenId) internal virtual {\n        _tokenApprovals[tokenId] = to;\n        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);\n    }\n\n    /**\n     * @dev Approve `operator` to operate on all of `owner` tokens\n     *\n     * Emits a {ApprovalForAll} event.\n     */\n    function _setApprovalForAll(\n        address owner,\n        address operator,\n        bool approved\n    ) internal virtual {\n        require(owner != operator, \"ERC721: approve to caller\");\n        _operatorApprovals[owner][operator] = approved;\n        emit ApprovalForAll(owner, operator, approved);\n    }\n\n    /**\n     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.\n     * The call is not executed if the target address is not a contract.\n     *\n     * @param from address representing the previous owner of the given token ID\n     * @param to target address that will receive the tokens\n     * @param tokenId uint256 ID of the token to be transferred\n     * @param _data bytes optional data to send along with the call\n     * @return bool whether the call correctly returned the expected magic value\n     */\n    function _checkOnERC721Received(\n        address from,\n        address to,\n        uint256 tokenId,\n        bytes memory _data\n    ) private returns (bool) {\n        if (to.isContract()) {\n            try\n                IERC721Receiver(to).onERC721Received(\n                    _msgSender(),\n                    from,\n                    tokenId,\n                    _data\n                )\n            returns (bytes4 retval) {\n                return retval == IERC721Receiver.onERC721Received.selector;\n            } catch (bytes memory reason) {\n                if (reason.length == 0) {\n                    revert(\n                        \"ERC721: transfer to non ERC721Receiver implementer\"\n                    );\n                } else {\n                    assembly {\n                        revert(add(32, reason), mload(reason))\n                    }\n                }\n            }\n        } else {\n            return true;\n        }\n    }\n\n    /**\n     * @dev Hook that is called before any token transfer. This includes minting\n     * and burning.\n     *\n     * Calling conditions:\n     *\n     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be\n     * transferred to `to`.\n     * - When `from` is zero, `tokenId` will be minted for `to`.\n     * - When `to` is zero, ``from``'s `tokenId` will be burned.\n     * - `from` and `to` are never both zero.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _beforeTokenTransfer(\n        address from,\n        address to,\n        uint256 tokenId\n    ) internal virtual {}\n}"
    },
    "src/ERC721Enumerable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.6;\n\nimport \"@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol\";\nimport \"./ERC721.sol\";\n\n/**\n * @dev This implements an optional extension of {ERC721} defined in the EIP that adds\n * enumerability of all the token ids in the contract as well as all token ids owned by each\n * account but takes out gas wasting redundancies from OG openzeppelin implementation.\n */\nabstract contract ERC721Enumerable is ERC721, IERC721Enumerable {\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {\n        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);\n    }\n\n    /**\n     * @dev See {IERC721Enumerable-totalSupply}.\n     */\n    function totalSupply() public view virtual override returns (uint256) {\n        return _owners.length;\n    }\n\n    /**\n     * @dev See {IERC721Enumerable-tokenByIndex}.\n     */\n    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {\n        require(index < _owners.length, \"ERC721Enumerable: global index out of bounds\");\n        return index;\n    }\n\n    /**\n     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.\n     */\n    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256 tokenId) {\n        require(index < balanceOf(owner), \"ERC721Enumerable: owner index out of bounds\");\n\n        uint count;\n        for(uint i; i < _owners.length; i++){\n            if(owner == _owners[i]){\n                if(count == index) return i;\n                else count++;\n            }\n        }\n\n        revert(\"ERC721Enumerable: owner index out of bounds\");\n    }\n}"
    }
  }
}}