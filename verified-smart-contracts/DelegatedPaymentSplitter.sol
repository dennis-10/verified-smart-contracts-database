{{
  "language": "Solidity",
  "sources": {
    "github/divergencetech/ethier/factories/finance/DelegatedPaymentSplitter.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// Copyright (c) 2022 the ethier authors (github.com/divergencetech/ethier)\npragma solidity >=0.8.0 <0.9.0;\n\nimport \"@openzeppelin/contracts-upgradeable/finance/PaymentSplitterUpgradeable.sol\";\n\n/**\n@notice This contract functions identically to a standard OpenZeppelin\nPaymentSplitter except that it can be cheaply cloned and deployed via the\nPaymentSplitterFactory. The upgradeable functionality is not used, but is\nrequired for cloning with an EIP-1677 minimal contract proxy.\n@dev Cloning only replicates the implementation logic, but not the data\nassociated with each clone. See EIP-1677 for details.\n\nNOTE: there is likely no need to import this contract directly; instead see the\nethier documentation for the deployed factory addresses.\n */\ncontract DelegatedPaymentSplitter is PaymentSplitterUpgradeable {\n    /**\n    @dev Initializes the PaymentSplitter, akin to a constructor. MUST be called\n    by the Factory, in the same transaction as deployment, as there are no\n    protections in place.\n     */\n    function initialize(address[] memory payees, uint256[] memory shares)\n        external\n        payable\n        initializer\n    {\n        __PaymentSplitter_init(payees, shares);\n    }\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/finance/PaymentSplitterUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (finance/PaymentSplitter.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../token/ERC20/utils/SafeERC20Upgradeable.sol\";\nimport \"../utils/AddressUpgradeable.sol\";\nimport \"../utils/ContextUpgradeable.sol\";\nimport \"../proxy/utils/Initializable.sol\";\n\n/**\n * @title PaymentSplitter\n * @dev This contract allows to split Ether payments among a group of accounts. The sender does not need to be aware\n * that the Ether will be split in this way, since it is handled transparently by the contract.\n *\n * The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each\n * account to a number of shares. Of all the Ether that this contract receives, each account will then be able to claim\n * an amount proportional to the percentage of total shares they were assigned.\n *\n * `PaymentSplitter` follows a _pull payment_ model. This means that payments are not automatically forwarded to the\n * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {release}\n * function.\n *\n * NOTE: This contract assumes that ERC20 tokens will behave similarly to native tokens (Ether). Rebasing tokens, and\n * tokens that apply fees during transfers, are likely to not be supported as expected. If in doubt, we encourage you\n * to run tests before sending real value to this contract.\n */\ncontract PaymentSplitterUpgradeable is Initializable, ContextUpgradeable {\n    event PayeeAdded(address account, uint256 shares);\n    event PaymentReleased(address to, uint256 amount);\n    event ERC20PaymentReleased(IERC20Upgradeable indexed token, address to, uint256 amount);\n    event PaymentReceived(address from, uint256 amount);\n\n    uint256 private _totalShares;\n    uint256 private _totalReleased;\n\n    mapping(address => uint256) private _shares;\n    mapping(address => uint256) private _released;\n    address[] private _payees;\n\n    mapping(IERC20Upgradeable => uint256) private _erc20TotalReleased;\n    mapping(IERC20Upgradeable => mapping(address => uint256)) private _erc20Released;\n\n    /**\n     * @dev Creates an instance of `PaymentSplitter` where each account in `payees` is assigned the number of shares at\n     * the matching position in the `shares` array.\n     *\n     * All addresses in `payees` must be non-zero. Both arrays must have the same non-zero length, and there must be no\n     * duplicates in `payees`.\n     */\n    function __PaymentSplitter_init(address[] memory payees, uint256[] memory shares_) internal onlyInitializing {\n        __Context_init_unchained();\n        __PaymentSplitter_init_unchained(payees, shares_);\n    }\n\n    function __PaymentSplitter_init_unchained(address[] memory payees, uint256[] memory shares_) internal onlyInitializing {\n        require(payees.length == shares_.length, \"PaymentSplitter: payees and shares length mismatch\");\n        require(payees.length > 0, \"PaymentSplitter: no payees\");\n\n        for (uint256 i = 0; i < payees.length; i++) {\n            _addPayee(payees[i], shares_[i]);\n        }\n    }\n\n    /**\n     * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully\n     * reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the\n     * reliability of the events, and not the actual splitting of Ether.\n     *\n     * To learn more about this see the Solidity documentation for\n     * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback\n     * functions].\n     */\n    receive() external payable virtual {\n        emit PaymentReceived(_msgSender(), msg.value);\n    }\n\n    /**\n     * @dev Getter for the total shares held by payees.\n     */\n    function totalShares() public view returns (uint256) {\n        return _totalShares;\n    }\n\n    /**\n     * @dev Getter for the total amount of Ether already released.\n     */\n    function totalReleased() public view returns (uint256) {\n        return _totalReleased;\n    }\n\n    /**\n     * @dev Getter for the total amount of `token` already released. `token` should be the address of an IERC20\n     * contract.\n     */\n    function totalReleased(IERC20Upgradeable token) public view returns (uint256) {\n        return _erc20TotalReleased[token];\n    }\n\n    /**\n     * @dev Getter for the amount of shares held by an account.\n     */\n    function shares(address account) public view returns (uint256) {\n        return _shares[account];\n    }\n\n    /**\n     * @dev Getter for the amount of Ether already released to a payee.\n     */\n    function released(address account) public view returns (uint256) {\n        return _released[account];\n    }\n\n    /**\n     * @dev Getter for the amount of `token` tokens already released to a payee. `token` should be the address of an\n     * IERC20 contract.\n     */\n    function released(IERC20Upgradeable token, address account) public view returns (uint256) {\n        return _erc20Released[token][account];\n    }\n\n    /**\n     * @dev Getter for the address of the payee number `index`.\n     */\n    function payee(uint256 index) public view returns (address) {\n        return _payees[index];\n    }\n\n    /**\n     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the\n     * total shares and their previous withdrawals.\n     */\n    function release(address payable account) public virtual {\n        require(_shares[account] > 0, \"PaymentSplitter: account has no shares\");\n\n        uint256 totalReceived = address(this).balance + totalReleased();\n        uint256 payment = _pendingPayment(account, totalReceived, released(account));\n\n        require(payment != 0, \"PaymentSplitter: account is not due payment\");\n\n        _released[account] += payment;\n        _totalReleased += payment;\n\n        AddressUpgradeable.sendValue(account, payment);\n        emit PaymentReleased(account, payment);\n    }\n\n    /**\n     * @dev Triggers a transfer to `account` of the amount of `token` tokens they are owed, according to their\n     * percentage of the total shares and their previous withdrawals. `token` must be the address of an IERC20\n     * contract.\n     */\n    function release(IERC20Upgradeable token, address account) public virtual {\n        require(_shares[account] > 0, \"PaymentSplitter: account has no shares\");\n\n        uint256 totalReceived = token.balanceOf(address(this)) + totalReleased(token);\n        uint256 payment = _pendingPayment(account, totalReceived, released(token, account));\n\n        require(payment != 0, \"PaymentSplitter: account is not due payment\");\n\n        _erc20Released[token][account] += payment;\n        _erc20TotalReleased[token] += payment;\n\n        SafeERC20Upgradeable.safeTransfer(token, account, payment);\n        emit ERC20PaymentReleased(token, account, payment);\n    }\n\n    /**\n     * @dev internal logic for computing the pending payment of an `account` given the token historical balances and\n     * already released amounts.\n     */\n    function _pendingPayment(\n        address account,\n        uint256 totalReceived,\n        uint256 alreadyReleased\n    ) private view returns (uint256) {\n        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;\n    }\n\n    /**\n     * @dev Add a new payee to the contract.\n     * @param account The address of the payee to add.\n     * @param shares_ The number of shares owned by the payee.\n     */\n    function _addPayee(address account, uint256 shares_) private {\n        require(account != address(0), \"PaymentSplitter: account is the zero address\");\n        require(shares_ > 0, \"PaymentSplitter: shares are 0\");\n        require(_shares[account] == 0, \"PaymentSplitter: account already has shares\");\n\n        _payees.push(account);\n        _shares[account] = shares_;\n        _totalShares = _totalShares + shares_;\n        emit PayeeAdded(account, shares_);\n    }\n    uint256[43] private __gap;\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../../utils/AddressUpgradeable.sol\";\n\n/**\n * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed\n * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an\n * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer\n * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.\n *\n * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as\n * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.\n *\n * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure\n * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.\n *\n * [CAUTION]\n * ====\n * Avoid leaving a contract uninitialized.\n *\n * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation\n * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the\n * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:\n *\n * [.hljs-theme-light.nopadding]\n * ```\n * /// @custom:oz-upgrades-unsafe-allow constructor\n * constructor() initializer {}\n * ```\n * ====\n */\nabstract contract Initializable {\n    /**\n     * @dev Indicates that the contract has been initialized.\n     */\n    bool private _initialized;\n\n    /**\n     * @dev Indicates that the contract is in the process of being initialized.\n     */\n    bool private _initializing;\n\n    /**\n     * @dev Modifier to protect an initializer function from being invoked twice.\n     */\n    modifier initializer() {\n        // If the contract is initializing we ignore whether _initialized is set in order to support multiple\n        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the\n        // contract may have been reentered.\n        require(_initializing ? _isConstructor() : !_initialized, \"Initializable: contract is already initialized\");\n\n        bool isTopLevelCall = !_initializing;\n        if (isTopLevelCall) {\n            _initializing = true;\n            _initialized = true;\n        }\n\n        _;\n\n        if (isTopLevelCall) {\n            _initializing = false;\n        }\n    }\n\n    /**\n     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the\n     * {initializer} modifier, directly or indirectly.\n     */\n    modifier onlyInitializing() {\n        require(_initializing, \"Initializable: contract is not initializing\");\n        _;\n    }\n\n    function _isConstructor() private view returns (bool) {\n        return !AddressUpgradeable.isContract(address(this));\n    }\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\nimport \"../proxy/utils/Initializable.sol\";\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract ContextUpgradeable is Initializable {\n    function __Context_init() internal onlyInitializing {\n        __Context_init_unchained();\n    }\n\n    function __Context_init_unchained() internal onlyInitializing {\n    }\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n    uint256[50] private __gap;\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary AddressUpgradeable {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize, which returns 0 for contracts in\n        // construction, since the code is only stored at the end of the\n        // constructor execution.\n\n        uint256 size;\n        assembly {\n            size := extcodesize(account)\n        }\n        return size > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../IERC20Upgradeable.sol\";\nimport \"../../../utils/AddressUpgradeable.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20Upgradeable {\n    using AddressUpgradeable for address;\n\n    function safeTransfer(\n        IERC20Upgradeable token,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n    }\n\n    function safeTransferFrom(\n        IERC20Upgradeable token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    /**\n     * @dev Deprecated. This function has issues similar to the ones found in\n     * {IERC20-approve}, and its usage is discouraged.\n     *\n     * Whenever possible, use {safeIncreaseAllowance} and\n     * {safeDecreaseAllowance} instead.\n     */\n    function safeApprove(\n        IERC20Upgradeable token,\n        address spender,\n        uint256 value\n    ) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'\n        require(\n            (value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n\n    function safeIncreaseAllowance(\n        IERC20Upgradeable token,\n        address spender,\n        uint256 value\n    ) internal {\n        uint256 newAllowance = token.allowance(address(this), spender) + value;\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    function safeDecreaseAllowance(\n        IERC20Upgradeable token,\n        address spender,\n        uint256 value\n    ) internal {\n        unchecked {\n            uint256 oldAllowance = token.allowance(address(this), spender);\n            require(oldAllowance >= value, \"SafeERC20: decreased allowance below zero\");\n            uint256 newAllowance = oldAllowance - value;\n            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n        }\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that\n        // the target address contains contract code and also asserts for success in the low-level call.\n\n        bytes memory returndata = address(token).functionCall(data, \"SafeERC20: low-level call failed\");\n        if (returndata.length > 0) {\n            // Return data is optional\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20Upgradeable {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 42949672
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