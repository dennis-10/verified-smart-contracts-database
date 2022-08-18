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
      "runs": 1000
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
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../IERC20.sol\";\nimport \"../../../utils/Address.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n    using Address for address;\n\n    function safeTransfer(\n        IERC20 token,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n    }\n\n    function safeTransferFrom(\n        IERC20 token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    /**\n     * @dev Deprecated. This function has issues similar to the ones found in\n     * {IERC20-approve}, and its usage is discouraged.\n     *\n     * Whenever possible, use {safeIncreaseAllowance} and\n     * {safeDecreaseAllowance} instead.\n     */\n    function safeApprove(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'\n        require(\n            (value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n\n    function safeIncreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        uint256 newAllowance = token.allowance(address(this), spender) + value;\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    function safeDecreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        unchecked {\n            uint256 oldAllowance = token.allowance(address(this), spender);\n            require(oldAllowance >= value, \"SafeERC20: decreased allowance below zero\");\n            uint256 newAllowance = oldAllowance - value;\n            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n        }\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function _callOptionalReturn(IERC20 token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that\n        // the target address contains contract code and also asserts for success in the low-level call.\n\n        bytes memory returndata = address(token).functionCall(data, \"SafeERC20: low-level call failed\");\n        if (returndata.length > 0) {\n            // Return data is optional\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize, which returns 0 for contracts in\n        // construction, since the code is only stored at the end of the\n        // constructor execution.\n\n        uint256 size;\n        assembly {\n            size := extcodesize(account)\n        }\n        return size > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "contracts/core/defi/butter/ButterBatchProcessingZapper.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n// Docgen-SOLC: 0.8.0\n\npragma solidity ^0.8.0;\npragma experimental ABIEncoderV2;\n\nimport \"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol\";\nimport {BatchType, Batch, IButterBatchProcessing} from \"../../interfaces/IButterBatchProcessing.sol\";\nimport \"../../../externals/interfaces/Curve3Pool.sol\";\nimport \"../../interfaces/IContractRegistry.sol\";\n\n/*\n * This Contract allows user to use and receive stablecoins directly when interacting with ButterBatchProcessing.\n * This contract mainly takes stablecoins swaps them into 3CRV and deposits them or the other way around.\n */\ncontract ButterBatchProcessingZapper {\n  using SafeERC20 for IERC20;\n\n  /* ========== STATE VARIABLES ========== */\n\n  IContractRegistry private contractRegistry;\n  Curve3Pool private curve3Pool;\n  IERC20 private threeCrv;\n\n  /* ========== EVENTS ========== */\n\n  event ZappedIntoBatch(uint256 threeCurveAmount, address account);\n  event ZappedOutOfBatch(\n    bytes32 batchId,\n    uint8 stableCoinIndex,\n    uint256 threeCurveAmount,\n    uint256 stableCoinAmount,\n    address account\n  );\n  event ClaimedIntoStable(\n    bytes32 batchId,\n    uint8 stableCoinIndex,\n    uint256 threeCurveAmount,\n    uint256 stableCoinAmount,\n    address account\n  );\n\n  /* ========== CONSTRUCTOR ========== */\n\n  constructor(\n    IContractRegistry _contractRegistry,\n    Curve3Pool _curve3Pool,\n    IERC20 _threeCrv\n  ) {\n    contractRegistry = _contractRegistry;\n    curve3Pool = _curve3Pool;\n    threeCrv = _threeCrv;\n  }\n\n  /* ========== MUTATIVE FUNCTIONS ========== */\n\n  /**\n   * @notice zapIntoBatch allows a user to deposit into a mintBatch directly with stablecoins\n   * @param _amounts An array of amounts in stablecoins the user wants to deposit\n   * @param _min_mint_amounts The min amount of 3CRV which should be minted by the curve three-pool (slippage control)\n   * @dev The amounts in _amounts must align with their index in the curve three-pool\n   */\n  function zapIntoBatch(uint256[3] memory _amounts, uint256 _min_mint_amounts) external {\n    address butterBatchProcessing = contractRegistry.getContract(keccak256(\"ButterBatchProcessing\"));\n    for (uint8 i; i < _amounts.length; i++) {\n      if (_amounts[i] > 0) {\n        //Deposit Stables\n        IERC20(curve3Pool.coins(i)).safeTransferFrom(msg.sender, address(this), _amounts[i]);\n      }\n    }\n    //Deposit stables to receive 3CRV\n    curve3Pool.add_liquidity(_amounts, _min_mint_amounts);\n\n    //Check the amount of returned 3CRV\n    /*\n    While curves metapools return the amount of minted 3CRV this is not possible with the three-pool which is why we simply have to check our balance after depositing our stables.\n    If a user sends 3CRV to this contract by accident (Which cant be retrieved anyway) they will be used aswell.\n    */\n    uint256 threeCrvAmount = threeCrv.balanceOf(address(this));\n\n    //Deposit 3CRV in current mint batch\n    IButterBatchProcessing(butterBatchProcessing).depositForMint(threeCrvAmount, msg.sender);\n    emit ZappedIntoBatch(threeCrvAmount, msg.sender);\n  }\n\n  /**\n   * @notice zapOutOfBatch allows a user to retrieve their not yet processed 3CRV and directly receive stablecoins\n   * @param _batchId Defines which batch gets withdrawn from\n   * @param _amountToWithdraw 3CRV amount that shall be withdrawn\n   * @param _stableCoinIndex Defines which stablecoin the user wants to receive\n   * @param _min_amount The min amount of stables which should be returned by the curve three-pool (slippage control)\n   * @dev The _stableCoinIndex must align with the index in the curve three-pool\n   */\n  function zapOutOfBatch(\n    bytes32 _batchId,\n    uint256 _amountToWithdraw,\n    uint8 _stableCoinIndex,\n    uint256 _min_amount\n  ) external {\n    // Allows the zapepr to withdraw 3CRV from batch for the user\n    IButterBatchProcessing(contractRegistry.getContract(keccak256(\"ButterBatchProcessing\"))).withdrawFromBatch(\n      _batchId,\n      _amountToWithdraw,\n      msg.sender\n    );\n\n    //Burns 3CRV for stables and sends them to the user\n    //stableBalance is only returned for the event\n    uint256 stableBalance = _swapAndTransfer3Crv(_amountToWithdraw, _stableCoinIndex, _min_amount);\n\n    emit ZappedOutOfBatch(_batchId, _stableCoinIndex, _amountToWithdraw, stableBalance, msg.sender);\n  }\n\n  /**\n   * @notice claimAndSwapToStable allows a user to claim their processed 3CRV from a redeemBatch and directly receive stablecoins\n   * @param _batchId Defines which batch gets withdrawn from\n   * @param _stableCoinIndex Defines which stablecoin the user wants to receive\n   * @param _min_amount The min amount of stables which should be returned by the curve three-pool (slippage control)\n   * @dev The _stableCoinIndex must align with the index in the curve three-pool\n   */\n  function claimAndSwapToStable(\n    bytes32 _batchId,\n    uint8 _stableCoinIndex,\n    uint256 _min_amount\n  ) external {\n    //We can only deposit 3CRV which come from mintBatches otherwise this could claim Butter which we cant process here\n    IButterBatchProcessing butterBatchProcessing = IButterBatchProcessing(\n      contractRegistry.getContract(keccak256(\"ButterBatchProcessing\"))\n    );\n    require(butterBatchProcessing.batches(_batchId).batchType == BatchType.Redeem, \"needs to return 3crv\");\n\n    //Zapper claims 3CRV for the user\n    uint256 threeCurveAmount = butterBatchProcessing.claim(_batchId, msg.sender);\n\n    //Burns 3CRV for stables and sends them to the user\n    //stableBalance is only returned for the event\n    uint256 stableBalance = _swapAndTransfer3Crv(threeCurveAmount, _stableCoinIndex, _min_amount);\n\n    emit ClaimedIntoStable(_batchId, _stableCoinIndex, threeCurveAmount, stableBalance, msg.sender);\n  }\n\n  /**\n   * @notice _swapAndTransfer3Crv burns 3CRV and sends the returned stables to the user\n   * @param _threeCurveAmount How many 3CRV shall be burned\n   * @param _stableCoinIndex Defines which stablecoin the user wants to receive\n   * @param _min_amount The min amount of stables which should be returned by the curve three-pool (slippage control)\n   * @dev The stableCoinIndex_ must align with the index in the curve three-pool\n   */\n  function _swapAndTransfer3Crv(\n    uint256 _threeCurveAmount,\n    uint8 _stableCoinIndex,\n    uint256 _min_amount\n  ) internal returns (uint256) {\n    //Burn 3CRV to receive stables\n    curve3Pool.remove_liquidity_one_coin(_threeCurveAmount, _stableCoinIndex, _min_amount);\n\n    //Check the amount of returned stables\n    /*\n    If a user sends Stables to this contract by accident (Which cant be retrieved anyway) they will be used aswell.\n    */\n    uint256 stableBalance = IERC20(curve3Pool.coins(_stableCoinIndex)).balanceOf(address(this));\n\n    //Transfer stables to user\n    IERC20(curve3Pool.coins(_stableCoinIndex)).safeTransfer(msg.sender, stableBalance);\n\n    //Return stablebalance for event\n    return stableBalance;\n  }\n\n  /**\n   * @notice set idempotent approvals for 3pool and butter batch processing\n   */\n  function setApprovals() external {\n    IERC20(curve3Pool.coins(0)).safeApprove(address(curve3Pool), 0);\n    IERC20(curve3Pool.coins(0)).safeApprove(address(curve3Pool), type(uint256).max);\n\n    IERC20(curve3Pool.coins(1)).safeApprove(address(curve3Pool), 0);\n    IERC20(curve3Pool.coins(1)).safeApprove(address(curve3Pool), type(uint256).max);\n\n    IERC20(curve3Pool.coins(2)).safeApprove(address(curve3Pool), 0);\n    IERC20(curve3Pool.coins(2)).safeApprove(address(curve3Pool), type(uint256).max);\n\n    address butterBatchProcessing = contractRegistry.getContract(keccak256(\"ButterBatchProcessing\"));\n    threeCrv.safeApprove(butterBatchProcessing, 0);\n    threeCrv.safeApprove(butterBatchProcessing, type(uint256).max);\n\n    threeCrv.safeApprove(address(curve3Pool), 0);\n    threeCrv.safeApprove(address(curve3Pool), type(uint256).max);\n  }\n}\n"
    },
    "contracts/core/interfaces/IButterBatchProcessing.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n// Docgen-SOLC: 0.8.0\n\npragma solidity ^0.8.0;\npragma experimental ABIEncoderV2;\n\nenum BatchType {\n  Mint,\n  Redeem\n}\n\nstruct Batch {\n  BatchType batchType;\n  bytes32 batchId;\n  bool claimable;\n  uint256 unclaimedShares;\n  uint256 suppliedTokenBalance;\n  uint256 claimableTokenBalance;\n  address suppliedTokenAddress;\n  address claimableTokenAddress;\n}\n\ninterface IButterBatchProcessing {\n  function batches(bytes32 batchId) external view returns (Batch memory);\n\n  function depositForMint(uint256 amount_, address account_) external;\n\n  function claim(bytes32 batchId_, address account_) external returns (uint256);\n\n  function withdrawFromBatch(\n    bytes32 batchId_,\n    uint256 amountToWithdraw_,\n    address account_\n  ) external;\n}\n"
    },
    "contracts/core/interfaces/IContractRegistry.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n// Docgen-SOLC: 0.8.0\n\npragma solidity ^0.8.0;\n\n/**\n * @dev External interface of ContractRegistry.\n */\ninterface IContractRegistry {\n  function getContract(bytes32 _name) external view returns (address);\n}\n"
    },
    "contracts/externals/interfaces/Curve3Pool.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n// Docgen-SOLC: 0.8.0\n\npragma solidity ^0.8.0;\n\ninterface Curve3Pool {\n  function add_liquidity(uint256[3] calldata amounts, uint256 min_mint_amounts) external;\n\n  function remove_liquidity_one_coin(\n    uint256 burn_amount,\n    int128 i,\n    uint256 min_amount\n  ) external;\n\n  function get_virtual_price() external view returns (uint256);\n\n  function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);\n\n  function coins(uint256 i) external view returns (address);\n\n  function calc_token_amount(uint256[3] calldata amounts, bool deposit) external view returns (uint256);\n}\n"
    }
  }
}}