{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n\tfunction _msgSender() internal view virtual returns (address) {\n\t\treturn msg.sender;\n\t}\n\n\tfunction _msgData() internal view virtual returns (bytes calldata) {\n\t\treturn msg.data;\n\t}\n}\n"},"ITraits.sol":{"content":"// SPDX-License-Identifier: MIT LICENSE\n\npragma solidity ^0.8.0;\n\ninterface ITraits {\n\tfunction tokenURI(uint256 tokenId) external view returns (string memory);\n}\n"},"IWoolf.sol":{"content":"// SPDX-License-Identifier: MIT LICENSE\n\npragma solidity ^0.8.0;\n\ninterface IWoolf {\n\t// struct to store each token\u0027s traits\n\tstruct ApeWolf {\n\t\tbool isApe;\n\t\tuint8 skin;\n\t\tuint8 eyes;\n\t\tuint8 mouth;\n\t\tuint8 clothing;\n\t\tuint8 headwear;\n\t\tuint8 alphaIndex;\n\t}\n\n\tfunction getPaidTokens() external view returns (uint256);\n\n\tfunction getTokenTraits(uint256 tokenId) external view returns (ApeWolf memory);\n\n\tfunction ownerOf(uint256 tokenId) external view returns (address owner);\n\n\tfunction transferFrom(\n\t\taddress from,\n\t\taddress to,\n\t\tuint256 tokenId\n\t) external;\n\n\tfunction safeTransferFrom(\n\t\taddress from,\n\t\taddress to,\n\t\tuint256 tokenId,\n\t\tbytes calldata data\n\t) external;\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n\taddress private _owner;\n\n\tevent OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n\t/**\n\t * @dev Initializes the contract setting the deployer as the initial owner.\n\t */\n\tconstructor() {\n\t\t_setOwner(_msgSender());\n\t}\n\n\t/**\n\t * @dev Returns the address of the current owner.\n\t */\n\tfunction owner() public view virtual returns (address) {\n\t\treturn _owner;\n\t}\n\n\t/**\n\t * @dev Throws if called by any account other than the owner.\n\t */\n\tmodifier onlyOwner() {\n\t\trequire(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n\t\t_;\n\t}\n\n\t/**\n\t * @dev Leaves the contract without owner. It will not be possible to call\n\t * `onlyOwner` functions anymore. Can only be called by the current owner.\n\t *\n\t * NOTE: Renouncing ownership will leave the contract without an owner,\n\t * thereby removing any functionality that is only available to the owner.\n\t */\n\tfunction renounceOwnership() public virtual onlyOwner {\n\t\t_setOwner(address(0));\n\t}\n\n\t/**\n\t * @dev Transfers ownership of the contract to a new account (`newOwner`).\n\t * Can only be called by the current owner.\n\t */\n\tfunction transferOwnership(address newOwner) public virtual onlyOwner {\n\t\trequire(newOwner != address(0), \"Ownable: new owner is the zero address\");\n\t\t_setOwner(newOwner);\n\t}\n\n\tfunction _setOwner(address newOwner) private {\n\t\taddress oldOwner = _owner;\n\t\t_owner = newOwner;\n\t\temit OwnershipTransferred(oldOwner, newOwner);\n\t}\n}\n"},"Strings.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev String operations.\n */\nlibrary Strings {\n\tbytes16 private constant _HEX_SYMBOLS = \"0123456789abcdef\";\n\n\t/**\n\t * @dev Converts a `uint256` to its ASCII `string` decimal representation.\n\t */\n\tfunction toString(uint256 value) internal pure returns (string memory) {\n\t\t// Inspired by OraclizeAPI\u0027s implementation - MIT licence\n\t\t// https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol\n\n\t\tif (value == 0) {\n\t\t\treturn \"0\";\n\t\t}\n\t\tuint256 temp = value;\n\t\tuint256 digits;\n\t\twhile (temp != 0) {\n\t\t\tdigits++;\n\t\t\ttemp /= 10;\n\t\t}\n\t\tbytes memory buffer = new bytes(digits);\n\t\twhile (value != 0) {\n\t\t\tdigits -= 1;\n\t\t\tbuffer[digits] = bytes1(uint8(48 + uint256(value % 10)));\n\t\t\tvalue /= 10;\n\t\t}\n\t\treturn string(buffer);\n\t}\n\n\t/**\n\t * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.\n\t */\n\tfunction toHexString(uint256 value) internal pure returns (string memory) {\n\t\tif (value == 0) {\n\t\t\treturn \"0x00\";\n\t\t}\n\t\tuint256 temp = value;\n\t\tuint256 length = 0;\n\t\twhile (temp != 0) {\n\t\t\tlength++;\n\t\t\ttemp \u003e\u003e= 8;\n\t\t}\n\t\treturn toHexString(value, length);\n\t}\n\n\t/**\n\t * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.\n\t */\n\tfunction toHexString(uint256 value, uint256 length) internal pure returns (string memory) {\n\t\tbytes memory buffer = new bytes(2 * length + 2);\n\t\tbuffer[0] = \"0\";\n\t\tbuffer[1] = \"x\";\n\t\tfor (uint256 i = 2 * length + 1; i \u003e 1; --i) {\n\t\t\tbuffer[i] = _HEX_SYMBOLS[value \u0026 0xf];\n\t\t\tvalue \u003e\u003e= 4;\n\t\t}\n\t\trequire(value == 0, \"Strings: hex length insufficient\");\n\t\treturn string(buffer);\n\t}\n}\n"},"Traits.sol":{"content":"// SPDX-License-Identifier: MIT LICENSE\n\npragma solidity ^0.8.0;\nimport \"./Ownable.sol\";\nimport \"./Strings.sol\";\nimport \"./ITraits.sol\";\nimport \"./IWoolf.sol\";\n\ncontract Traits is Ownable, ITraits {\n\tusing Strings for uint256;\n\n\t// struct to store each trait\u0027s data for metadata and rendering\n\tstruct Trait {\n\t\tstring name;\n\t\tstring png;\n\t}\n\tstring private baseURI;\n\tuint256 public number;\n\n\t// mapping from trait type (index) to its name\n\tstring[6] _traitTypes = [\"Skin\", \"Eyes\", \"Mouth\", \"clothing\", \"Headwear\", \"Alpha\"];\n\t// storage of each traits name and base64 PNG data\n\tmapping(uint8 =\u003e mapping(uint8 =\u003e Trait)) public traitData;\n\t// mapping from alphaIndex to its score\n\tstring[4] _alphas = [\"8\", \"7\", \"6\", \"5\"];\n\n\tIWoolf public woolf;\n\n\tconstructor() {}\n\n\t/** ADMIN */\n\n\tfunction setWoolf(address _woolf) external onlyOwner {\n\t\twoolf = IWoolf(_woolf);\n\t}\n\n\t/**\n\t * administrative to upload the names and images associated with each trait\n\t * @param traitType the trait type to upload the traits for (see traitTypes for a mapping)\n\t * @param traits the names and base64 encoded PNGs for each trait\n\t */\n\tfunction uploadTraits(\n\t\tuint8 traitType,\n\t\tuint8[] calldata traitIds,\n\t\tTrait[] calldata traits\n\t) external onlyOwner {\n\t\trequire(traitIds.length == traits.length, \"Mismatched inputs\");\n\t\tfor (uint256 i = 0; i \u003c traits.length; i++) {\n\t\t\ttraitData[traitType][traitIds[i]] = Trait(traits[i].name, traits[i].png);\n\t\t}\n\t}\n\n\t/** RENDER */\n\n\t/**\n\t * generates an attribute for the attributes array in the ERC721 metadata standard\n\t * @param traitType the trait type to reference as the metadata key\n\t * @param value the token\u0027s trait associated with the key\n\t * @return a JSON dictionary for the single attribute\n\t */\n\tfunction attributeForTypeAndValue(string memory traitType, string memory value) internal pure returns (string memory) {\n\t\treturn string(abi.encodePacked(\u0027{\"trait_type\":\"\u0027, traitType, \u0027\",\"value\":\"\u0027, value, \u0027\"}\u0027));\n\t}\n\n\t/**\n\t * generates an array composed of all the individual traits and values\n\t * @param tokenId the ID of the token to compose the metadata for\n\t * @return a JSON array of all of the attributes for given token ID\n\t */\n\tfunction compileAttributes(uint256 tokenId) public view returns (string memory) {\n\t\tIWoolf.ApeWolf memory s = woolf.getTokenTraits(tokenId);\n\t\tstring memory traits;\n\t\tif (s.isApe) {\n\t\t\ttraits = string(\n\t\t\t\tabi.encodePacked(\n\t\t\t\t\tattributeForTypeAndValue(_traitTypes[0], traitData[0][s.skin].name),\n\t\t\t\t\t\",\",\n\t\t\t\t\tattributeForTypeAndValue(_traitTypes[1], traitData[1][s.eyes].name),\n\t\t\t\t\t\",\",\n\t\t\t\t\tattributeForTypeAndValue(_traitTypes[2], traitData[2][s.mouth].name),\n\t\t\t\t\t\",\",\n\t\t\t\t\tattributeForTypeAndValue(_traitTypes[4], traitData[4][s.headwear].name),\n\t\t\t\t\t\",\"\n\t\t\t\t)\n\t\t\t);\n\t\t} else {\n\t\t\ttraits = string(\n\t\t\t\tabi.encodePacked(\n\t\t\t\t\tattributeForTypeAndValue(_traitTypes[0], traitData[6][s.alphaIndex].name),\n\t\t\t\t\t\",\",\n\t\t\t\t\tattributeForTypeAndValue(_traitTypes[1], traitData[7][s.eyes].name),\n\t\t\t\t\t\",\",\n\t\t\t\t\tattributeForTypeAndValue(_traitTypes[2], traitData[8][s.mouth].name),\n\t\t\t\t\t\",\",\n\t\t\t\t\tattributeForTypeAndValue(_traitTypes[3], traitData[9][s.clothing].name),\n\t\t\t\t\t\",\",\n\t\t\t\t\tattributeForTypeAndValue(_traitTypes[4], traitData[10][s.headwear].name),\n\t\t\t\t\t\",\",\n\t\t\t\t\tattributeForTypeAndValue(\"Alpha Score\", _alphas[s.alphaIndex]),\n\t\t\t\t\t\",\"\n\t\t\t\t)\n\t\t\t);\n\t\t}\n\t\treturn\n\t\t\tstring(\n\t\t\t\tabi.encodePacked(\n\t\t\t\t\t\"[\",\n\t\t\t\t\ttraits,\n\t\t\t\t\t\u0027{\"trait_type\":\"Generation\",\"value\":\u0027,\n\t\t\t\t\ttokenId \u003c= woolf.getPaidTokens() ? \u0027\"Gen 0\"\u0027 : \u0027\"Gen 1\"\u0027,\n\t\t\t\t\t\u0027},{\"trait_type\":\"Type\",\"value\":\u0027,\n\t\t\t\t\ts.isApe ? \u0027\"Ape\"\u0027 : \u0027\"Wolf\"\u0027,\n\t\t\t\t\t\"}]\"\n\t\t\t\t)\n\t\t\t);\n\t}\n\n\tfunction setBaseURI(string calldata _baseURI) external onlyOwner {\n\t\tbaseURI = _baseURI;\n\t}\n\n\tfunction getBaseURI() public view returns (string memory) {\n\t\treturn baseURI;\n\t}\n\n\tfunction setNumber(uint256 _number) external onlyOwner {\n\t\tnumber = _number;\n\t}\n\n\t/**\n\t * generates a base64 encoded metadata response without referencing off-chain content\n\t * @param tokenId the ID of the token to generate the metadata for\n\t * @return a base64 encoded JSON dictionary of the token\u0027s metadata and SVG\n\t */\n\tfunction tokenURI(uint256 tokenId) public view override returns (string memory) {\n\t\tIWoolf.ApeWolf memory s = woolf.getTokenTraits(tokenId);\n\n\t\tstring memory metadata = string(\n\t\t\tabi.encodePacked(\n\t\t\t\t\u0027{\"name\": \"\u0027,\n\t\t\t\ts.isApe ? \"Ape #\" : \"Wolf #\",\n\t\t\t\ttokenId.toString(),\n\t\t\t\t\u0027\", \"description\": \"Thousands of Ape and Wolves compete on a farm in the metaverse. A tempting prize of $MPeach awaits, with deadly high stakes. All the metadata and images are generated and stored 100% on-chain. No IPFS. NO API. Just the Ethereum blockchain.\", \"image\": \"\u0027,\n\t\t\t\tgetBaseURI(),\n\t\t\t\tnumber \u003e= tokenId ? tokenId.toString() : \"0\",\n\t\t\t\t\u0027.png\", \"attributes\":\u0027,\n\t\t\t\tcompileAttributes(tokenId),\n\t\t\t\t\"}\"\n\t\t\t)\n\t\t);\n\n\t\treturn string(abi.encodePacked(\"data:application/json;base64,\", base64(bytes(metadata))));\n\t}\n\n\t/** BASE 64 - Written by Brech Devos */\n\n\tstring internal constant TABLE = \"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/\";\n\n\tfunction base64(bytes memory data) internal pure returns (string memory) {\n\t\tif (data.length == 0) return \"\";\n\n\t\t// load the table into memory\n\t\tstring memory table = TABLE;\n\n\t\t// multiply by 4/3 rounded up\n\t\tuint256 encodedLen = 4 * ((data.length + 2) / 3);\n\n\t\t// add some extra buffer at the end required for the writing\n\t\tstring memory result = new string(encodedLen + 32);\n\n\t\tassembly {\n\t\t\t// set the actual output length\n\t\t\tmstore(result, encodedLen)\n\n\t\t\t// prepare the lookup table\n\t\t\tlet tablePtr := add(table, 1)\n\n\t\t\t// input ptr\n\t\t\tlet dataPtr := data\n\t\t\tlet endPtr := add(dataPtr, mload(data))\n\n\t\t\t// result ptr, jump over length\n\t\t\tlet resultPtr := add(result, 32)\n\n\t\t\t// run over the input, 3 bytes at a time\n\t\t\tfor {\n\n\t\t\t} lt(dataPtr, endPtr) {\n\n\t\t\t} {\n\t\t\t\tdataPtr := add(dataPtr, 3)\n\n\t\t\t\t// read 3 bytes\n\t\t\t\tlet input := mload(dataPtr)\n\n\t\t\t\t// write 4 characters\n\t\t\t\tmstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))\n\t\t\t\tresultPtr := add(resultPtr, 1)\n\t\t\t\tmstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))\n\t\t\t\tresultPtr := add(resultPtr, 1)\n\t\t\t\tmstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F)))))\n\t\t\t\tresultPtr := add(resultPtr, 1)\n\t\t\t\tmstore(resultPtr, shl(248, mload(add(tablePtr, and(input, 0x3F)))))\n\t\t\t\tresultPtr := add(resultPtr, 1)\n\t\t\t}\n\n\t\t\t// padding with \u0027=\u0027\n\t\t\tswitch mod(mload(data), 3)\n\t\t\tcase 1 {\n\t\t\t\tmstore(sub(resultPtr, 2), shl(240, 0x3d3d))\n\t\t\t}\n\t\t\tcase 2 {\n\t\t\t\tmstore(sub(resultPtr, 1), shl(248, 0x3d))\n\t\t\t}\n\t\t}\n\n\t\treturn result;\n\t}\n}\n"}}