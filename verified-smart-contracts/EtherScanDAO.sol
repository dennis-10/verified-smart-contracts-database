{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}"},"draft-EIP712.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./ECDSA.sol\";\n\n/**\n * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.\n *\n * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,\n * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding\n * they need in their contracts using a combination of `abi.encode` and `keccak256`.\n *\n * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding\n * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA\n * ({_hashTypedDataV4}).\n *\n * The implementation of the domain separator was designed to be as efficient as possible while still properly updating\n * the chain id to protect against replay attacks on an eventual fork of the chain.\n *\n * NOTE: This contract implements the version of the encoding known as \"v4\", as implemented by the JSON RPC method\n * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].\n *\n * _Available since v3.4._\n */\nabstract contract EIP712 {\n    /* solhint-disable var-name-mixedcase */\n    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to\n    // invalidate the cached domain separator if the chain id changes.\n    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;\n    uint256 private immutable _CACHED_CHAIN_ID;\n\n    bytes32 private immutable _HASHED_NAME;\n    bytes32 private immutable _HASHED_VERSION;\n    bytes32 private immutable _TYPE_HASH;\n\n    /* solhint-enable var-name-mixedcase */\n\n    /**\n     * @dev Initializes the domain separator and parameter caches.\n     *\n     * The meaning of `name` and `version` is specified in\n     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:\n     *\n     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.\n     * - `version`: the current major version of the signing domain.\n     *\n     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart\n     * contract upgrade].\n     */\n    constructor(string memory name, string memory version) {\n        bytes32 hashedName = keccak256(bytes(name));\n        bytes32 hashedVersion = keccak256(bytes(version));\n        bytes32 typeHash = keccak256(\n            \"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)\"\n        );\n        _HASHED_NAME = hashedName;\n        _HASHED_VERSION = hashedVersion;\n        _CACHED_CHAIN_ID = block.chainid;\n        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);\n        _TYPE_HASH = typeHash;\n    }\n\n    /**\n     * @dev Returns the domain separator for the current chain.\n     */\n    function _domainSeparatorV4() internal view returns (bytes32) {\n        if (block.chainid == _CACHED_CHAIN_ID) {\n            return _CACHED_DOMAIN_SEPARATOR;\n        } else {\n            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);\n        }\n    }\n\n    function _buildDomainSeparator(\n        bytes32 typeHash,\n        bytes32 nameHash,\n        bytes32 versionHash\n    ) private view returns (bytes32) {\n        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));\n    }\n\n    /**\n     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this\n     * function returns the hash of the fully encoded EIP712 message for this domain.\n     *\n     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:\n     *\n     * ```solidity\n     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(\n     *     keccak256(\"Mail(address to,string contents)\"),\n     *     mailTo,\n     *     keccak256(bytes(mailContents))\n     * )));\n     * address signer = ECDSA.recover(digest, signature);\n     * ```\n     */\n    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {\n        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);\n    }\n}"},"ECDSA.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.\n *\n * These functions can be used to verify that a message was signed by the holder\n * of the private keys of a given address.\n */\nlibrary ECDSA {\n    enum RecoverError {\n        NoError,\n        InvalidSignature,\n        InvalidSignatureLength,\n        InvalidSignatureS,\n        InvalidSignatureV\n    }\n\n    function _throwError(RecoverError error) private pure {\n        if (error == RecoverError.NoError) {\n            return; // no error: do nothing\n        } else if (error == RecoverError.InvalidSignature) {\n            revert(\"ECDSA: invalid signature\");\n        } else if (error == RecoverError.InvalidSignatureLength) {\n            revert(\"ECDSA: invalid signature length\");\n        } else if (error == RecoverError.InvalidSignatureS) {\n            revert(\"ECDSA: invalid signature \u0027s\u0027 value\");\n        } else if (error == RecoverError.InvalidSignatureV) {\n            revert(\"ECDSA: invalid signature \u0027v\u0027 value\");\n        }\n    }\n\n    /**\n     * @dev Returns the address that signed a hashed message (`hash`) with\n     * `signature` or error string. This address can then be used for verification purposes.\n     *\n     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:\n     * this function rejects them by requiring the `s` value to be in the lower\n     * half order, and the `v` value to be either 27 or 28.\n     *\n     * IMPORTANT: `hash` _must_ be the result of a hash operation for the\n     * verification to be secure: it is possible to craft signatures that\n     * recover to arbitrary addresses for non-hashed data. A safe way to ensure\n     * this is by receiving a hash of the original message (which may otherwise\n     * be too long), and then calling {toEthSignedMessageHash} on it.\n     *\n     * Documentation for signature generation:\n     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]\n     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]\n     *\n     * _Available since v4.3._\n     */\n    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {\n        // Check the signature length\n        // - case 65: r,s,v signature (standard)\n        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._\n        if (signature.length == 65) {\n            bytes32 r;\n            bytes32 s;\n            uint8 v;\n            // ecrecover takes the signature parameters, and the only way to get them\n            // currently is to use assembly.\n            assembly {\n                r := mload(add(signature, 0x20))\n                s := mload(add(signature, 0x40))\n                v := byte(0, mload(add(signature, 0x60)))\n            }\n            return tryRecover(hash, v, r, s);\n        } else if (signature.length == 64) {\n            bytes32 r;\n            bytes32 vs;\n            // ecrecover takes the signature parameters, and the only way to get them\n            // currently is to use assembly.\n            assembly {\n                r := mload(add(signature, 0x20))\n                vs := mload(add(signature, 0x40))\n            }\n            return tryRecover(hash, r, vs);\n        } else {\n            return (address(0), RecoverError.InvalidSignatureLength);\n        }\n    }\n\n    /**\n     * @dev Returns the address that signed a hashed message (`hash`) with\n     * `signature`. This address can then be used for verification purposes.\n     *\n     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:\n     * this function rejects them by requiring the `s` value to be in the lower\n     * half order, and the `v` value to be either 27 or 28.\n     *\n     * IMPORTANT: `hash` _must_ be the result of a hash operation for the\n     * verification to be secure: it is possible to craft signatures that\n     * recover to arbitrary addresses for non-hashed data. A safe way to ensure\n     * this is by receiving a hash of the original message (which may otherwise\n     * be too long), and then calling {toEthSignedMessageHash} on it.\n     */\n    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {\n        (address recovered, RecoverError error) = tryRecover(hash, signature);\n        _throwError(error);\n        return recovered;\n    }\n\n    /**\n     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.\n     *\n     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]\n     *\n     * _Available since v4.3._\n     */\n    function tryRecover(\n        bytes32 hash,\n        bytes32 r,\n        bytes32 vs\n    ) internal pure returns (address, RecoverError) {\n        bytes32 s;\n        uint8 v;\n        assembly {\n            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)\n            v := add(shr(255, vs), 27)\n        }\n        return tryRecover(hash, v, r, s);\n    }\n\n    /**\n     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.\n     *\n     * _Available since v4.2._\n     */\n    function recover(\n        bytes32 hash,\n        bytes32 r,\n        bytes32 vs\n    ) internal pure returns (address) {\n        (address recovered, RecoverError error) = tryRecover(hash, r, vs);\n        _throwError(error);\n        return recovered;\n    }\n\n    /**\n     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,\n     * `r` and `s` signature fields separately.\n     *\n     * _Available since v4.3._\n     */\n    function tryRecover(\n        bytes32 hash,\n        uint8 v,\n        bytes32 r,\n        bytes32 s\n    ) internal pure returns (address, RecoverError) {\n        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature\n        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines\n        // the valid range for s in (301): 0 \u003c s \u003c secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most\n        // signatures from current libraries generate a unique signature with an s-value in the lower half order.\n        //\n        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value\n        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or\n        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept\n        // these malleable signatures as well.\n        if (uint256(s) \u003e 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {\n            return (address(0), RecoverError.InvalidSignatureS);\n        }\n        if (v != 27 \u0026\u0026 v != 28) {\n            return (address(0), RecoverError.InvalidSignatureV);\n        }\n\n        // If the signature is valid (and not malleable), return the signer address\n        address signer = ecrecover(hash, v, r, s);\n        if (signer == address(0)) {\n            return (address(0), RecoverError.InvalidSignature);\n        }\n\n        return (signer, RecoverError.NoError);\n    }\n\n    /**\n     * @dev Overload of {ECDSA-recover} that receives the `v`,\n     * `r` and `s` signature fields separately.\n     */\n    function recover(\n        bytes32 hash,\n        uint8 v,\n        bytes32 r,\n        bytes32 s\n    ) internal pure returns (address) {\n        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);\n        _throwError(error);\n        return recovered;\n    }\n\n    /**\n     * @dev Returns an Ethereum Signed Message, created from a `hash`. This\n     * produces hash corresponding to the one signed with the\n     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]\n     * JSON-RPC method as part of EIP-191.\n     *\n     * See {recover}.\n     */\n    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {\n        // 32 is the length in bytes of hash,\n        // enforced by the type signature above\n        return keccak256(abi.encodePacked(\"\\x19Ethereum Signed Message:\\n32\", hash));\n    }\n\n    /**\n     * @dev Returns an Ethereum Signed Typed Data, created from a\n     * `domainSeparator` and a `structHash`. This produces hash corresponding\n     * to the one signed with the\n     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]\n     * JSON-RPC method as part of EIP-712.\n     *\n     * See {recover}.\n     */\n    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {\n        return keccak256(abi.encodePacked(\"\\x19\\x01\", domainSeparator, structHash));\n    }\n}"},"ERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (token/ERC20/ERC20.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IERC20.sol\";\nimport \"./IERC20Metadata.sol\";\nimport \"./Context.sol\";\n\n/**\n * @dev Implementation of the {IERC20} interface.\n *\n * This implementation is agnostic to the way tokens are created. This means\n * that a supply mechanism has to be added in a derived contract using {_mint}.\n * For a generic mechanism see {ERC20PresetMinterPauser}.\n *\n * TIP: For a detailed writeup see our guide\n * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How\n * to implement supply mechanisms].\n *\n * We have followed general OpenZeppelin Contracts guidelines: functions revert\n * instead returning `false` on failure. This behavior is nonetheless\n * conventional and does not conflict with the expectations of ERC20\n * applications.\n *\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\n * This allows applications to reconstruct the allowance for all accounts just\n * by listening to said events. Other implementations of the EIP may not emit\n * these events, as it isn\u0027t required by the specification.\n *\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\n * functions have been added to mitigate the well-known issues around setting\n * allowances. See {IERC20-approve}.\n */\ncontract ERC20 is Context, IERC20, IERC20Metadata {\n    struct MintBalance {\n        uint8 minted;\n        uint248 balance;\n    }\n\n    mapping(address =\u003e MintBalance) private _balances;\n\n    mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\n\n    uint256 internal _totalSupply;\n\n    string private _name;\n    string private _symbol;\n\n    /**\n     * @dev Sets the values for {name} and {symbol}.\n     *\n     * The default value of {decimals} is 18. To select a different value for\n     * {decimals} you should overload it.\n     *\n     * All two of these values are immutable: they can only be set once during\n     * construction.\n     */\n    constructor(string memory name_, string memory symbol_) {\n        _name = name_;\n        _symbol = symbol_;\n    }\n\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() public view virtual override returns (string memory) {\n        return _name;\n    }\n\n    /**\n     * @dev Returns the symbol of the token, usually a shorter version of the\n     * name.\n     */\n    function symbol() public view virtual override returns (string memory) {\n        return _symbol;\n    }\n\n    /**\n     * @dev Returns the number of decimals used to get its user representation.\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\n     * be displayed to a user as `5.05` (`505 / 10 ** 2`).\n     *\n     * Tokens usually opt for a value of 18, imitating the relationship between\n     * Ether and Wei. This is the value {ERC20} uses, unless this function is\n     * overridden;\n     *\n     * NOTE: This information is only used for _display_ purposes: it in\n     * no way affects any of the arithmetic of the contract, including\n     * {IERC20-balanceOf} and {IERC20-transfer}.\n     */\n    function decimals() public view virtual override returns (uint8) {\n        return 18;\n    }\n\n    /**\n     * @dev See {IERC20-totalSupply}.\n     */\n    function totalSupply() public view virtual override returns (uint256) {\n        return _totalSupply;\n    }\n\n    /**\n     * @dev See {IERC20-balanceOf}.\n     */\n    function balanceOf(address account) public view virtual override returns (uint256) {\n        return _balances[account].balance;\n    }\n\n    function minted(address account) public view returns (uint256) {\n        return _balances[account].minted;\n    }\n\n    /**\n     * @dev See {IERC20-transfer}.\n     *\n     * Requirements:\n     *\n     * - `recipient` cannot be the zero address.\n     * - the caller must have a balance of at least `amount`.\n     */\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(_msgSender(), recipient, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-allowance}.\n     */\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n    /**\n     * @dev See {IERC20-approve}.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\n        _approve(_msgSender(), spender, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-transferFrom}.\n     *\n     * Emits an {Approval} event indicating the updated allowance. This is not\n     * required by the EIP. See the note at the beginning of {ERC20}.\n     *\n     * Requirements:\n     *\n     * - `sender` and `recipient` cannot be the zero address.\n     * - `sender` must have a balance of at least `amount`.\n     * - the caller must have allowance for ``sender``\u0027s tokens of at least\n     * `amount`.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) public virtual override returns (bool) {\n        _transfer(sender, recipient, amount);\n\n        uint256 currentAllowance = _allowances[sender][_msgSender()];\n        require(currentAllowance \u003e= amount, \"ERC20: transfer amount exceeds allowance\");\n        unchecked {\n            _approve(sender, _msgSender(), currentAllowance - amount);\n        }\n\n        return true;\n    }\n\n    /**\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);\n        return true;\n    }\n\n    /**\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     * - `spender` must have allowance for the caller of at least\n     * `subtractedValue`.\n     */\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\n        uint256 currentAllowance = _allowances[_msgSender()][spender];\n        require(currentAllowance \u003e= subtractedValue, \"ERC20: decreased allowance below zero\");\n        unchecked {\n            _approve(_msgSender(), spender, currentAllowance - subtractedValue);\n        }\n\n        return true;\n    }\n\n    /**\n     * @dev Moves `amount` of tokens from `sender` to `recipient`.\n     *\n     * This internal function is equivalent to {transfer}, and can be used to\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\n     *\n     * Emits a {Transfer} event.\n     *\n     * Requirements:\n     *\n     * - `sender` cannot be the zero address.\n     * - `recipient` cannot be the zero address.\n     * - `sender` must have a balance of at least `amount`.\n     */\n    function _transfer(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) internal virtual {\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\n\n        _beforeTokenTransfer(sender, recipient, amount);\n\n        uint256 senderBalance = _balances[sender].balance;\n        require(senderBalance \u003e= amount, \"ERC20: transfer amount exceeds balance\");\n        unchecked {\n            _balances[sender].balance = uint248(senderBalance - amount);\n        }\n        _balances[recipient].balance += uint248(amount);\n\n        emit Transfer(sender, recipient, amount);\n\n        _afterTokenTransfer(sender, recipient, amount);\n    }\n\n    /** @dev Creates `amount` tokens and assigns them to `account`, increasing\n     * the total supply.\n     *\n     * Emits a {Transfer} event with `from` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `account` cannot be the zero address.\n     */\n    function _mint(address account, uint256 amount) internal virtual {\n        // require(account != address(0), \"ERC20: mint to the zero address\");\n        // _beforeTokenTransfer(address(0), account, amount);\n        // _totalSupply += amount;\n        uint256 b = _balances[account].balance + amount;\n        _balances[account].balance = uint248(b);\n        _balances[account].minted = 1;\n        emit Transfer(address(0), account, amount);\n        // _afterTokenTransfer(address(0), account, amount);\n    }\n\n    /**\n     * @dev Destroys `amount` tokens from `account`, reducing the\n     * total supply.\n     *\n     * Emits a {Transfer} event with `to` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `account` cannot be the zero address.\n     * - `account` must have at least `amount` tokens.\n     */\n    function _burn(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"ERC20: burn from the zero address\");\n\n        _beforeTokenTransfer(account, address(0), amount);\n\n        uint256 accountBalance = _balances[account].balance;\n        require(accountBalance \u003e= amount, \"ERC20: burn amount exceeds balance\");\n        unchecked {\n            _balances[account].balance = uint248(accountBalance - amount);\n        }\n        _totalSupply -= amount;\n\n        emit Transfer(account, address(0), amount);\n\n        _afterTokenTransfer(account, address(0), amount);\n    }\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.\n     *\n     * This internal function is equivalent to `approve`, and can be used to\n     * e.g. set automatic allowances for certain subsystems, etc.\n     *\n     * Emits an {Approval} event.\n     *\n     * Requirements:\n     *\n     * - `owner` cannot be the zero address.\n     * - `spender` cannot be the zero address.\n     */\n    function _approve(\n        address owner,\n        address spender,\n        uint256 amount\n    ) internal virtual {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n\n    /**\n     * @dev Hook that is called before any transfer of tokens. This includes\n     * minting and burning.\n     *\n     * Calling conditions:\n     *\n     * - when `from` and `to` are both non-zero, `amount` of ``from``\u0027s tokens\n     * will be transferred to `to`.\n     * - when `from` is zero, `amount` tokens will be minted for `to`.\n     * - when `to` is zero, `amount` of ``from``\u0027s tokens will be burned.\n     * - `from` and `to` are never both zero.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _beforeTokenTransfer(\n        address from,\n        address to,\n        uint256 amount\n    ) internal virtual {}\n\n    /**\n     * @dev Hook that is called after any transfer of tokens. This includes\n     * minting and burning.\n     *\n     * Calling conditions:\n     *\n     * - when `from` and `to` are both non-zero, `amount` of ``from``\u0027s tokens\n     * has been transferred to `to`.\n     * - when `from` is zero, `amount` tokens have been minted for `to`.\n     * - when `to` is zero, `amount` of ``from``\u0027s tokens have been burned.\n     * - `from` and `to` are never both zero.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _afterTokenTransfer(\n        address from,\n        address to,\n        uint256 amount\n    ) internal virtual {}\n}"},"EtherScanDAO.sol":{"content":"// SPDX-License-Identifier: MIT\n/**\nSolution to Vitalik Buterin!\nWelcome to EtherScanDAO free space!\n*/\npragma solidity ^0.8.4;\n\nimport \"./ERC20.sol\";\nimport \"./draft-EIP712.sol\";\nimport \"./ECDSA.sol\";\n\ncontract EtherScanDAO is ERC20, EIP712 {\n    uint256 public constant MAX_SUPPLY = uint248(1e14 ether);\n\n    // for DAO.\n    uint256 public constant AMOUNT_DAO = MAX_SUPPLY / 100 * 20;\n    address public constant ADDR_DAO = 0x7F90071cbB97eFe9526d5D6C24ee962F30955a86;\n\n    // for staking\n    uint256 public constant AMOUNT_STAKING = MAX_SUPPLY / 100 * 20;\n    address public constant ADDR_STAKING = 0xf0F573708670c11D824aA27FB01dC49F8dbeC64e;\n\n    // for liquidity providers\n    uint256 public constant AMOUNT_LP = MAX_SUPPLY / 100 * 10;\n    address public constant ADDR_LP = 0x44E09804D25359E410C551688EEeaE158D0EbeaD;\n\n    // for airdrop\n    uint256 public constant AMOUNT_AIREDROP = MAX_SUPPLY - (AMOUNT_DAO + AMOUNT_STAKING + AMOUNT_LP);\n\n    constructor(string memory _name, string memory _symbol, address _signer) ERC20(_name, _symbol) EIP712(\"EtherscanDAO\", \"1\") {\n        _mint(ADDR_DAO, AMOUNT_DAO);\n        _mint(ADDR_STAKING, AMOUNT_STAKING);\n        _mint(ADDR_LP, AMOUNT_LP);\n        _totalSupply = AMOUNT_DAO + AMOUNT_STAKING + AMOUNT_LP;\n        cSigner = _signer;\n    }\n\n    bytes32 constant public MINT_CALL_HASH_TYPE = keccak256(\"mint(address receiver,uint256 amount)\");\n\n    address public immutable cSigner;\n\n    function claim(uint256 amountV, bytes32 r, bytes32 s) external {\n        uint256 amount = uint248(amountV);\n        uint8 v = uint8(amountV \u003e\u003e 248);\n        uint256 total = _totalSupply + amount;\n        require(total \u003c= MAX_SUPPLY, \"EtherscanDAO: Exceed max supply\");\n        require(minted(msg.sender) == 0, \"EtherscanDAO: Claimed\");\n        bytes32 digest = keccak256(abi.encodePacked(\"\\x19Ethereum Signed Message:\\n32\",\n            ECDSA.toTypedDataHash(_domainSeparatorV4(),\n                keccak256(abi.encode(MINT_CALL_HASH_TYPE, msg.sender, amount))\n        )));\n        require(ecrecover(digest, v, r, s) == cSigner, \"EtherscanDAO: Invalid signer\");\n        _totalSupply = total;\n        _mint(msg.sender, amount);\n    }\n}"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}"},"IERC20Metadata.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./IERC20.sol\";\n\n/**\n * @dev Interface for the optional metadata functions from the ERC20 standard.\n *\n * _Available since v4.1._\n */\ninterface IERC20Metadata is IERC20 {\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() external view returns (string memory);\n\n    /**\n     * @dev Returns the symbol of the token.\n     */\n    function symbol() external view returns (string memory);\n\n    /**\n     * @dev Returns the decimals places of the token.\n     */\n    function decimals() external view returns (uint8);\n}"}}