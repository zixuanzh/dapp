pragma solidity ^0.4.8;

contract Token {
	
	function Token() {

	}

	/**
	* return total token supply
	*/
	function totalSupply() returns (uint256) {

	}

	/**
	* @param owner address: _owner
	* return balance of Token owned by _owner
	*/
	function balanceOf(address _owner) returns (uint256) {

	}

	/**
	* @param address to be sent to: _to
	* @param amount: _value
	* send tokens to another address
	*/
	function transfer(address _to, uint256 _value) {

	}

	/**
	* @param address to be sent from: _from
	* @param address to be sent to: _to
	* @param amount: _value
	* transfer tokens on behalf of another user
	*/
	function transferFrom(address _from, address _to, uint256 _value) {

	}

	/**
	* @param address to be allowed to send tokens on your behalf: _spender
	* @param amount: _value
	* allow another user to transfer tokens on your behalf
	*/
	function approve(address _spender, uint256 _value) {

	}

}