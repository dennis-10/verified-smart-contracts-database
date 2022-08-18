{"MOZVesting.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.5;\n\nimport \"./Ownable.sol\";\nimport \"./ReentrancyGuard.sol\";\nimport \"./TransferHelper.sol\";\n\ninterface Token {\n    function decimals() external view returns (uint256);\n\n    function balanceOf(address who) external view returns (uint256);\n\n    function totalsupply() external view returns (uint256);\n\n    function mint(address to, uint256 value) external returns (bool success);\n\n    function allowance(address owner, address spender)\n        external\n        view\n        returns (uint256);\n}\n\ncontract MOZVesting is Ownable, ReentrancyGuard {\n    address public teamAllocationAddress =\n        0xAf806721C80fF71EEebA33e9Ceb81e1facD7c63b;\n    address public mozTokenAddress;\n    struct UserInfo {\n        uint256 totalTokens;\n        uint256 claimedAmount;\n    }\n    mapping(address =\u003e UserInfo) public userMapping;\n\n    //teamAllocation Time\n    uint64 vestingPoint1 = 1644451200; //10-02-2022\n    uint64 vestingPoint2 = 1675987200; //10-02-2023\n    uint64 vestingPoint3 = 1707523200; //10-02-2024\n    uint64 vestingPoint4 = 1739145600; //10-02-2025\n\n    constructor(address _mozTokenAddress) {\n        mozTokenAddress = _mozTokenAddress;\n        updateInfo(2_000_000_000, teamAllocationAddress);\n    }\n\n    function updateInfo(uint256 _totalTokens, address _userAddress) internal {\n        UserInfo memory uInfo = UserInfo({\n            totalTokens: _totalTokens * (10**Token(mozTokenAddress).decimals()),\n            claimedAmount: 0\n        });\n        userMapping[_userAddress] = uInfo;\n    }\n\n    function claimTokens() external {\n        require((msg.sender == teamAllocationAddress), \"Invalid Address\");\n        UserInfo storage uInfo = userMapping[msg.sender];\n        uint256 userTokens = calculateTokens();\n        require(userTokens != 0, \"Cannot Claim\");\n        TransferHelper.safeTransfer(mozTokenAddress, msg.sender, userTokens);\n        uInfo.claimedAmount = uInfo.claimedAmount + userTokens;\n    }\n\n    function calculateTokens() public view returns (uint256) {\n        UserInfo memory uInfo = userMapping[teamAllocationAddress];\n        uint256 tokenAmount;\n        if (uint64(block.timestamp) \u003e vestingPoint4) {\n            tokenAmount = uInfo.totalTokens - uInfo.claimedAmount;\n        } else if (uint64(block.timestamp) \u003e vestingPoint3) {\n            tokenAmount =\n                ((70 * uInfo.totalTokens) / 100) -\n                uInfo.claimedAmount;\n        } else if (uint64(block.timestamp) \u003e vestingPoint2) {\n            tokenAmount =\n                ((40 * uInfo.totalTokens) / 100) -\n                uInfo.claimedAmount;\n        } else if (uint64(block.timestamp) \u003e vestingPoint1) {\n            tokenAmount =\n                ((10 * uInfo.totalTokens) / 100) -\n                uInfo.claimedAmount;\n        }\n        return (tokenAmount);\n    }\n\n    function updateMozAddress(address _mozTokenAddress) external onlyOwner {\n        mozTokenAddress = _mozTokenAddress;\n    }\n\n    function updateTeamAllocationAddress(address _teamAllocationAddress)\n        external\n        onlyOwner\n    {\n        teamAllocationAddress = _teamAllocationAddress;\n    }\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.5;\n\ncontract Ownable {\n    address public owner;\n\n    event OwnershipTransferred(\n        address indexed previousOwner,\n        address indexed newOwner\n    );\n\n    /**\n     * @dev The Ownable constructor sets the original `owner` of the contract to the sender\n     * account.\n     */\n    constructor() {\n        _setOwner(msg.sender);\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(msg.sender == owner, \"Only owner Access\");\n        _;\n    }\n\n    /**\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\n     * @param newOwner The address to transfer ownership to.\n     */\n    function transferOwnership(address newOwner) public onlyOwner {\n        require(newOwner != address(0));\n        emit OwnershipTransferred(owner, newOwner);\n        owner = newOwner;\n    }\n\n    function _setOwner(address newOwner) internal {\n        owner = newOwner;\n    }\n}\n\n"},"ReentrancyGuard.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot\u0027s contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler\u0027s defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction\u0027s gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant _NOT_ENTERED = 1;\n    uint256 private constant _ENTERED = 2;\n\n    uint256 private _status;\n\n    constructor () {\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and make it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        // On the first call to nonReentrant, _notEntered will be true\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\n\n        // Any calls to nonReentrant after this point will fail\n        _status = _ENTERED;\n\n        _;\n\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = _NOT_ENTERED;\n    }\n}\n\n\n"},"TransferHelper.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.5;\n\n// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false\nlibrary TransferHelper {\n    function safeApprove(\n        address token,\n        address to,\n        uint256 value\n    ) internal {\n        // bytes4(keccak256(bytes(\u0027approve(address,uint256)\u0027)));\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));\n        require(\n            success \u0026\u0026 (data.length == 0 || abi.decode(data, (bool))),\n            \u0027TransferHelper::safeApprove: approve failed\u0027\n        );\n    }\n\n    function safeTransfer(\n        address token,\n        address to,\n        uint256 value\n    ) internal {\n        // bytes4(keccak256(bytes(\u0027transfer(address,uint256)\u0027)));\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));\n        require(\n            success \u0026\u0026 (data.length == 0 || abi.decode(data, (bool))),\n            \u0027TransferHelper::safeTransfer: transfer failed\u0027\n        );\n    }\n\n    function safeTransferFrom(\n        address token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        // bytes4(keccak256(bytes(\u0027transferFrom(address,address,uint256)\u0027)));\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));\n        require(\n            success \u0026\u0026 (data.length == 0 || abi.decode(data, (bool))),\n            \u0027TransferHelper::transferFrom: transferFrom failed\u0027\n        );\n    }\n\n    function safeTransferETH(address to, uint256 value) internal {\n        (bool success, ) = to.call{value: value}(new bytes(0));\n        require(success, \u0027TransferHelper::safeTransferETH: ETH transfer failed\u0027);\n    }\n}\n\n\n\n"}}