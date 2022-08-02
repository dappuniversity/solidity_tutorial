// SPDX-License-Identifier: Unlicense

// Contract inspired by Damn Vulnerable DeFi
// Original Contract:
// https://github.com/OpenZeppelin/damn-vulnerable-defi/blob/master/contracts/unstoppable/ReceiverUnstoppable.sol

import "hardhat/console.sol";
import "./Token.sol";
import "./FlashLoan.sol";

contract FlashLoanReceiver {

    FlashLoan private pool;
    address private owner;

    event LoanReceived(address token, uint256 amount);

    constructor(address poolAddress) public {
        pool = FlashLoan(poolAddress);
        owner = msg.sender;
    }

    function receiveTokens(address tokenAddress, uint256 amount) external {
        require(msg.sender == address(pool), "Sender must be pool");

        // Emit event to prove tokens receive in test
        emit LoanReceived(tokenAddress, amount);

        // Use your funds here!

        // Return all tokens to the pool
        require(Token(tokenAddress).transfer(msg.sender, amount), "Transfer of tokens failed");
    }

    function executeFlashLoan(uint256 amount) external {
        require(msg.sender == owner, "Only owner can execute flash loan");
        pool.flashLoan(amount);
    }
}
