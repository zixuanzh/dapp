pragma solidity ^0.4.8;

/**
* Special Features:
*	issuer can issue stock to addresses
*	issuer can pay dividend to all addresses currently holding ZStock
*/

contract ZStock {

	uint256 total_supply;
	uint256 total_remaining;
	// total number of holders with nonzero ZStock
	uint256 total_holder;
	uint256 next_index;
	address public issuer;
	mapping(address => uint256) balance;
	mapping(address => mapping(address => uint256)) approved;
	// index each account once it was issued a ZStock
	mapping(uint => address) accountIndex;
	
	function ZStock() {
		total_supply = 1000000;
		total_remaining = 1000000;
		total_holder = 0;
		next_index = 0;
		issuer = msg.sender;
	}

	/**
	* return total token supply
	*/
	function totalSupply() returns (uint256) {
		return total_supply;
	}

	/**
	* @param owner address: _owner
	* return balance of ZStock owned by _owner
	*/
	function balanceOf(address _owner) returns (uint256) {
		return balance(_owner);
	}

	/**
	* @param address to be sent to: _to
	* @param amount: _value
	* send tokens to another address
	*/
	function transfer(address _to, uint256 _value) {
		if (balance[msg.sender] < _value) throw;
		if (_value <= 0) throw;
		balance[msg.sender] -= _value;
		balance[_to] += _value;
		if (balance[msg.sender] == 0) {
			total_holder -= 1;
		}
	}

	/**
	* @param address to be sent from: _from
	* @param address to be sent to: _to
	* @param amount: _value
	* transfer tokens on behalf of another user
	*/
	function transferFrom(address _from, address _to, uint256 _value) {
		if (_value <= 0) throw;
		if (balance[_from] < _value) throw;
		if (approved[_from][_to] < _value) throw;
		approved[_from][_to] -= _value;
		balance[_from] -= _value;
		balance[_to] += _value;
		if (balance[_from] == 0) {
			total_holder -= 1;
		}
	}

	/**
	* @param address to be allowed to send tokens on your behalf: _spender
	* @param amount: _value
	* allow another user to transfer tokens on your behalf
	*/
	function approve(address _spender, uint256 _value) {
		if (balance[msg.sender] < _value) throw;
		if (_value <= 0) throw;
		approved[msg.sender][_spender] = _value;
	}

	/**
	* @param address to be issued tokens to: _to
	* @param amount: _value
	* issue stocks to addresses by the issuer
	*/
	function issue(address _to, uint256 _value) {
		if (msg.sender != issuer) throw;
		if (_value <= 0) throw;
		if (total_remaining <= 0) throw;
		if (total_remaining < _value) throw;
		// _to is a new address
		if (balance[_to] == 0) {
			accountIndex[next_index] = _to;
			total_holder += 1;
			next_index += 1;
		}
		balance[_to] += _value;
		total_remaining -= _value;
	}

	/**
	* @param dividend paid per user: _dividend
	* pay dividend to all holders of ZStock
	*/
	function payDividend(uint256 _dividend) {
		if (msg.sender != issuer) throw;
		if (_dividend < 0) throw;
		// we need to know total_holder here
		// so that we know the total amount of dividend to be paid
		// before issuing dividends
		if (total_remaining < total_holder * _dividend) throw;
		for (uint i = 0; i < next_index; i++) {
			// if the account holds ZStock
			if (balance[accountIndex[i]] > 0) {
				balance[accountIndex[i]] += _dividend;
				total_remaining -= _dividend;
			}
		}
	}
}