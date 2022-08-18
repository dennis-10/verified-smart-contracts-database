{"IGenArt721CoreV2.sol":{"content":"pragma solidity ^0.5.0;\n\ninterface IGenArt721CoreV2 {\n  function isWhitelisted(address sender) external view returns (bool);\n  function admin() external view returns(address);\n  function projectIdToCurrencySymbol(uint256 _projectId) external view returns (string memory);\n  function projectIdToCurrencyAddress(uint256 _projectId) external view returns (address);\n  function projectIdToArtistAddress(uint256 _projectId) external view returns (address payable);\n  function projectIdToPricePerTokenInWei(uint256 _projectId) external view returns (uint256);\n  function projectIdToAdditionalPayee(uint256 _projectId) external view returns (address payable);\n  function projectIdToAdditionalPayeePercentage(uint256 _projectId) external view returns (uint256);\n  function projectTokenInfo(uint256 _projectId) external view returns (address, uint256, uint256, uint256, bool, address, uint256, string memory, address);\n  function renderProviderAddress() external view returns (address payable);\n  function renderProviderPercentage() external view returns (uint256);\n  function mint(address _to, uint256 _projectId, address _by) external returns (uint256 tokenId);\n  function ownerOf(uint256 tokenId) external view returns (address);\n  function tokenIdToProjectId(uint256 tokenId) external view returns(uint256);\n}"},"RedeemableProduct.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.5.0;\n\nimport \"./SafeMath.sol\";\nimport \"./IGenArt721CoreV2.sol\";\n\ncontract RedeemableProduct {\n    using SafeMath for uint256;\n\n    event SetRedemptionAmount(\n        address indexed genArtCoreAddress,\n        uint256 indexed projectId,\n        uint256 indexed amount\n    );\n\n    event AddProductName(\n        address indexed genArtCoreAddress,\n        uint256 indexed projectId,\n        string name\n    );\n\n    event RemoveProductName(\n        address indexed genArtCoreAddress,\n        uint256 indexed projectId,\n        string name\n    );\n\n    event SetRecipientAddress(address indexed recipientAddress);\n\n    event AddVariation(\n        address indexed genArtCoreAddress,\n        uint256 indexed projectId,\n        uint256 indexed variationId,\n        string variant,\n        uint256 priceInWei,\n        bool paused\n    );\n\n    event UpdateVariation(\n        address indexed genArtCoreAddress,\n        uint256 indexed projectId,\n        uint256 indexed variationId,\n        string variant,\n        uint256 priceInWei,\n        bool paused\n    );\n\n    struct Order {\n        address redeemer;\n        string productName;\n        string variant;\n        uint256 priceInWei;\n    }\n\n    struct Variation {\n        string variant;\n        uint256 priceInWei;\n        bool paused;\n    }\n\n    IGenArt721CoreV2 public genArtCoreContract;\n\n    string private _contractName;\n    address private _redemptionServiceAddress;\n    address payable private _recipientAddress;\n\n    mapping(address =\u003e mapping(uint256 =\u003e uint256)) private _redemptionAmount;\n    mapping(address =\u003e mapping(uint256 =\u003e uint256)) private _isTokenRedeemed;\n    mapping(address =\u003e mapping(uint256 =\u003e string)) private _productName;\n    mapping(address =\u003e mapping(uint256 =\u003e mapping(uint256 =\u003e Order))) private _orderInfo;\n    mapping(address =\u003e mapping(uint256 =\u003e mapping(uint256 =\u003e Variation))) private _variationInfo;\n    mapping(address =\u003e mapping(uint256 =\u003e uint256)) private _nextVariationId;\n\n    modifier onlyGenArtWhitelist() {\n        require(genArtCoreContract.isWhitelisted(msg.sender), \"only gen art whitelisted\");\n        _;\n    }\n\n    modifier onlyAdmin() {\n        require(msg.sender == genArtCoreContract.admin(), \"Only admin\");\n        _;\n    }\n\n    modifier onlyRedemptionService() {\n        require(msg.sender == _redemptionServiceAddress, \u0027only merch shop contract\u0027);\n        _;\n    }\n\n    constructor(string memory contractName, address genArtCoreAddress, address redemptionServiceAddress, address payable recipientAddress) public {\n        _contractName = contractName;\n        genArtCoreContract = IGenArt721CoreV2(genArtCoreAddress);\n        _redemptionServiceAddress = redemptionServiceAddress;\n        _recipientAddress = recipientAddress;\n    }\n\n    function getContractName() public view returns(string memory contractName) {\n        return _contractName;\n    }\n\n    function getNextVariationId(address genArtCoreAddress, uint256 projectId) public view returns(uint256 nextVariationId) {\n        return _nextVariationId[genArtCoreAddress][projectId];\n    }\n\n    function getRecipientAddress() public view returns(address payable recipientAddress) {\n        return _recipientAddress;\n    }\n\n    function getTokenRedemptionCount(address genArtCoreAddress, uint256 tokenId) public view returns(uint256 tokenRedeemptionCount) {\n        return _isTokenRedeemed[genArtCoreAddress][tokenId];\n    }\n\n    function getRedemptionAmount(address genArtCoreAddress, uint256 projectId) public view returns(uint256 amount) {\n        return _redemptionAmount[genArtCoreAddress][projectId];\n    }\n\n    function getProductName(address genArtCoreAddress, uint256 projectId) public view returns(string memory name) {\n        return _productName[genArtCoreAddress][projectId];\n    }\n\n    function getVariationInfo(address genArtCoreAddress, uint256 projectId, uint256 variationId) public view returns(string memory variant, uint256 priceInWei, bool paused) {\n        Variation memory variation = _variationInfo[genArtCoreAddress][projectId][variationId];\n        return (variation.variant, variation.priceInWei, variation.paused);\n    }\n\n    function getVariationIsPaused(address genArtCoreAddress, uint256 projectId, uint256 variationId) public view returns(bool paused) {\n        Variation memory variation = _variationInfo[genArtCoreAddress][projectId][variationId];\n        return variation.paused;\n    }\n\n    function getVariationPriceInWei(address genArtCoreAddress, uint256 projectId, uint256 variationId) public view returns(uint256 priceInWei) {\n        Variation memory variation = _variationInfo[genArtCoreAddress][projectId][variationId];\n        return variation.priceInWei;\n    }\n\n    function getOrderInfo(address genArtCoreAddress, uint256 tokenId, uint256 redemptionCount) public view returns(string memory contractName, address redeemer, string memory name, string memory variant, uint256 priceInWei) {\n        Order memory order = _orderInfo[genArtCoreAddress][tokenId][redemptionCount];\n        return (_contractName, order.redeemer, order.productName, order.variant, order.priceInWei);\n    }\n\n    function setRecipientAddress(address payable recipientAddress) public onlyAdmin {\n        _recipientAddress = recipientAddress;\n        emit SetRecipientAddress(_recipientAddress);\n    }\n\n    function setRedemptionAmount(address genArtCoreAddress, uint256 projectId, uint256 amount) public onlyGenArtWhitelist {\n        emit SetRedemptionAmount(genArtCoreAddress, projectId, amount);\n        _redemptionAmount[genArtCoreAddress][projectId] = amount;\n    }\n\n    function addProductName(address genArtCoreAddress, uint256 projectId, string memory name) public onlyGenArtWhitelist {\n        _productName[genArtCoreAddress][projectId] = name;\n        emit AddProductName(genArtCoreAddress, projectId, name);\n    }\n\n    function removeProductName(address genArtCoreAddress, uint256 projectId) public onlyGenArtWhitelist {\n        string memory name = _productName[genArtCoreAddress][projectId];\n        delete _productName[genArtCoreAddress][projectId];\n        emit RemoveProductName(genArtCoreAddress, projectId, name);\n    }\n\n    function addVariation(address genArtCoreAddress, uint256 projectId, string memory variant, uint256 priceInWei, bool paused) public onlyGenArtWhitelist {\n        uint256 variationId = _nextVariationId[genArtCoreAddress][projectId];\n        _variationInfo[genArtCoreAddress][projectId][variationId].variant = variant;\n        _variationInfo[genArtCoreAddress][projectId][variationId].priceInWei = priceInWei;\n        _variationInfo[genArtCoreAddress][projectId][variationId].paused = paused;\n        _nextVariationId[genArtCoreAddress][projectId] = variationId.add(1);\n        emit AddVariation(genArtCoreAddress, projectId, variationId, variant, priceInWei, paused);\n    }\n\n    function updateVariation(address genArtCoreAddress, uint256 projectId, uint256 variationId, string memory variant, uint256 priceInWei, bool paused) public onlyGenArtWhitelist {\n        _variationInfo[genArtCoreAddress][projectId][variationId].variant = variant;\n        _variationInfo[genArtCoreAddress][projectId][variationId].priceInWei = priceInWei;\n        _variationInfo[genArtCoreAddress][projectId][variationId].paused = paused;\n        emit UpdateVariation(genArtCoreAddress, projectId, variationId, variant, priceInWei, paused);\n    }\n\n    function toggleVariationIsPaused(address genArtCoreAddress, uint256 projectId, uint256 variationId) public onlyGenArtWhitelist {\n        _variationInfo[genArtCoreAddress][projectId][variationId].paused = !_variationInfo[genArtCoreAddress][projectId][variationId].paused;\n    }\n\n    function incrementRedemptionAmount(address redeemer, address genArtCoreAddress, uint256 tokenId, uint256 variationId) public onlyRedemptionService {\n        uint256 redemptionCount = _isTokenRedeemed[genArtCoreAddress][tokenId].add(1);\n        uint256 projectId = genArtCoreContract.tokenIdToProjectId(tokenId);\n        uint256 purchasePriceInWei = getVariationPriceInWei(genArtCoreAddress, projectId, variationId);\n        _isTokenRedeemed[genArtCoreAddress][tokenId] = redemptionCount;\n        string memory product = _productName[genArtCoreAddress][projectId];\n        Variation memory incrementedVariation = _variationInfo[genArtCoreAddress][projectId][variationId];\n        _orderInfo[genArtCoreAddress][tokenId][redemptionCount] =\n            Order(\n                redeemer,\n                product,\n                incrementedVariation.variant,\n                purchasePriceInWei\n            );\n    }\n}"},"SafeMath.sol":{"content":"// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/math/SafeMath.sol\npragma solidity ^0.5.0;\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it\u0027s recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return sub(a, b, \"SafeMath: subtraction overflow\");\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     *\n     * _Available since v2.4.0._\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b \u003c= a, errorMessage);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return div(a, b, \"SafeMath: division by zero\");\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     *\n     * _Available since v2.4.0._\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0, errorMessage);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return mod(a, b, \"SafeMath: modulo by zero\");\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts with custom message when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     *\n     * _Available since v2.4.0._\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b != 0, errorMessage);\n        return a % b;\n    }\n}"}}