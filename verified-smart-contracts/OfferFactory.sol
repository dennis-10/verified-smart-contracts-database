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
    "src/ERC20/IERC20.sol": {
      "content": "/**\n* SPDX-License-Identifier: MIT\n*\n* Copyright (c) 2016-2019 zOS Global Limited\n*\n*/\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\n * the optional functions; to access them see `ERC20Detailed`.\n */\n\ninterface IERC20 {\n\n    // Optional functions\n    function name() external view returns (string memory);\n\n    function symbol() external view returns (string memory);\n\n    event NameChanged(string name, string symbol);\n\n    function decimals() external view returns (uint8);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a `Transfer` event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through `transferFrom`. This is\n     * zero by default.\n     *\n     * This value changes when `approve` or `transferFrom` are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * > Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an `Approval` event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a `Transfer` event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to `approve`. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n}"
    },
    "src/draggable/IDraggable.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nabstract contract IDraggable {\n    \n    function getOracle() public virtual returns (address);\n    function drag(address buyer, address currency) external virtual;\n    function notifyOfferEnded() external virtual;\n    function votingPower(address voter) external virtual returns (uint256);\n    function totalVotingTokens() public virtual view returns (uint256);\n    function notifyVoted(address voter) external virtual;\n\n}"
    },
    "src/draggable/Offer.sol": {
      "content": "/**\n* SPDX-License-Identifier: LicenseRef-Aktionariat\n*\n* MIT License with Automated License Fee Payments\n*\n* Copyright (c) 2020 Aktionariat AG (aktionariat.com)\n*\n* Permission is hereby granted to any person obtaining a copy of this software\n* and associated documentation files (the \"Software\"), to deal in the Software\n* without restriction, including without limitation the rights to use, copy,\n* modify, merge, publish, distribute, sublicense, and/or sell copies of the\n* Software, and to permit persons to whom the Software is furnished to do so,\n* subject to the following conditions:\n*\n* - The above copyright notice and this permission notice shall be included in\n*   all copies or substantial portions of the Software.\n* - All automated license fee payments integrated into this and related Software\n*   are preserved.\n*\n* THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n* SOFTWARE.\n*/\npragma solidity ^0.8.0;\n\nimport \"../ERC20/IERC20.sol\";\nimport \"./IDraggable.sol\";\n/**\n * @title A public offer to acquire all tokens\n * @author Luzius Meisser, luzius@aktionariat.com\n */\n\ncontract Offer {\n\n    uint256 public immutable quorum;                    // Percentage of votes needed to start drag-along process in BPS, i.e. 10'000 = 100%\n\n    IDraggable public immutable token;\n    address public immutable buyer;                     // who made the offer\n    \n    IERC20 public immutable currency;\n    uint256 public immutable price;                               // the price offered per share\n\n    enum Vote { NONE, YES, NO }                         // Used internally, represents not voted yet or yes/no vote.\n    mapping (address => Vote) private votes;            // Who votes what\n    uint256 public yesVotes;                            // total number of yes votes, including external votes\n    uint256 public noVotes;                             // total number of no votes, including external votes\n    uint256 public noExternal;                          // number of external no votes reported by oracle\n    uint256 public yesExternal;                         // number of external yes votes reported by oracle\n\n    uint256 public immutable voteEnd;                             // end of vote period in block time (seconds after 1.1.1970)\n\n    event VotesChanged(uint256 newYesVotes, uint256 newNoVotes);\n    event OfferCreated(address indexed buyer, address token, uint256 pricePerShare, address currency);\n    event OfferEnded(address indexed buyer, bool success, string message);\n\n    // Not checked here, but buyer should make sure it is well funded from the beginning\n    constructor(\n        address _buyer,\n        address _token,\n        uint256 _price,\n        address _currency,\n        uint256 _quorum,\n        uint256 _votePeriod\n    ) \n        payable \n    {\n        buyer = _buyer;\n        token = IDraggable(_token);\n        currency = IERC20(_currency);\n        price = _price;\n        quorum = _quorum;\n        // rely on time stamp is ok, no exact time stamp needed\n        // solhint-disable-next-line not-rely-on-time\n        voteEnd = block.timestamp + _votePeriod;\n        // License Fee to Aktionariat AG, also ensures that offer is serious.\n        // Any circumvention of this license fee payment is a violation of the copyright terms.\n        payable(0x29Fe8914e76da5cE2d90De98a64d0055f199d06D).transfer(3 ether);\n        emit OfferCreated(_buyer, address(_token), _price, address(_currency));\n    }\n\n    function makeCompetingOffer(address betterOffer) external {\n        require(msg.sender == address(token), \"invalid caller\");\n        Offer better = Offer(betterOffer);\n        require(!isAccepted(), \"old already accepted\");\n        require(currency == better.currency() && better.price() > price, \"old offer better\");\n        require(better.isWellFunded(), \"not funded\");\n        kill(false, \"replaced\");\n    }\n\n    function hasExpired() internal view returns (bool) {\n        // rely on time stamp is ok, no exact time stamp needed\n        // solhint-disable-next-line not-rely-on-time\n        return block.timestamp > voteEnd + 30 days; // buyer has thirty days to complete acquisition after voting ends\n    }\n\n    function contest() external {\n        if (hasExpired()) {\n            kill(false, \"expired\");\n        } else if (isDeclined()) {\n            kill(false, \"declined\");\n        } else if (!isWellFunded()) {\n            kill(false, \"lack of funds\");\n        }\n    }\n\n    function cancel() external {\n        require(msg.sender == buyer, \"invalid caller\");\n        kill(false, \"cancelled\");\n    }\n\n    function execute() external {\n        require(msg.sender == buyer, \"not buyer\");\n        require(isAccepted(), \"not accepted\");\n        uint256 totalPrice = getTotalPrice();\n        require(currency.transferFrom(buyer, address(token), totalPrice), \"transfer failed\");\n        token.drag(buyer, address(currency));\n        kill(true, \"success\");\n    }\n\n    function getTotalPrice() internal view returns (uint256) {\n        IERC20 tok = IERC20(address(token));\n        return (tok.totalSupply() - tok.balanceOf(buyer)) * price;\n    }\n\n    function isWellFunded() public view returns (bool) {\n        uint256 buyerBalance = currency.balanceOf(buyer);\n        uint256 totalPrice = getTotalPrice();\n        return totalPrice <= buyerBalance;\n    }\n\n    function isAccepted() public view returns (bool) {\n        if (isVotingOpen()) {\n            // is it already clear that 75% will vote yes even though the vote is not over yet?\n            return yesVotes * 10000  >= quorum * IDraggable(token).totalVotingTokens();\n        } else {\n            // did 75% of all cast votes say 'yes'?\n            return yesVotes * 10000 >= quorum * (yesVotes + noVotes);\n        }\n    }\n\n    function isDeclined() public view returns (bool) {\n        if (isVotingOpen()) {\n            // is it already clear that 25% will vote no even though the vote is not over yet?\n            uint256 supply = token.totalVotingTokens();\n            return (supply - noVotes) * 10000 < quorum * supply;\n        } else {\n            // did quorum% of all cast votes say 'no'?\n            return 10000 * yesVotes < quorum * (yesVotes + noVotes);\n        }\n    }\n\n    function notifyMoved(address from, address to, uint256 value) external {\n        require(msg.sender == address(token), \"invalid caller\");\n        if (isVotingOpen()) {\n            Vote fromVoting = votes[from];\n            Vote toVoting = votes[to];\n            update(fromVoting, toVoting, value);\n        }\n    }\n\n    function update(Vote previousVote, Vote newVote, uint256 votes_) internal {\n        if (previousVote != newVote) {\n            if (previousVote == Vote.NO) {\n                noVotes = noVotes - votes_;\n            } else if (previousVote == Vote.YES) {\n                yesVotes = yesVotes - votes_;\n            }\n            if (newVote == Vote.NO) {\n                noVotes = noVotes + votes_;\n            } else if (newVote == Vote.YES) {\n                yesVotes = yesVotes + votes_;\n            }\n            emit VotesChanged(yesVotes, noVotes);\n        }\n    }\n\n    function isVotingOpen() public view returns (bool) {\n        // rely on time stamp is ok, no exact time stamp needed\n        // solhint-disable-next-line not-rely-on-time\n        return block.timestamp <= voteEnd;\n    }\n\n    modifier votingOpen() {\n        require(isVotingOpen(), \"vote ended\");\n        _;\n    }\n\n    /**\n     * Function to allow the oracle to report the votes of external votes (e.g. shares tokenized on other blockchains).\n     * This functions is idempotent and sets the number of external yes and no votes. So when more votes come in, the\n     * oracle should always report the total number of yes and no votes. Abstentions are not counted.\n     */\n    function reportExternalVotes(uint256 yes, uint256 no) external {\n        require(msg.sender == token.getOracle(), \"not oracle\");\n        require(yes + no + IERC20(address(token)).totalSupply() <= token.totalVotingTokens(), \"too many votes\");\n        // adjust total votes taking into account that the oralce might have reported different counts before\n        yesVotes = yesVotes - yesExternal + yes;\n        noVotes = noVotes - noExternal + no;\n        // remember how the oracle voted in case the oracle later reports updated numbers\n        yesExternal = yes;\n        noExternal = no;\n    }\n\n    function voteYes() external {\n        vote(Vote.YES);\n    }\n\n    function voteNo() external { \n        vote(Vote.NO);\n    }\n\n    function vote(Vote newVote) internal votingOpen() {\n        Vote previousVote = votes[msg.sender];\n        votes[msg.sender] = newVote;\n        if(previousVote == Vote.NONE){\n            IDraggable(token).notifyVoted(msg.sender);\n        }\n        update(previousVote, newVote, IDraggable(token).votingPower(msg.sender));\n    }\n\n    function hasVotedYes(address voter) external view returns (bool) {\n        return votes[voter] == Vote.YES;\n    }\n\n    function hasVotedNo(address voter) external view returns (bool) {\n        return votes[voter] == Vote.NO;\n    }\n\n    function kill(bool success, string memory message) internal {\n        IDraggable(token).notifyOfferEnded();\n        emit OfferEnded(buyer, success, message);\n        selfdestruct(payable(buyer));\n    }\n\n}"
    },
    "src/draggable/OfferFactory.sol": {
      "content": "/**\n* SPDX-License-Identifier: LicenseRef-Aktionariat\n*\n* MIT License with Automated License Fee Payments\n*\n* Copyright (c) 2020 Aktionariat AG (aktionariat.com)\n*\n* Permission is hereby granted to any person obtaining a copy of this software\n* and associated documentation files (the \"Software\"), to deal in the Software\n* without restriction, including without limitation the rights to use, copy,\n* modify, merge, publish, distribute, sublicense, and/or sell copies of the\n* Software, and to permit persons to whom the Software is furnished to do so,\n* subject to the following conditions:\n*\n* - The above copyright notice and this permission notice shall be included in\n*   all copies or substantial portions of the Software.\n* - All automated license fee payments integrated into this and related Software\n*   are preserved.\n*\n* THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n* SOFTWARE.\n*/\npragma solidity ^0.8.0;\n\nimport \"./Offer.sol\";\n\ncontract OfferFactory {\n    \n    event OfferCreated(address contractAddress, string typeName);\n\n    // It must be possible to predict the address of the offer so one can pre-fund the allowance.\n    function predict(bytes32 salt, address buyer, address token, uint256 pricePerShare, address currency, uint256 quorum, uint256 votePeriod) external view returns (address) {\n        bytes32 initCodeHash = keccak256(abi.encodePacked(type(Offer).creationCode, abi.encode(buyer, token, pricePerShare, currency, quorum, votePeriod)));\n        bytes32 hashResult = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, initCodeHash));\n        return address(uint160(uint256(hashResult)));\n    }\n\n    // Do not call directly, msg.sender must be the token to be acquired\n    function create(bytes32 salt, address buyer, uint256 pricePerShare, address currency, uint256 quorum, uint256 votePeriod) external payable returns (address) {\n        Offer offer = new Offer{value: msg.value, salt: salt}(buyer, msg.sender, pricePerShare, currency, quorum, votePeriod);\n        return address(offer);\n    }\n}"
    }
  }
}}