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
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize, which returns 0 for contracts in\n        // construction, since the code is only stored at the end of the\n        // constructor execution.\n\n        uint256 size;\n        assembly {\n            size := extcodesize(account)\n        }\n        return size > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "contracts/Donation.sol": {
      "content": "//SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"@openzeppelin/contracts/utils/Address.sol\";\nimport \"./DonationErrors.sol\";\n\n/// @title Contract for accepting donations with attributes for the cause\ncontract Donation is Ownable {\n\n\t/// Event emitted when a donation is made to a cause\n\t/// @param donor The donor\n\t/// @param amount The amount of the donation\n\t/// @param cause The cause for the donation\n\tevent DonatedToCause(\n        address indexed donor,\n        uint256 amount,\n        string cause\n    );\n\n\t/// Event emitted when the minimum and maximum donation limits are updated\n\t/// @param newMinimum The new mininimum allowable donation\n\t/// @param newMaximum The new maxinimum allowable donation\n\tevent DonationLimitUpdated(\n\t\tuint256 newMinimum,\n\t\tuint256 newMaximum\n\t);\n\n\t/// Event emitted when the donations are withdrawn\n\t/// @param amount The amount withdrawn\n\tevent DonationsWithdrawn(\n\t\tuint256 amount\n\t);\n\n\t/// Used to regulate the keys in the causesToDonations mapping\n\tuint256 private _mappingVersion;\n\n\t/// The maximum donation allowed by this contract\n\t/// @dev Trailing `_` allows us to pass Slither tests, while also communicating that this value is not public\n    uint256 internal maximumDonation_ = 10 ether;\n\n\t/// The minimum donation allowed by this contract\n\t/// @dev Ensure this is high enough so that most of the transaction is not wasted on gas\n    uint256 internal minimumDonation_ = 0.01 ether;\n\n    /// The total of donations collected per cause\n    /// @dev This value is internal in case subclasses wish to withdraw or otherwise access contract balances that are specific to donations\n\tmapping(bytes32 => uint256) internal causesToDonations_;\n\n    /// Submits a donation to the contract\n    /// @notice Donations outside of minimumDonation() and maximumDonation() are not allowed\n\t/// @param cause The cause for which to donate\n    function donate(string calldata cause) external payable {\n        if (msg.value == 0 || msg.value < minimumDonation_ || msg.value > maximumDonation_) revert InvalidDonationAmount();\n\t\tcausesToDonations_[_keyForCause(cause)] += msg.value;\n\t\temit DonatedToCause(msg.sender, msg.value, cause);\n    }\n\n\t/// Returns the accumulated donations specific to a cause\n\t/// @notice This value may be reset by the owner\n\t/// @param cause The cause for which to display current donations\n\tfunction donationsForCause(string calldata cause) external view returns (uint256) {\n\t\treturn causesToDonations_[_keyForCause(cause)];\n\t}\n\n\t/// Gets the maximum donation allowed by the contract\n\t/// @return The maximum allowable donation\n\tfunction maximumDonation() external view returns (uint256) {\n\t\treturn maximumDonation_;\n\t}\n\n\t/// Gets the minimum donation allowed by the contract\n\t/// @return The minimum allowable donation\n\tfunction minimumDonation() external view returns (uint256) {\n\t\treturn minimumDonation_;\n\t}\n\n\t/// Updates the minimum and maximum donation limits\n\t/// @param minimum The new minimum allowable donation\n\t/// @param maximum The new minimum allowable donation\n\t/// @dev Throws when maximum is less than minimum. You may set both to 0 to pause donations\n\tfunction updateDonationLimits(uint256 minimum, uint256 maximum) external onlyOwner {\n\t\tif (maximum < minimum) revert InvalidLimitsSpecified();\n\t\tmaximumDonation_ = maximum;\n\t\tminimumDonation_ = minimum;\n\t\temit DonationLimitUpdated(minimum, maximum);\n\t}\n\n    /// Withdraws donations to the owner's wallet\n    /// @dev This resets all mappings of causes to donations\n    function withdraw() external onlyOwner {\n\t\t_mappingVersion++;\n\t\temit DonationsWithdrawn(address(this).balance);\n        Address.sendValue(payable(owner()), address(this).balance);\n    }\n\n\t/// Returns the current mapping key for the specified cause\n\t/// @dev internal in case subclassing contracts wish to access the mapping\n\t/// @param cause The cause for which to obtain the mapping's key\n\t/// @return The `bytes32` key to be used in the `_causesToDonations` mapping\n\tfunction _keyForCause(string memory cause) internal view returns (bytes32) {\n\t\tbytes memory causeBytes = bytes(cause);\n\t\tif (causeBytes.length == 0 || causeBytes.length > 32) revert InvalidCause();\n\t\treturn keccak256(abi.encodePacked(_mappingVersion, causeBytes));\n\t}\n}\n"
    },
    "contracts/DonationErrors.sol": {
      "content": "//SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\n/// Error thrown when a call to donate does not have a valid cause\nerror InvalidCause();\n\n/// Error thrown when a call to donate does not include a value\nerror InvalidDonationAmount();\n\n/// Error thrown when a call to update limits contains a maximum that is less than the minimum\nerror InvalidLimitsSpecified();\n"
    }
  }
}}