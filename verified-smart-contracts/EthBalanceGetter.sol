pragma solidity >=0.5.0;

contract EthBalanceGetter {
    function balanceOf(address account) external view returns (uint256) {
        return account.balance;
    }
}