pragma solidity ^0.4.4;

import "./ZStock.sol";
import "./Token.sol"

contract Exchange {

	// keeps track of how much Ether a user has
	mapping(address => uint) etherBalance;

	// maps users => tokens => tokenBalance balance structs. 
	// This keeps track the amount of tokens and price they are selling said tokens for. 
	mapping(address => mapping(address => tokenBalance)) tokenBalances;

	// When used in mapping, this keeps track of how many of a specific 
	// type of token a user has deposited or bought. When price == 0, 
	// token is not being sold. 
	struct tokenBalance {
		uint numTokens;
		uint price;
	}

	// this allows only users with tokens to call contracts
	modifier ownsTokens(address _owner, address _token) {
		if (balanceOf(_owner, _token) == 0) throw;
		_;
	}

	function Exchange() {
		
	}

	// Here is what happens for this function to run:
	// On an already existing token (hence called NateCoin) contract, 
	// a user calls the function approve( addressofDecentralizedExchange, _amount). 
	// This gives the DecentralizedExchange the power to take _amount worth of NateCoins from the users balance on NateCoin.
	// The user calls depositToken(addressNateCoin, _amount).
	// The first line of code creates the variable “token” of type Token. 
	// This code tells the  DecentralizedExchange the interface of NateCoin (so it can call functions on it)
	// In the next line, the DecentralizedExchange attempts to transfer money within NateCoin to itself. 
	// If the user has not completed step 1, this will throw
	// The DecentralizedExchange updates the balance of the user for NateCoin. 
	// Now, the user has _amount more NateCoins deposited within the smart contract. 
	function depositToken(address _token, uint _amount)  {
		Token token = Token(_token);
		// if (!token.transferFrom(msg.sender, this, _amount)) throw;
		tokenBalances[msg.sender][_token].numTokens += _amount;
		if (!token.transferFrom(msg.sender, this, _amount)) throw;
	}


	// update balance BEFORE transfer is called
	function withdrawToken(address _token, uint _amount) {
		Token token = Token(_token);
		// if (!tokenBalances[msg.sender]) throw;
		// if (!tokenBalances[msg.sender][_token]) throw;
		if (tokenBalances[msg.sender][_token].numTokens < _amount) throw;
		tokenBalances[msg.sender][_token].numTokens -= _amount;
		etherBalance[msg.sender] += _amount;
		// token.transfer(msg.sender, _amount);
		msg.sender.send(_amount);
	}

	function balanceOf(address _owner, address _token) {
		// if (!tokenBalances[_owner][_token]) throw;
		// if (tokenBalances[_owner][_token] < 0) throw;
		return tokenBalances[_owner][_token].numTokens;
	}

	function setPrice(address _token, uint _price) ownsToekns(msg.sender, _token) {
		// if (_price <= 0) throw;
		// if (!tokenBalances[msg.sender][_token]) throw;
		// if (tokenBalances[msg.sender][_token] <= 0) throw;
		tokenBalances[msg.sender][_token].price = _price;
	}
	
	// msg.value is the ether mount
	function buyToken(address _token, address _seller, address _amount) {
		Token token = Token(_token);
		if (tokenBalances[_seller][_token].price * _amount < msg.value) throw;
		if (etherBalance[msg.sender] < msg.value) throw;
		if (tokenBalances[_seller][_token].numTokens < _amount) throw;
		tokenBalances[_seller][_token].numTokens -= _amount;
		tokenBalances[msg.sender][_token].numTokens += _amount;
		etherBalance[msg.sender] -= _amount;
		etherBalance[_seller] += _amount;
	}

	// .send send ether to someone
	function withdrawEther(uint _amount) {
		// if (_amount <= 0) throw;
		// if (!etherBalance[msg.sender]) throw;
		// if (etherBalance[msg.sender] <= 0) throw;
		if (etherBalance[msg.sender] < _amount) throw;
		etherBalance[msg.sender] -= _amount;
		// this.send(msg.sender, _amount);
		msg.sender.send(_amount);
	}


}
