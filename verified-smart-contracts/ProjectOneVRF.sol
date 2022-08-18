{{
  "language": "Solidity",
  "sources": {
    "PrjOneVRF.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\n/**\n*   @title LIT Project One VRF\n*   @author Transient Labs, LLC\n*   @notice Contract to perform VRF for copyright of Survive All Apocalypses\n*   Copyright (C) 2021 Transient Labs\n*/\n\n/*\n #######                                                      #                            \n    #    #####    ##   #    #  ####  # ###### #    # #####    #         ##   #####   ####  \n    #    #    #  #  #  ##   # #      # #      ##   #   #      #        #  #  #    # #      \n    #    #    # #    # # #  #  ####  # #####  # #  #   #      #       #    # #####   ####  \n    #    #####  ###### #  # #      # # #      #  # #   #      #       ###### #    #      # \n    #    #   #  #    # #   ## #    # # #      #   ##   #      #       #    # #    # #    # \n    #    #    # #    # #    #  ####  # ###### #    #   #      ####### #    # #####   #### \n    \n0101010011100101100000110111011100101101000110010011011101110100 01001100110000011000101110011 \n*/\n\npragma solidity ^0.8.0;\n\nimport \"Ownable.sol\";\nimport \"SafeMath.sol\";\nimport \"VRFConsumerBase.sol\";\n\ncontract ProjectOneVRF is VRFConsumerBase, Ownable {\n\n    using SafeMath for uint256;\n\n    bytes32 private randomRequestId;\n    bool private randomReceived;\n    uint256 private randomResult;\n    bool private raffleComplete;\n    bool private revealTokenId;\n    uint256 private randomTokenId;\n\n    event randomnessReceived();\n\n    /**\n    *   @notice constructor for contract\n    *   @dev contract deployer becomes the contract owner\n    *   @param _vrfCoordinator is the address for vrf coordinator on Ethereum.\n    *   @param _link is the address for the LINK ERC20 token on Ethereum\n    */\n    constructor(address _vrfCoordinator, address _link) VRFConsumerBase(_vrfCoordinator, _link) Ownable() {}\n    \n    /**\n    *   @notice function to request randomness from Chainlink VRF\n    *   @dev requires owner to call the function \n    *   @dev a wrapper on the VRF consumer base contract\n    *   @dev require enough link for the transaction\n    *   @param keyHash is the public key against which randomness is generated\n    *   @param fee is the fee in LINK for the request\n    */\n    function getRandomValue(bytes32 keyHash, uint256 fee) public onlyOwner {\n        require(LINK.balanceOf(address(this)) >= fee, \"Error: Not enough LINK\");\n        randomRequestId = requestRandomness(keyHash, fee);\n    }\n\n    /**\n    *   @notice function to receive random value from chainlink VRF\n    *   @dev internal function since VRFCoordinator calls \"rawFulfillRandomness\" and that has security built in\n    *   @dev still need to make sure we store a value with the right request Id and that we haven't already received a fulfilled order\n    *   @dev just stores result which can then be used elsewhere. This avoid reverting functions\n    *   @dev emits event showing that it was received\n    */\n    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {\n        if (requestId == randomRequestId && !randomReceived) {\n            randomResult = randomness;\n            randomReceived = true;\n        }\n\n        emit randomnessReceived();\n    }   \n\n    /**\n    *   @notice function to determine a randomTokenId based on VRF\n    *   @dev can only be called by owner\n    *   @dev requires that the random ID hasn't been chosen yet\n    *   @dev uses inclusive modulus calculation to convert uint256 to value between 1 and current number of tokens.\n    *   This is then used to get the owner of that random token.\n    */\n    function calcRandomId() public onlyOwner {\n        require(randomReceived, \"Error: VRF has not been called yet\");\n        require(!raffleComplete, \"Error: raffle is complete\");\n        randomTokenId = randomResult.mod(892).add(1);\n        raffleComplete = true;\n    }\n\n    /**\n    *   @dev gets the random token id\n    *   @dev onlyOwner. Others must wait until tokenID is revealed. This is so that LIT creators or Transient Labs may not receive the copyright. Don't want to dox people :)\n    * \n    */\n    function ownerGetRandomId() public view onlyOwner returns(uint256) {\n        require(raffleComplete, \"Error: raffle not complete\");\n        return(randomTokenId);\n    }\n\n    /**\n    *   @dev gets the random token id once the winner is revealed\n    * \n    */\n    function getRandomId() public view returns(uint256) {\n        require(raffleComplete, \"Error: raffle not complete\");\n        require(revealTokenId, \"Error: token ID not ready to be revealed to the public\");\n        return(randomTokenId);\n    }\n\n    /**\n    *   @dev resets randomness bools and value. This shall only be used if the random chosen id belongs to a LIT creator or Transient Labs.\n    *   @dev onlyOwner\n    */\n    function resetRaffle() public onlyOwner {\n        raffleComplete = false;\n        randomReceived = false;\n    }\n\n    /**\n    *   @dev function to get raffle status\n    */\n    function raffleStatus() public view returns(bool) {\n        return(raffleComplete);\n    }\n\n    /**\n    *   @dev reveal raffle\n    *   @dev ownly owner\n    */\n    function revealRaffle() public onlyOwner {\n        revealTokenId = true;\n    }\n\n    /**\n    *   @dev hide raffle\n    *   @dev ownly owner\n    */\n    function hideRaffle() public onlyOwner {\n        revealTokenId = false;\n    }\n\n    /**\n    *   @dev show status of raffle reveal\n    */\n    function raffleRevealStatus() public view returns(bool) {\n        return(revealTokenId);\n    }\n}  "
    },
    "Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "SafeMath.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (utils/math/SafeMath.sol)\n\npragma solidity ^0.8.0;\n\n// CAUTION\n// This version of SafeMath should only be used with Solidity 0.8 or later,\n// because it relies on the compiler's built in overflow checks.\n\n/**\n * @dev Wrappers over Solidity's arithmetic operations.\n *\n * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler\n * now has built in overflow checking.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            uint256 c = a + b;\n            if (c < a) return (false, 0);\n            return (true, c);\n        }\n    }\n\n    /**\n     * @dev Returns the substraction of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b > a) return (false, 0);\n            return (true, a - b);\n        }\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the\n            // benefit is lost if 'b' is also tested.\n            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n            if (a == 0) return (true, 0);\n            uint256 c = a * b;\n            if (c / a != b) return (false, 0);\n            return (true, c);\n        }\n    }\n\n    /**\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b == 0) return (false, 0);\n            return (true, a / b);\n        }\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b == 0) return (false, 0);\n            return (true, a % b);\n        }\n    }\n\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity's `+` operator.\n     *\n     * Requirements:\n     *\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a + b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity's `*` operator.\n     *\n     * Requirements:\n     *\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a * b;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity's `/` operator.\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting when dividing by zero.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a % b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {trySub}.\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(\n        uint256 a,\n        uint256 b,\n        string memory errorMessage\n    ) internal pure returns (uint256) {\n        unchecked {\n            require(b <= a, errorMessage);\n            return a - b;\n        }\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(\n        uint256 a,\n        uint256 b,\n        string memory errorMessage\n    ) internal pure returns (uint256) {\n        unchecked {\n            require(b > 0, errorMessage);\n            return a / b;\n        }\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting with custom message when dividing by zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryMod}.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(\n        uint256 a,\n        uint256 b,\n        string memory errorMessage\n    ) internal pure returns (uint256) {\n        unchecked {\n            require(b > 0, errorMessage);\n            return a % b;\n        }\n    }\n}\n"
    },
    "VRFConsumerBase.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"LinkTokenInterface.sol\";\n\nimport \"VRFRequestIDBase.sol\";\n\n/** ****************************************************************************\n * @notice Interface for contracts using VRF randomness\n * *****************************************************************************\n * @dev PURPOSE\n *\n * @dev Reggie the Random Oracle (not his real job) wants to provide randomness\n * @dev to Vera the verifier in such a way that Vera can be sure he's not\n * @dev making his output up to suit himself. Reggie provides Vera a public key\n * @dev to which he knows the secret key. Each time Vera provides a seed to\n * @dev Reggie, he gives back a value which is computed completely\n * @dev deterministically from the seed and the secret key.\n *\n * @dev Reggie provides a proof by which Vera can verify that the output was\n * @dev correctly computed once Reggie tells it to her, but without that proof,\n * @dev the output is indistinguishable to her from a uniform random sample\n * @dev from the output space.\n *\n * @dev The purpose of this contract is to make it easy for unrelated contracts\n * @dev to talk to Vera the verifier about the work Reggie is doing, to provide\n * @dev simple access to a verifiable source of randomness.\n * *****************************************************************************\n * @dev USAGE\n *\n * @dev Calling contracts must inherit from VRFConsumerBase, and can\n * @dev initialize VRFConsumerBase's attributes in their constructor as\n * @dev shown:\n *\n * @dev   contract VRFConsumer {\n * @dev     constuctor(<other arguments>, address _vrfCoordinator, address _link)\n * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {\n * @dev         <initialization with other arguments goes here>\n * @dev       }\n * @dev   }\n *\n * @dev The oracle will have given you an ID for the VRF keypair they have\n * @dev committed to (let's call it keyHash), and have told you the minimum LINK\n * @dev price for VRF service. Make sure your contract has sufficient LINK, and\n * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you\n * @dev want to generate randomness from.\n *\n * @dev Once the VRFCoordinator has received and validated the oracle's response\n * @dev to your request, it will call your contract's fulfillRandomness method.\n *\n * @dev The randomness argument to fulfillRandomness is the actual random value\n * @dev generated from your seed.\n *\n * @dev The requestId argument is generated from the keyHash and the seed by\n * @dev makeRequestId(keyHash, seed). If your contract could have concurrent\n * @dev requests open, you can use the requestId to track which seed is\n * @dev associated with which randomness. See VRFRequestIDBase.sol for more\n * @dev details. (See \"SECURITY CONSIDERATIONS\" for principles to keep in mind,\n * @dev if your contract could have multiple requests in flight simultaneously.)\n *\n * @dev Colliding `requestId`s are cryptographically impossible as long as seeds\n * @dev differ. (Which is critical to making unpredictable randomness! See the\n * @dev next section.)\n *\n * *****************************************************************************\n * @dev SECURITY CONSIDERATIONS\n *\n * @dev A method with the ability to call your fulfillRandomness method directly\n * @dev could spoof a VRF response with any random value, so it's critical that\n * @dev it cannot be directly called by anything other than this base contract\n * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).\n *\n * @dev For your users to trust that your contract's random behavior is free\n * @dev from malicious interference, it's best if you can write it so that all\n * @dev behaviors implied by a VRF response are executed *during* your\n * @dev fulfillRandomness method. If your contract must store the response (or\n * @dev anything derived from it) and use it later, you must ensure that any\n * @dev user-significant behavior which depends on that stored value cannot be\n * @dev manipulated by a subsequent VRF request.\n *\n * @dev Similarly, both miners and the VRF oracle itself have some influence\n * @dev over the order in which VRF responses appear on the blockchain, so if\n * @dev your contract could have multiple VRF requests in flight simultaneously,\n * @dev you must ensure that the order in which the VRF responses arrive cannot\n * @dev be used to manipulate your contract's user-significant behavior.\n *\n * @dev Since the ultimate input to the VRF is mixed with the block hash of the\n * @dev block in which the request is made, user-provided seeds have no impact\n * @dev on its economic security properties. They are only included for API\n * @dev compatability with previous versions of this contract.\n *\n * @dev Since the block hash of the block which contains the requestRandomness\n * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful\n * @dev miner could, in principle, fork the blockchain to evict the block\n * @dev containing the request, forcing the request to be included in a\n * @dev different block with a different hash, and therefore a different input\n * @dev to the VRF. However, such an attack would incur a substantial economic\n * @dev cost. This cost scales with the number of blocks the VRF oracle waits\n * @dev until it calls responds to a request.\n */\nabstract contract VRFConsumerBase is VRFRequestIDBase {\n\n  /**\n   * @notice fulfillRandomness handles the VRF response. Your contract must\n   * @notice implement it. See \"SECURITY CONSIDERATIONS\" above for important\n   * @notice principles to keep in mind when implementing your fulfillRandomness\n   * @notice method.\n   *\n   * @dev VRFConsumerBase expects its subcontracts to have a method with this\n   * @dev signature, and will call it once it has verified the proof\n   * @dev associated with the randomness. (It is triggered via a call to\n   * @dev rawFulfillRandomness, below.)\n   *\n   * @param requestId The Id initially returned by requestRandomness\n   * @param randomness the VRF output\n   */\n  function fulfillRandomness(\n    bytes32 requestId,\n    uint256 randomness\n  )\n    internal\n    virtual;\n\n  /**\n   * @dev In order to keep backwards compatibility we have kept the user\n   * seed field around. We remove the use of it because given that the blockhash\n   * enters later, it overrides whatever randomness the used seed provides.\n   * Given that it adds no security, and can easily lead to misunderstandings,\n   * we have removed it from usage and can now provide a simpler API.\n   */\n  uint256 constant private USER_SEED_PLACEHOLDER = 0;\n\n  /**\n   * @notice requestRandomness initiates a request for VRF output given _seed\n   *\n   * @dev The fulfillRandomness method receives the output, once it's provided\n   * @dev by the Oracle, and verified by the vrfCoordinator.\n   *\n   * @dev The _keyHash must already be registered with the VRFCoordinator, and\n   * @dev the _fee must exceed the fee specified during registration of the\n   * @dev _keyHash.\n   *\n   * @dev The _seed parameter is vestigial, and is kept only for API\n   * @dev compatibility with older versions. It can't *hurt* to mix in some of\n   * @dev your own randomness, here, but it's not necessary because the VRF\n   * @dev oracle will mix the hash of the block containing your request into the\n   * @dev VRF seed it ultimately uses.\n   *\n   * @param _keyHash ID of public key against which randomness is generated\n   * @param _fee The amount of LINK to send with the request\n   *\n   * @return requestId unique ID for this request\n   *\n   * @dev The returned requestId can be used to distinguish responses to\n   * @dev concurrent requests. It is passed as the first argument to\n   * @dev fulfillRandomness.\n   */\n  function requestRandomness(\n    bytes32 _keyHash,\n    uint256 _fee\n  )\n    internal\n    returns (\n      bytes32 requestId\n    )\n  {\n    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));\n    // This is the seed passed to VRFCoordinator. The oracle will mix this with\n    // the hash of the block containing this request to obtain the seed/input\n    // which is finally passed to the VRF cryptographic machinery.\n    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);\n    // nonces[_keyHash] must stay in sync with\n    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above\n    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).\n    // This provides protection against the user repeating their input seed,\n    // which would result in a predictable/duplicate output, if multiple such\n    // requests appeared in the same block.\n    nonces[_keyHash] = nonces[_keyHash] + 1;\n    return makeRequestId(_keyHash, vRFSeed);\n  }\n\n  LinkTokenInterface immutable internal LINK;\n  address immutable private vrfCoordinator;\n\n  // Nonces for each VRF key from which randomness has been requested.\n  //\n  // Must stay in sync with VRFCoordinator[_keyHash][this]\n  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;\n\n  /**\n   * @param _vrfCoordinator address of VRFCoordinator contract\n   * @param _link address of LINK token contract\n   *\n   * @dev https://docs.chain.link/docs/link-token-contracts\n   */\n  constructor(\n    address _vrfCoordinator,\n    address _link\n  ) {\n    vrfCoordinator = _vrfCoordinator;\n    LINK = LinkTokenInterface(_link);\n  }\n\n  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF\n  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating\n  // the origin of the call\n  function rawFulfillRandomness(\n    bytes32 requestId,\n    uint256 randomness\n  )\n    external\n  {\n    require(msg.sender == vrfCoordinator, \"Only VRFCoordinator can fulfill\");\n    fulfillRandomness(requestId, randomness);\n  }\n}\n"
    },
    "LinkTokenInterface.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface LinkTokenInterface {\n\n  function allowance(\n    address owner,\n    address spender\n  )\n    external\n    view\n    returns (\n      uint256 remaining\n    );\n\n  function approve(\n    address spender,\n    uint256 value\n  )\n    external\n    returns (\n      bool success\n    );\n\n  function balanceOf(\n    address owner\n  )\n    external\n    view\n    returns (\n      uint256 balance\n    );\n\n  function decimals()\n    external\n    view\n    returns (\n      uint8 decimalPlaces\n    );\n\n  function decreaseApproval(\n    address spender,\n    uint256 addedValue\n  )\n    external\n    returns (\n      bool success\n    );\n\n  function increaseApproval(\n    address spender,\n    uint256 subtractedValue\n  ) external;\n\n  function name()\n    external\n    view\n    returns (\n      string memory tokenName\n    );\n\n  function symbol()\n    external\n    view\n    returns (\n      string memory tokenSymbol\n    );\n\n  function totalSupply()\n    external\n    view\n    returns (\n      uint256 totalTokensIssued\n    );\n\n  function transfer(\n    address to,\n    uint256 value\n  )\n    external\n    returns (\n      bool success\n    );\n\n  function transferAndCall(\n    address to,\n    uint256 value,\n    bytes calldata data\n  )\n    external\n    returns (\n      bool success\n    );\n\n  function transferFrom(\n    address from,\n    address to,\n    uint256 value\n  )\n    external\n    returns (\n      bool success\n    );\n\n}\n"
    },
    "VRFRequestIDBase.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ncontract VRFRequestIDBase {\n\n  /**\n   * @notice returns the seed which is actually input to the VRF coordinator\n   *\n   * @dev To prevent repetition of VRF output due to repetition of the\n   * @dev user-supplied seed, that seed is combined in a hash with the\n   * @dev user-specific nonce, and the address of the consuming contract. The\n   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in\n   * @dev the final seed, but the nonce does protect against repetition in\n   * @dev requests which are included in a single block.\n   *\n   * @param _userSeed VRF seed input provided by user\n   * @param _requester Address of the requesting contract\n   * @param _nonce User-specific nonce at the time of the request\n   */\n  function makeVRFInputSeed(\n    bytes32 _keyHash,\n    uint256 _userSeed,\n    address _requester,\n    uint256 _nonce\n  )\n    internal\n    pure\n    returns (\n      uint256\n    )\n  {\n    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));\n  }\n\n  /**\n   * @notice Returns the id for this request\n   * @param _keyHash The serviceAgreement ID to be used for this request\n   * @param _vRFInputSeed The seed to be passed directly to the VRF\n   * @return The id for this request\n   *\n   * @dev Note that _vRFInputSeed is not the seed passed by the consuming\n   * @dev contract, but the one generated by makeVRFInputSeed\n   */\n  function makeRequestId(\n    bytes32 _keyHash,\n    uint256 _vRFInputSeed\n  )\n    internal\n    pure\n    returns (\n      bytes32\n    )\n  {\n    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));\n  }\n}"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
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
  }
}}