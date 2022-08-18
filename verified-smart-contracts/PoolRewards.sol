{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 100
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
    "@openzeppelin/contracts/proxy/utils/Initializable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\n// solhint-disable-next-line compiler-version\npragma solidity ^0.8.0;\n\n/**\n * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed\n * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an\n * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer\n * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.\n *\n * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as\n * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.\n *\n * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure\n * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.\n */\nabstract contract Initializable {\n\n    /**\n     * @dev Indicates that the contract has been initialized.\n     */\n    bool private _initialized;\n\n    /**\n     * @dev Indicates that the contract is in the process of being initialized.\n     */\n    bool private _initializing;\n\n    /**\n     * @dev Modifier to protect an initializer function from being invoked twice.\n     */\n    modifier initializer() {\n        require(_initializing || !_initialized, \"Initializable: contract is already initialized\");\n\n        bool isTopLevelCall = !_initializing;\n        if (isTopLevelCall) {\n            _initializing = true;\n            _initialized = true;\n        }\n\n        _;\n\n        if (isTopLevelCall) {\n            _initializing = false;\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/security/ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant _NOT_ENTERED = 1;\n    uint256 private constant _ENTERED = 2;\n\n    uint256 private _status;\n\n    constructor () {\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and make it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        // On the first call to nonReentrant, _notEntered will be true\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\n\n        // Any calls to nonReentrant after this point will fail\n        _status = _ENTERED;\n\n        _;\n\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = _NOT_ENTERED;\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../IERC20.sol\";\nimport \"../../../utils/Address.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n    using Address for address;\n\n    function safeTransfer(IERC20 token, address to, uint256 value) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n    }\n\n    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    /**\n     * @dev Deprecated. This function has issues similar to the ones found in\n     * {IERC20-approve}, and its usage is discouraged.\n     *\n     * Whenever possible, use {safeIncreaseAllowance} and\n     * {safeDecreaseAllowance} instead.\n     */\n    function safeApprove(IERC20 token, address spender, uint256 value) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'\n        // solhint-disable-next-line max-line-length\n        require((value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n\n    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {\n        uint256 newAllowance = token.allowance(address(this), spender) + value;\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {\n        unchecked {\n            uint256 oldAllowance = token.allowance(address(this), spender);\n            require(oldAllowance >= value, \"SafeERC20: decreased allowance below zero\");\n            uint256 newAllowance = oldAllowance - value;\n            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n        }\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function _callOptionalReturn(IERC20 token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that\n        // the target address contains contract code and also asserts for success in the low-level call.\n\n        bytes memory returndata = address(token).functionCall(data, \"SafeERC20: low-level call failed\");\n        if (returndata.length > 0) { // Return data is optional\n            // solhint-disable-next-line max-line-length\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize, which returns 0 for contracts in\n        // construction, since the code is only stored at the end of the\n        // constructor execution.\n\n        uint256 size;\n        // solhint-disable-next-line no-inline-assembly\n        assembly { size := extcodesize(account) }\n        return size > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value\n        (bool success, ) = recipient.call{ value: amount }(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain`call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n      return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = target.call{ value: value }(data);\n        return _verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return _verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return _verifyCallResult(success, returndata, errorMessage);\n    }\n\n    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                // solhint-disable-next-line no-inline-assembly\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "contracts/interfaces/vesper/IPoolRewards.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.3;\n\ninterface IPoolRewards {\n    /// Emitted after reward added\n    event RewardAdded(address indexed rewardToken, uint256 reward, uint256 rewardDuration);\n    /// Emitted whenever any user claim rewards\n    event RewardPaid(address indexed user, address indexed rewardToken, uint256 reward);\n    /// Emitted after adding new rewards token into rewardTokens array\n    event RewardTokenAdded(address indexed rewardToken, address[] existingRewardTokens);\n\n    function claimReward(address) external;\n\n    function notifyRewardAmount(\n        address _rewardToken,\n        uint256 _rewardAmount,\n        uint256 _rewardDuration\n    ) external;\n\n    function notifyRewardAmount(\n        address[] memory _rewardTokens,\n        uint256[] memory _rewardAmounts,\n        uint256[] memory _rewardDurations\n    ) external;\n\n    function updateReward(address) external;\n\n    function claimable(address _account)\n        external\n        view\n        returns (address[] memory _rewardTokens, uint256[] memory _claimableAmounts);\n\n    function lastTimeRewardApplicable(address _rewardToken) external view returns (uint256);\n\n    function rewardForDuration()\n        external\n        view\n        returns (address[] memory _rewardTokens, uint256[] memory _rewardForDuration);\n\n    function rewardPerToken()\n        external\n        view\n        returns (address[] memory _rewardTokens, uint256[] memory _rewardPerTokenRate);\n}\n"
    },
    "contracts/interfaces/vesper/IVesperPool.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.3;\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\n\ninterface IVesperPool is IERC20 {\n    function deposit() external payable;\n\n    function deposit(uint256 _share) external;\n\n    function multiTransfer(address[] memory _recipients, uint256[] memory _amounts) external returns (bool);\n\n    function excessDebt(address _strategy) external view returns (uint256);\n\n    function permit(\n        address,\n        address,\n        uint256,\n        uint256,\n        uint8,\n        bytes32,\n        bytes32\n    ) external;\n\n    function poolRewards() external returns (address);\n\n    function reportEarning(\n        uint256 _profit,\n        uint256 _loss,\n        uint256 _payback\n    ) external;\n\n    function reportLoss(uint256 _loss) external;\n\n    function resetApproval() external;\n\n    function sweepERC20(address _fromToken) external;\n\n    function withdraw(uint256 _amount) external;\n\n    function withdrawETH(uint256 _amount) external;\n\n    function whitelistedWithdraw(uint256 _amount) external;\n\n    function governor() external view returns (address);\n\n    function keepers() external view returns (address[] memory);\n\n    function isKeeper(address _address) external view returns (bool);\n\n    function maintainers() external view returns (address[] memory);\n\n    function isMaintainer(address _address) external view returns (bool);\n\n    function feeCollector() external view returns (address);\n\n    function pricePerShare() external view returns (uint256);\n\n    function strategy(address _strategy)\n        external\n        view\n        returns (\n            bool _active,\n            uint256 _interestFee,\n            uint256 _debtRate,\n            uint256 _lastRebalance,\n            uint256 _totalDebt,\n            uint256 _totalLoss,\n            uint256 _totalProfit,\n            uint256 _debtRatio\n        );\n\n    function stopEverything() external view returns (bool);\n\n    function token() external view returns (IERC20);\n\n    function tokensHere() external view returns (uint256);\n\n    function totalDebtOf(address _strategy) external view returns (uint256);\n\n    function totalValue() external view returns (uint256);\n\n    function withdrawFee() external view returns (uint256);\n\n    // Function to get pricePerShare from V2 pools\n    function getPricePerShare() external view returns (uint256);\n}\n"
    },
    "contracts/pool/PoolRewards.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.3;\n\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\nimport \"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol\";\nimport \"@openzeppelin/contracts/proxy/utils/Initializable.sol\";\nimport \"@openzeppelin/contracts/security/ReentrancyGuard.sol\";\nimport \"../interfaces/vesper/IPoolRewards.sol\";\nimport \"../interfaces/vesper/IVesperPool.sol\";\n\ncontract PoolRewardsStorage {\n    /// Vesper pool address\n    address public pool;\n\n    /// Array of reward token addresses\n    address[] public rewardTokens;\n\n    /// Reward token to valid/invalid flag mapping\n    mapping(address => bool) public isRewardToken;\n\n    /// Reward token to period ending of current reward\n    mapping(address => uint256) public periodFinish;\n\n    /// Reward token to current reward rate mapping\n    mapping(address => uint256) public rewardRates;\n\n    /// Reward token to Duration of current reward distribution\n    mapping(address => uint256) public rewardDuration;\n\n    /// Reward token to Last reward drip update time stamp mapping\n    mapping(address => uint256) public lastUpdateTime;\n\n    /// Reward token to Reward per token mapping. Calculated and stored at last drip update\n    mapping(address => uint256) public rewardPerTokenStored;\n\n    /// Reward token => User => Reward per token stored at last reward update\n    mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;\n\n    /// RewardToken => User => Rewards earned till last reward update\n    mapping(address => mapping(address => uint256)) public rewards;\n}\n\n/// @title Distribute rewards based on vesper pool balance and supply\ncontract PoolRewards is Initializable, IPoolRewards, ReentrancyGuard, PoolRewardsStorage {\n    string public constant VERSION = \"4.0.0\";\n    using SafeERC20 for IERC20;\n\n    /**\n     * @dev Called by proxy to initialize this contract\n     * @param _pool Vesper pool address\n     * @param _rewardTokens Array of reward token addresses\n     */\n    function initialize(address _pool, address[] memory _rewardTokens) public initializer {\n        require(_pool != address(0), \"pool-address-is-zero\");\n        require(_rewardTokens.length != 0, \"invalid-reward-tokens\");\n        pool = _pool;\n        rewardTokens = _rewardTokens;\n        for (uint256 i = 0; i < _rewardTokens.length; i++) {\n            isRewardToken[_rewardTokens[i]] = true;\n        }\n    }\n\n    modifier onlyAuthorized() {\n        require(msg.sender == IVesperPool(pool).governor(), \"not-authorized\");\n        _;\n    }\n\n    /**\n     * @notice Notify that reward is added. Only authorized caller can call\n     * @dev Also updates reward rate and reward earning period.\n     * @param _rewardTokens Tokens being rewarded\n     * @param _rewardAmounts Rewards amount for token on same index in rewardTokens array\n     * @param _rewardDurations Duration for which reward will be distributed\n     */\n    function notifyRewardAmount(\n        address[] memory _rewardTokens,\n        uint256[] memory _rewardAmounts,\n        uint256[] memory _rewardDurations\n    ) external virtual override onlyAuthorized {\n        _notifyRewardAmount(_rewardTokens, _rewardAmounts, _rewardDurations, IERC20(pool).totalSupply());\n    }\n\n    function notifyRewardAmount(\n        address _rewardToken,\n        uint256 _rewardAmount,\n        uint256 _rewardDuration\n    ) external virtual override onlyAuthorized {\n        _notifyRewardAmount(_rewardToken, _rewardAmount, _rewardDuration, IERC20(pool).totalSupply());\n    }\n\n    /// @notice Add new reward token in existing rewardsToken array\n    function addRewardToken(address _newRewardToken) external onlyAuthorized {\n        require(_newRewardToken != address(0), \"reward-token-address-zero\");\n        require(!isRewardToken[_newRewardToken], \"reward-token-already-exist\");\n        emit RewardTokenAdded(_newRewardToken, rewardTokens);\n        rewardTokens.push(_newRewardToken);\n        isRewardToken[_newRewardToken] = true;\n    }\n\n    /**\n     * @notice Claim earned rewards.\n     * @dev This function will claim rewards for all tokens being rewarded\n     */\n    function claimReward(address _account) external virtual override nonReentrant {\n        uint256 _totalSupply = IERC20(pool).totalSupply();\n        uint256 _balance = IERC20(pool).balanceOf(_account);\n        uint256 _len = rewardTokens.length;\n        for (uint256 i = 0; i < _len; i++) {\n            address _rewardToken = rewardTokens[i];\n            _updateReward(_rewardToken, _account, _totalSupply, _balance);\n\n            // Claim rewards\n            uint256 _reward = rewards[_rewardToken][_account];\n            if (_reward != 0 && _reward <= IERC20(_rewardToken).balanceOf(address(this))) {\n                _claimReward(_rewardToken, _account, _reward);\n                emit RewardPaid(_account, _rewardToken, _reward);\n            }\n        }\n    }\n\n    /**\n     * @notice Updated reward for given account.\n     */\n    function updateReward(address _account) external override {\n        uint256 _totalSupply = IERC20(pool).totalSupply();\n        uint256 _balance = IERC20(pool).balanceOf(_account);\n        uint256 _len = rewardTokens.length;\n        for (uint256 i = 0; i < _len; i++) {\n            _updateReward(rewardTokens[i], _account, _totalSupply, _balance);\n        }\n    }\n\n    /**\n     * @notice Returns claimable reward amount.\n     * @return _rewardTokens Array of tokens being rewarded\n     * @return _claimableAmounts Array of claimable for token on same index in rewardTokens\n     */\n    function claimable(address _account)\n        external\n        view\n        virtual\n        override\n        returns (address[] memory _rewardTokens, uint256[] memory _claimableAmounts)\n    {\n        uint256 _totalSupply = IERC20(pool).totalSupply();\n        uint256 _balance = IERC20(pool).balanceOf(_account);\n        uint256 _len = rewardTokens.length;\n        _claimableAmounts = new uint256[](_len);\n        for (uint256 i = 0; i < _len; i++) {\n            _claimableAmounts[i] = _claimable(rewardTokens[i], _account, _totalSupply, _balance);\n        }\n        _rewardTokens = rewardTokens;\n    }\n\n    /// @notice Provides easy access to all rewardTokens\n    function getRewardTokens() external view returns (address[] memory) {\n        return rewardTokens;\n    }\n\n    /// @notice Returns timestamp of last reward update\n    function lastTimeRewardApplicable(address _rewardToken) public view override returns (uint256) {\n        return block.timestamp < periodFinish[_rewardToken] ? block.timestamp : periodFinish[_rewardToken];\n    }\n\n    function rewardForDuration()\n        external\n        view\n        override\n        returns (address[] memory _rewardTokens, uint256[] memory _rewardForDuration)\n    {\n        uint256 _len = rewardTokens.length;\n        _rewardForDuration = new uint256[](_len);\n        for (uint256 i = 0; i < _len; i++) {\n            _rewardForDuration[i] = rewardRates[rewardTokens[i]] * rewardDuration[rewardTokens[i]];\n        }\n        _rewardTokens = rewardTokens;\n    }\n\n    /**\n     * @notice Rewards rate per pool token\n     * @return _rewardTokens Array of tokens being rewarded\n     * @return _rewardPerTokenRate Array of Rewards rate for token on same index in rewardTokens\n     */\n    function rewardPerToken()\n        external\n        view\n        override\n        returns (address[] memory _rewardTokens, uint256[] memory _rewardPerTokenRate)\n    {\n        uint256 _totalSupply = IERC20(pool).totalSupply();\n        uint256 _len = rewardTokens.length;\n        _rewardPerTokenRate = new uint256[](_len);\n        for (uint256 i = 0; i < _len; i++) {\n            _rewardPerTokenRate[i] = _rewardPerToken(rewardTokens[i], _totalSupply);\n        }\n        _rewardTokens = rewardTokens;\n    }\n\n    function _claimable(\n        address _rewardToken,\n        address _account,\n        uint256 _totalSupply,\n        uint256 _balance\n    ) internal view returns (uint256) {\n        uint256 _rewardPerTokenAvailable =\n            _rewardPerToken(_rewardToken, _totalSupply) - userRewardPerTokenPaid[_rewardToken][_account];\n        uint256 _rewardsEarnedSinceLastUpdate = (_balance * _rewardPerTokenAvailable) / 1e18;\n        return rewards[_rewardToken][_account] + _rewardsEarnedSinceLastUpdate;\n    }\n\n    function _claimReward(\n        address _rewardToken,\n        address _account,\n        uint256 _reward\n    ) internal virtual {\n        // Mark reward as claimed\n        rewards[_rewardToken][_account] = 0;\n        // Transfer reward\n        IERC20(_rewardToken).safeTransfer(_account, _reward);\n    }\n\n    // There are scenarios when extending contract will override external methods and\n    // end up calling internal function. Hence providing internal functions\n    function _notifyRewardAmount(\n        address[] memory _rewardTokens,\n        uint256[] memory _rewardAmounts,\n        uint256[] memory _rewardDurations,\n        uint256 _totalSupply\n    ) internal {\n        uint256 _len = _rewardTokens.length;\n        uint256 _amountsLen = _rewardAmounts.length;\n        uint256 _durationsLen = _rewardDurations.length;\n        require(_len != 0, \"invalid-reward-tokens\");\n        require(_amountsLen != 0, \"invalid-reward-amounts\");\n        require(_durationsLen != 0, \"invalid-reward-durations\");\n        require(_len == _amountsLen && _len == _durationsLen, \"array-length-mismatch\");\n        for (uint256 i = 0; i < _len; i++) {\n            _notifyRewardAmount(_rewardTokens[i], _rewardAmounts[i], _rewardDurations[i], _totalSupply);\n        }\n    }\n\n    function _notifyRewardAmount(\n        address _rewardToken,\n        uint256 _rewardAmount,\n        uint256 _rewardDuration,\n        uint256 _totalSupply\n    ) internal {\n        require(_rewardToken != address(0), \"incorrect-reward-token\");\n        require(_rewardAmount != 0, \"incorrect-reward-amount\");\n        require(_rewardDuration != 0, \"incorrect-reward-duration\");\n        require(isRewardToken[_rewardToken], \"invalid-reward-token\");\n\n        // Update rewards earned so far\n        rewardPerTokenStored[_rewardToken] = _rewardPerToken(_rewardToken, _totalSupply);\n        if (block.timestamp >= periodFinish[_rewardToken]) {\n            rewardRates[_rewardToken] = _rewardAmount / _rewardDuration;\n        } else {\n            uint256 remainingPeriod = periodFinish[_rewardToken] - block.timestamp;\n\n            uint256 leftover = remainingPeriod * rewardRates[_rewardToken];\n            rewardRates[_rewardToken] = (_rewardAmount + leftover) / _rewardDuration;\n        }\n        // Safety check\n        uint256 balance = IERC20(_rewardToken).balanceOf(address(this));\n        require(rewardRates[_rewardToken] <= (balance / _rewardDuration), \"rewards-too-high\");\n        // Start new drip time\n        rewardDuration[_rewardToken] = _rewardDuration;\n        lastUpdateTime[_rewardToken] = block.timestamp;\n        periodFinish[_rewardToken] = block.timestamp + _rewardDuration;\n        emit RewardAdded(_rewardToken, _rewardAmount, _rewardDuration);\n    }\n\n    function _rewardPerToken(address _rewardToken, uint256 _totalSupply) internal view returns (uint256) {\n        if (_totalSupply == 0) {\n            return rewardPerTokenStored[_rewardToken];\n        }\n\n        uint256 _timeSinceLastUpdate = lastTimeRewardApplicable(_rewardToken) - lastUpdateTime[_rewardToken];\n        uint256 _rewardsSinceLastUpdate = _timeSinceLastUpdate * rewardRates[_rewardToken];\n        uint256 _rewardsPerTokenSinceLastUpdate = (_rewardsSinceLastUpdate * 1e18) / _totalSupply;\n        return rewardPerTokenStored[_rewardToken] + _rewardsPerTokenSinceLastUpdate;\n    }\n\n    function _updateReward(\n        address _rewardToken,\n        address _account,\n        uint256 _totalSupply,\n        uint256 _balance\n    ) internal {\n        uint256 _rewardPerTokenStored = _rewardPerToken(_rewardToken, _totalSupply);\n        rewardPerTokenStored[_rewardToken] = _rewardPerTokenStored;\n        lastUpdateTime[_rewardToken] = lastTimeRewardApplicable(_rewardToken);\n        if (_account != address(0)) {\n            rewards[_rewardToken][_account] = _claimable(_rewardToken, _account, _totalSupply, _balance);\n            userRewardPerTokenPaid[_rewardToken][_account] = _rewardPerTokenStored;\n        }\n    }\n}\n"
    }
  }
}}