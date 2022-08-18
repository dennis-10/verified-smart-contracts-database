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
    "contracts/SuperglyphsRoyaltiesOverride.sol": {
      "content": "//SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\n/// @title SuperglyphsRoyaltiesOverride\n/// @author Simon Fremaux (@dievardump)\ncontract SuperglyphsRoyaltiesOverride {\n    address public immutable nftContract;\n    address public immutable moduleContract;\n\n    constructor(address nftContract_, address moduleContract_) {\n        nftContract = nftContract_;\n        moduleContract = moduleContract_;\n    }\n\n    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {\n        return\n            interfaceId == this.royaltyInfo.selector ||\n            interfaceId == this.supportsInterface.selector;\n    }\n\n    function royaltyInfo(uint256 tokenId, uint256 value)\n        public\n        view\n        returns (address recipient, uint256 amount)\n    {\n        // first get royalties info from the nft contract\n        (recipient, amount) = SuperglyphsRoyaltiesOverride(nftContract)\n            .royaltyInfo(tokenId, value);\n\n        // if the recipient is the SuperglyphModule itself, this means the token hasn't been frozen\n        // so we must return the contract owner instead of the contract address\n        //\n        // because I have been dumb enough to forget to add withdraw for ERC20 in the contract itself\n        // meaning: royalties paid in ERC20 (or others) and not in ETH will be locked forever in the contract\n        //\n        // I'm hoping to save some of them by creating this override.\n        // Marketplaces using the RoyaltyRegistry will work\n        if (recipient == moduleContract) {\n            recipient = IOwnable(moduleContract).owner();\n        }\n    }\n}\n\ninterface IOwnable {\n    function owner() external view returns (address);\n}\n"
    }
  }
}}