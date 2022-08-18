{{
  "language": "Solidity",
  "sources": {
    "xERC20.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0\npragma solidity ^0.8.4;\n\nimport {ERC20} from \"ERC20.sol\";\nimport {SafeTransferLib} from \"SafeTransferLib.sol\";\n\nimport {Ownable} from \"Ownable.sol\";\nimport {FullMath} from \"FullMath.sol\";\nimport {ERC20 as CloneERC20} from \"ERC20.sol\";\n\n/// @title xERC20\n/// @author zefram.eth\n/// @notice A special type of ERC20 staking pool where the reward token is the same as\n/// the stake token. This enables stakers to receive an xERC20 token representing their\n/// stake that can then be transferred or plugged into other things (e.g. Uniswap).\n/// @dev xERC20 is inspired by xSUSHI, but is superior because rewards are distributed over time rather\n/// than immediately, which prevents MEV bots from stealing the rewards or malicious users staking immediately\n/// before the reward distribution and unstaking immediately after.\ncontract xERC20 is CloneERC20, Ownable {\n    /// -----------------------------------------------------------------------\n    /// Library usage\n    /// -----------------------------------------------------------------------\n\n    using SafeTransferLib for ERC20;\n\n    /// -----------------------------------------------------------------------\n    /// Errors\n    /// -----------------------------------------------------------------------\n\n    error Error_ZeroOwner();\n    error Error_AlreadyInitialized();\n    error Error_NotRewardDistributor();\n    error Error_ZeroSupply();\n\n    /// -----------------------------------------------------------------------\n    /// Events\n    /// -----------------------------------------------------------------------\n\n    event RewardAdded(uint128 reward);\n    event Staked(\n        address indexed user,\n        uint256 stakeTokenAmount,\n        uint256 xERC20Amount\n    );\n    event Withdrawn(\n        address indexed user,\n        uint256 stakeTokenAmount,\n        uint256 xERC20Amount\n    );\n\n    /// -----------------------------------------------------------------------\n    /// Constants\n    /// -----------------------------------------------------------------------\n\n    uint256 internal constant PRECISION = 1e18;\n\n    /// -----------------------------------------------------------------------\n    /// Storage variables\n    /// -----------------------------------------------------------------------\n\n    uint64 public currentUnlockEndTimestamp;\n    uint64 public lastRewardTimestamp;\n    uint128 public lastRewardAmount;\n\n    /// @notice Tracks if an address can call notifyReward()\n    mapping(address => bool) public isRewardDistributor;\n\n    /// -----------------------------------------------------------------------\n    /// Immutable parameters\n    /// -----------------------------------------------------------------------\n\n    /// @notice The token being staked in the pool\n    function stakeToken() public pure returns (ERC20) {\n        return ERC20(_getArgAddress(0x41));\n    }\n\n    /// @notice The length of each reward period, in seconds\n    function DURATION() public pure returns (uint64) {\n        return _getArgUint64(0x55);\n    }\n\n    /// -----------------------------------------------------------------------\n    /// Initialization\n    /// -----------------------------------------------------------------------\n\n    /// @notice Initializes the owner, called by StakingPoolFactory\n    /// @param initialOwner The initial owner of the contract\n    function initialize(address initialOwner) external {\n        if (owner() != address(0)) {\n            revert Error_AlreadyInitialized();\n        }\n        if (initialOwner == address(0)) {\n            revert Error_ZeroOwner();\n        }\n\n        _transferOwnership(initialOwner);\n    }\n\n    /// -----------------------------------------------------------------------\n    /// User actions\n    /// -----------------------------------------------------------------------\n\n    /// @notice Stake tokens to receive xERC20 tokens\n    /// @param stakeTokenAmount The amount of tokens to stake\n    /// @return xERC20Amount The amount of xERC20 tokens minted\n    function stake(uint256 stakeTokenAmount)\n        external\n        virtual\n        returns (uint256 xERC20Amount)\n    {\n        /// -----------------------------------------------------------------------\n        /// Validation\n        /// -----------------------------------------------------------------------\n\n        if (stakeTokenAmount == 0) {\n            return 0;\n        }\n\n        /// -----------------------------------------------------------------------\n        /// State updates\n        /// -----------------------------------------------------------------------\n\n        xERC20Amount = FullMath.mulDiv(\n            stakeTokenAmount,\n            PRECISION,\n            getPricePerFullShare()\n        );\n        _mint(msg.sender, xERC20Amount);\n\n        /// -----------------------------------------------------------------------\n        /// Effects\n        /// -----------------------------------------------------------------------\n\n        stakeToken().safeTransferFrom(\n            msg.sender,\n            address(this),\n            stakeTokenAmount\n        );\n\n        emit Staked(msg.sender, stakeTokenAmount, xERC20Amount);\n    }\n\n    /// @notice Withdraw tokens by burning xERC20 tokens\n    /// @param xERC20Amount The amount of xERC20 to burn\n    /// @return stakeTokenAmount The amount of staked tokens withdrawn\n    function withdraw(uint256 xERC20Amount)\n        external\n        virtual\n        returns (uint256 stakeTokenAmount)\n    {\n        /// -----------------------------------------------------------------------\n        /// Validation\n        /// -----------------------------------------------------------------------\n\n        if (xERC20Amount == 0) {\n            return 0;\n        }\n\n        /// -----------------------------------------------------------------------\n        /// State updates\n        /// -----------------------------------------------------------------------\n        stakeTokenAmount = FullMath.mulDiv(\n            xERC20Amount,\n            getPricePerFullShare(),\n            PRECISION\n        );\n        _burn(msg.sender, xERC20Amount);\n\n        /// -----------------------------------------------------------------------\n        /// Effects\n        /// -----------------------------------------------------------------------\n\n        stakeToken().safeTransfer(msg.sender, stakeTokenAmount);\n\n        emit Withdrawn(msg.sender, stakeTokenAmount, xERC20Amount);\n    }\n\n    /// -----------------------------------------------------------------------\n    /// Getters\n    /// -----------------------------------------------------------------------\n\n    /// @notice Compute the amount of staked tokens that can be withdrawn by burning\n    ///         1 xERC20 token. Increases linearly during a reward distribution period.\n    /// @dev Initialized to be PRECISION (representing 1:1)\n    /// @return The amount of staked tokens that can be withdrawn by burning\n    ///         1 xERC20 token\n    function getPricePerFullShare() public view returns (uint256) {\n        uint256 totalShares = totalSupply;\n        uint256 stakeTokenBalance = stakeToken().balanceOf(address(this));\n        if (totalShares == 0 || stakeTokenBalance == 0) {\n            return PRECISION;\n        }\n        uint256 lastRewardAmount_ = lastRewardAmount;\n        uint256 currentUnlockEndTimestamp_ = currentUnlockEndTimestamp;\n        if (\n            lastRewardAmount_ == 0 ||\n            block.timestamp >= currentUnlockEndTimestamp_\n        ) {\n            // no rewards or rewards fully unlocked\n            // entire balance is withdrawable\n            return FullMath.mulDiv(stakeTokenBalance, PRECISION, totalShares);\n        } else {\n            // rewards not fully unlocked\n            // deduct locked rewards from balance\n            uint256 lastRewardTimestamp_ = lastRewardTimestamp;\n            // can't overflow since lockedRewardAmount < lastRewardAmount\n            uint256 lockedRewardAmount = (lastRewardAmount_ *\n                (currentUnlockEndTimestamp_ - block.timestamp)) /\n                (currentUnlockEndTimestamp_ - lastRewardTimestamp_);\n            return\n                FullMath.mulDiv(\n                    stakeTokenBalance - lockedRewardAmount,\n                    PRECISION,\n                    totalShares\n                );\n        }\n    }\n\n    /// -----------------------------------------------------------------------\n    /// Owner actions\n    /// -----------------------------------------------------------------------\n\n    /// @notice Distributes rewards to xERC20 holders\n    /// @dev When not in a distribution period, start a new one with rewardUnlockPeriod seconds.\n    ///      When in a distribution period, add rewards to current period.\n    function distributeReward(uint128 rewardAmount) external {\n        /// -----------------------------------------------------------------------\n        /// Validation\n        /// -----------------------------------------------------------------------\n\n        if (totalSupply == 0) {\n            revert Error_ZeroSupply();\n        }\n        if (!isRewardDistributor[msg.sender]) {\n            revert Error_NotRewardDistributor();\n        }\n\n        /// -----------------------------------------------------------------------\n        /// Storage loads\n        /// -----------------------------------------------------------------------\n\n        uint256 currentUnlockEndTimestamp_ = currentUnlockEndTimestamp;\n\n        /// -----------------------------------------------------------------------\n        /// State updates\n        /// -----------------------------------------------------------------------\n\n        if (block.timestamp >= currentUnlockEndTimestamp_) {\n            // start new reward period\n            currentUnlockEndTimestamp = uint64(block.timestamp + DURATION());\n            lastRewardAmount = rewardAmount;\n        } else {\n            // add rewards to current reward period\n            // can't overflow since lockedRewardAmount < lastRewardAmount\n            uint256 lockedRewardAmount = (lastRewardAmount *\n                (currentUnlockEndTimestamp_ - block.timestamp)) /\n                (currentUnlockEndTimestamp_ - lastRewardTimestamp);\n            // will revert if lastRewardAmount overflows\n            lastRewardAmount = uint128(rewardAmount + lockedRewardAmount);\n        }\n        lastRewardTimestamp = uint64(block.timestamp);\n\n        /// -----------------------------------------------------------------------\n        /// Effects\n        /// -----------------------------------------------------------------------\n\n        stakeToken().safeTransferFrom(msg.sender, address(this), rewardAmount);\n\n        emit RewardAdded(rewardAmount);\n    }\n\n    /// @notice Lets the owner add/remove accounts from the list of reward distributors.\n    /// Reward distributors can call notifyRewardAmount()\n    /// @param rewardDistributor The account to add/remove\n    /// @param isRewardDistributor_ True to add the account, false to remove the account\n    function setRewardDistributor(\n        address rewardDistributor,\n        bool isRewardDistributor_\n    ) external onlyOwner {\n        isRewardDistributor[rewardDistributor] = isRewardDistributor_;\n    }\n}\n"
    },
    "ERC20.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\nimport {Clone} from \"Clone.sol\";\n\n/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.\n/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)\n/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)\n/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.\nabstract contract ERC20 is Clone {\n    /*///////////////////////////////////////////////////////////////\n                                  EVENTS\n    //////////////////////////////////////////////////////////////*/\n\n    event Transfer(address indexed from, address indexed to, uint256 amount);\n\n    event Approval(\n        address indexed owner,\n        address indexed spender,\n        uint256 amount\n    );\n\n    /*///////////////////////////////////////////////////////////////\n                              ERC20 STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    uint256 public totalSupply;\n\n    mapping(address => uint256) public balanceOf;\n\n    mapping(address => mapping(address => uint256)) public allowance;\n\n    /*///////////////////////////////////////////////////////////////\n                               METADATA\n    //////////////////////////////////////////////////////////////*/\n\n    function name() external pure returns (string memory) {\n        return string(abi.encodePacked(_getArgUint256(0)));\n    }\n\n    function symbol() external pure returns (string memory) {\n        return string(abi.encodePacked(_getArgUint256(0x20)));\n    }\n\n    function decimals() external pure returns (uint8) {\n        return _getArgUint8(0x40);\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                              ERC20 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function approve(address spender, uint256 amount)\n        public\n        virtual\n        returns (bool)\n    {\n        allowance[msg.sender][spender] = amount;\n\n        emit Approval(msg.sender, spender, amount);\n\n        return true;\n    }\n\n    function transfer(address to, uint256 amount)\n        public\n        virtual\n        returns (bool)\n    {\n        balanceOf[msg.sender] -= amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(msg.sender, to, amount);\n\n        return true;\n    }\n\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) public virtual returns (bool) {\n        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.\n\n        if (allowed != type(uint256).max)\n            allowance[from][msg.sender] = allowed - amount;\n\n        balanceOf[from] -= amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(from, to, amount);\n\n        return true;\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                       INTERNAL LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function _mint(address to, uint256 amount) internal virtual {\n        totalSupply += amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(address(0), to, amount);\n    }\n\n    function _burn(address from, uint256 amount) internal virtual {\n        balanceOf[from] -= amount;\n\n        // Cannot underflow because a user's balance\n        // will never be larger than the total supply.\n        unchecked {\n            totalSupply -= amount;\n        }\n\n        emit Transfer(from, address(0), amount);\n    }\n\n    function _getImmutableVariablesOffset()\n        internal\n        pure\n        returns (uint256 offset)\n    {\n        assembly {\n            offset := sub(\n                calldatasize(),\n                add(shr(240, calldataload(sub(calldatasize(), 2))), 2)\n            )\n        }\n    }\n}\n"
    },
    "Clone.sol": {
      "content": "// SPDX-License-Identifier: BSD\npragma solidity ^0.8.4;\n\n/// @title Clone\n/// @author zefram.eth\n/// @notice Provides helper functions for reading immutable args from calldata\ncontract Clone {\n    /// @notice Reads an immutable arg with type address\n    /// @param argOffset The offset of the arg in the packed data\n    /// @return arg The arg value\n    function _getArgAddress(uint256 argOffset)\n        internal\n        pure\n        returns (address arg)\n    {\n        uint256 offset = _getImmutableArgsOffset();\n        assembly {\n            arg := shr(0x60, calldataload(add(offset, argOffset)))\n        }\n    }\n\n    /// @notice Reads an immutable arg with type uint256\n    /// @param argOffset The offset of the arg in the packed data\n    /// @return arg The arg value\n    function _getArgUint256(uint256 argOffset)\n        internal\n        pure\n        returns (uint256 arg)\n    {\n        uint256 offset = _getImmutableArgsOffset();\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            arg := calldataload(add(offset, argOffset))\n        }\n    }\n\n    /// @notice Reads an immutable arg with type uint64\n    /// @param argOffset The offset of the arg in the packed data\n    /// @return arg The arg value\n    function _getArgUint64(uint256 argOffset)\n        internal\n        pure\n        returns (uint64 arg)\n    {\n        uint256 offset = _getImmutableArgsOffset();\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            arg := shr(0xc0, calldataload(add(offset, argOffset)))\n        }\n    }\n\n    /// @notice Reads an immutable arg with type uint8\n    /// @param argOffset The offset of the arg in the packed data\n    /// @return arg The arg value\n    function _getArgUint8(uint256 argOffset) internal pure returns (uint8 arg) {\n        uint256 offset = _getImmutableArgsOffset();\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            arg := shr(0xf8, calldataload(add(offset, argOffset)))\n        }\n    }\n\n    /// @return offset The offset of the packed immutable args in calldata\n    function _getImmutableArgsOffset() internal pure returns (uint256 offset) {\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            offset := sub(\n                calldatasize(),\n                add(shr(240, calldataload(sub(calldatasize(), 2))), 2)\n            )\n        }\n    }\n}\n"
    },
    "SafeTransferLib.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\nimport {ERC20} from \"ERC20.sol\";\n\n/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.\n/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeTransferLib.sol)\n/// @author Modified from Gnosis (https://github.com/gnosis/gp-v2-contracts/blob/main/src/contracts/libraries/GPv2SafeERC20.sol)\n/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.\n/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.\nlibrary SafeTransferLib {\n    /*///////////////////////////////////////////////////////////////\n                            ETH OPERATIONS\n    //////////////////////////////////////////////////////////////*/\n\n    function safeTransferETH(address to, uint256 amount) internal {\n        bool callStatus;\n\n        assembly {\n            // Transfer the ETH and store if it succeeded or not.\n            callStatus := call(gas(), to, amount, 0, 0, 0, 0)\n        }\n\n        require(callStatus, \"ETH_TRANSFER_FAILED\");\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                           ERC20 OPERATIONS\n    //////////////////////////////////////////////////////////////*/\n\n    function safeTransferFrom(\n        ERC20 token,\n        address from,\n        address to,\n        uint256 amount\n    ) internal {\n        bool callStatus;\n\n        assembly {\n            // Get a pointer to some free memory.\n            let freeMemoryPointer := mload(0x40)\n\n            // Write the abi-encoded calldata to memory piece by piece:\n            mstore(\n                freeMemoryPointer,\n                0x23b872dd00000000000000000000000000000000000000000000000000000000\n            ) // Begin with the function selector.\n            mstore(\n                add(freeMemoryPointer, 4),\n                and(from, 0xffffffffffffffffffffffffffffffffffffffff)\n            ) // Mask and append the \"from\" argument.\n            mstore(\n                add(freeMemoryPointer, 36),\n                and(to, 0xffffffffffffffffffffffffffffffffffffffff)\n            ) // Mask and append the \"to\" argument.\n            mstore(add(freeMemoryPointer, 68), amount) // Finally append the \"amount\" argument. No mask as it's a full 32 byte value.\n\n            // Call the token and store if it succeeded or not.\n            // We use 100 because the calldata length is 4 + 32 * 3.\n            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)\n        }\n\n        require(\n            didLastOptionalReturnCallSucceed(callStatus),\n            \"TRANSFER_FROM_FAILED\"\n        );\n    }\n\n    function safeTransfer(\n        ERC20 token,\n        address to,\n        uint256 amount\n    ) internal {\n        bool callStatus;\n\n        assembly {\n            // Get a pointer to some free memory.\n            let freeMemoryPointer := mload(0x40)\n\n            // Write the abi-encoded calldata to memory piece by piece:\n            mstore(\n                freeMemoryPointer,\n                0xa9059cbb00000000000000000000000000000000000000000000000000000000\n            ) // Begin with the function selector.\n            mstore(\n                add(freeMemoryPointer, 4),\n                and(to, 0xffffffffffffffffffffffffffffffffffffffff)\n            ) // Mask and append the \"to\" argument.\n            mstore(add(freeMemoryPointer, 36), amount) // Finally append the \"amount\" argument. No mask as it's a full 32 byte value.\n\n            // Call the token and store if it succeeded or not.\n            // We use 68 because the calldata length is 4 + 32 * 2.\n            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)\n        }\n\n        require(\n            didLastOptionalReturnCallSucceed(callStatus),\n            \"TRANSFER_FAILED\"\n        );\n    }\n\n    function safeApprove(\n        ERC20 token,\n        address to,\n        uint256 amount\n    ) internal {\n        bool callStatus;\n\n        assembly {\n            // Get a pointer to some free memory.\n            let freeMemoryPointer := mload(0x40)\n\n            // Write the abi-encoded calldata to memory piece by piece:\n            mstore(\n                freeMemoryPointer,\n                0x095ea7b300000000000000000000000000000000000000000000000000000000\n            ) // Begin with the function selector.\n            mstore(\n                add(freeMemoryPointer, 4),\n                and(to, 0xffffffffffffffffffffffffffffffffffffffff)\n            ) // Mask and append the \"to\" argument.\n            mstore(add(freeMemoryPointer, 36), amount) // Finally append the \"amount\" argument. No mask as it's a full 32 byte value.\n\n            // Call the token and store if it succeeded or not.\n            // We use 68 because the calldata length is 4 + 32 * 2.\n            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)\n        }\n\n        require(didLastOptionalReturnCallSucceed(callStatus), \"APPROVE_FAILED\");\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                         INTERNAL HELPER LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function didLastOptionalReturnCallSucceed(bool callStatus)\n        private\n        pure\n        returns (bool success)\n    {\n        assembly {\n            // Get how many bytes the call returned.\n            let returnDataSize := returndatasize()\n\n            // If the call reverted:\n            if iszero(callStatus) {\n                // Copy the revert message into memory.\n                returndatacopy(0, 0, returnDataSize)\n\n                // Revert with the same message.\n                revert(0, returnDataSize)\n            }\n\n            switch returnDataSize\n            case 32 {\n                // Copy the return data into memory.\n                returndatacopy(0, 0, returnDataSize)\n\n                // Set success to whether it returned true.\n                success := iszero(iszero(mload(0)))\n            }\n            case 0 {\n                // There was no return data.\n                success := 1\n            }\n            default {\n                // It returned some malformed input.\n                success := 0\n            }\n        }\n    }\n}\n"
    },
    "Ownable.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0\n\npragma solidity ^0.8.4;\n\nabstract contract Ownable {\n    error Ownable_NotOwner();\n    error Ownable_NewOwnerZeroAddress();\n\n    address private _owner;\n\n    event OwnershipTransferred(\n        address indexed previousOwner,\n        address indexed newOwner\n    );\n\n    /// @dev Returns the address of the current owner.\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /// @dev Throws if called by any account other than the owner.\n    modifier onlyOwner() {\n        if (owner() != msg.sender) revert Ownable_NotOwner();\n        _;\n    }\n\n    /// @dev Transfers ownership of the contract to a new account (`newOwner`).\n    /// Can only be called by the current owner.\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        if (newOwner == address(0)) revert Ownable_NewOwnerZeroAddress();\n        _transferOwnership(newOwner);\n    }\n\n    /// @dev Transfers ownership of the contract to a new account (`newOwner`).\n    /// Internal function without access restriction.\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "FullMath.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.8.0;\n\n/// @title Contains 512-bit math functions\n/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision\n/// @dev Handles \"phantom overflow\" i.e., allows multiplication and division where an intermediate value overflows 256 bits\nlibrary FullMath {\n    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0\n    /// @param a The multiplicand\n    /// @param b The multiplier\n    /// @param denominator The divisor\n    /// @return result The 256-bit result\n    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv\n    function mulDiv(\n        uint256 a,\n        uint256 b,\n        uint256 denominator\n    ) internal pure returns (uint256 result) {\n        unchecked {\n            // 512-bit multiply [prod1 prod0] = a * b\n            // Compute the product mod 2**256 and mod 2**256 - 1\n            // then use the Chinese Remainder Theorem to reconstruct\n            // the 512 bit result. The result is stored in two 256\n            // variables such that product = prod1 * 2**256 + prod0\n            uint256 prod0; // Least significant 256 bits of the product\n            uint256 prod1; // Most significant 256 bits of the product\n            assembly {\n                let mm := mulmod(a, b, not(0))\n                prod0 := mul(a, b)\n                prod1 := sub(sub(mm, prod0), lt(mm, prod0))\n            }\n\n            // Handle non-overflow cases, 256 by 256 division\n            if (prod1 == 0) {\n                require(denominator > 0);\n                assembly {\n                    result := div(prod0, denominator)\n                }\n                return result;\n            }\n\n            // Make sure the result is less than 2**256.\n            // Also prevents denominator == 0\n            require(denominator > prod1);\n\n            ///////////////////////////////////////////////\n            // 512 by 256 division.\n            ///////////////////////////////////////////////\n\n            // Make division exact by subtracting the remainder from [prod1 prod0]\n            // Compute remainder using mulmod\n            uint256 remainder;\n            assembly {\n                remainder := mulmod(a, b, denominator)\n            }\n            // Subtract 256 bit number from 512 bit number\n            assembly {\n                prod1 := sub(prod1, gt(remainder, prod0))\n                prod0 := sub(prod0, remainder)\n            }\n\n            // Factor powers of two out of denominator\n            // Compute largest power of two divisor of denominator.\n            // Always >= 1.\n            uint256 twos = (type(uint256).max - denominator + 1) & denominator;\n            // Divide denominator by power of two\n            assembly {\n                denominator := div(denominator, twos)\n            }\n\n            // Divide [prod1 prod0] by the factors of two\n            assembly {\n                prod0 := div(prod0, twos)\n            }\n            // Shift in bits from prod1 into prod0. For this we need\n            // to flip `twos` such that it is 2**256 / twos.\n            // If twos is zero, then it becomes one\n            assembly {\n                twos := add(div(sub(0, twos), twos), 1)\n            }\n            prod0 |= prod1 * twos;\n\n            // Invert denominator mod 2**256\n            // Now that denominator is an odd number, it has an inverse\n            // modulo 2**256 such that denominator * inv = 1 mod 2**256.\n            // Compute the inverse by starting with a seed that is correct\n            // correct for four bits. That is, denominator * inv = 1 mod 2**4\n            uint256 inv = (3 * denominator) ^ 2;\n            // Now use Newton-Raphson iteration to improve the precision.\n            // Thanks to Hensel's lifting lemma, this also works in modular\n            // arithmetic, doubling the correct bits in each step.\n            inv *= 2 - denominator * inv; // inverse mod 2**8\n            inv *= 2 - denominator * inv; // inverse mod 2**16\n            inv *= 2 - denominator * inv; // inverse mod 2**32\n            inv *= 2 - denominator * inv; // inverse mod 2**64\n            inv *= 2 - denominator * inv; // inverse mod 2**128\n            inv *= 2 - denominator * inv; // inverse mod 2**256\n\n            // Because the division is now exact we can divide by multiplying\n            // with the modular inverse of denominator. This will give us the\n            // correct result modulo 2**256. Since the precoditions guarantee\n            // that the outcome is less than 2**256, this is the final result.\n            // We don't need to compute the high bits of the result and prod1\n            // is no longer required.\n            result = prod0 * inv;\n            return result;\n        }\n    }\n\n    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0\n    /// @param a The multiplicand\n    /// @param b The multiplier\n    /// @param denominator The divisor\n    /// @return result The 256-bit result\n    function mulDivRoundingUp(\n        uint256 a,\n        uint256 b,\n        uint256 denominator\n    ) internal pure returns (uint256 result) {\n        result = mulDiv(a, b, denominator);\n        unchecked {\n            if (mulmod(a, b, denominator) > 0) {\n                require(result < type(uint256).max);\n                result++;\n            }\n        }\n    }\n}\n"
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