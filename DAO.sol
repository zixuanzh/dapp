pragma solidity ^0.4.8;

import './StandardToken.sol'

contract DAO {
	StandardToken token;
	uint tokenBuyPeriod;
	enum DAOState = {buyState, investState};
	DAOState currentDAOState;
	address DAOOwner;
	uint tokenPrice;
	uint proposalNum;

	struct Proposal {
		uint upVotes;
		uint downVotes;
		address payoutAddress;
		string description;
		uint amount;
		uint ROI;
		uint votingEnds;
	}

	mapping(uint => Proposal) proposals;
	mapping(address => bool) lockedAddresses;

	funciton DAO(uint tokenCost, uint tokenSellLength) {
		token = new StandardToken();
		buyPeriod = now + tokenSellLength;
		currentDAOState = DAOState.buyState;
		DAOOwner = msg.sender;
		uint tokenPrice = tokenCost;
	}

	modifier atDAOState(DAOState _state) {
		if (_state == currentDAOState) {_;}
	};

	modifier updateDAOState() {
		if (now > tokenBuyPeriod && currentDAOState == DAOState.buyState) {
			currentDAOState = DAOState.investState;
			{_;}
		}
	}

	modifier onlyDAOOwner() {
		if (msg.sender == DAOOwner) {_;}
	}

	modifier onlyUnlockedToken() {
		if (!lockedAddresses[msg.sender]) {_;}
	}

	modifier stillVoting(uint _proposalID) {
		if (proposals[_proposalID].votingEnds > now) {_;}
	}

	modifier votingCompleted(uint _proposalID) {
		if (proposals[_proposalID].votingEnds < now) {_;}
	}

	function invest() payable atDAOState(DAOState.buyState) returns (bool) {
		uint numToken = msg.value / tokenPrice;
		if (token.approve(msg.sender, numToken)) {return true};
	}

	function newProposal(address _recipient, uint _amount, 
		string _description, uint _amountROI, uint votingPeriod) updateDAOState atDAOState(DAOState.investState)
			returns (uint proposalID) {
		proposalID = sha3(proposalNum);
		proposals[proposalID] = Proposal({
				upVotes: 0,
				downVotes: 0,
				payoutAddress: _recipient,
				description: _description,
				amount: _amount,
				ROI: _amountROI,
				votingEnds: now + votingPeriod
			});
		proposalNum += 1;
		return proposalID;
	}

	function vote(uint _proposalID, bool _supportProposal) stillVoting {
		lockedAddresses[msg.sender] = true;
		if (_supportProposal) {
			proposals[_proposalID].upVotes += 1;
		} else {
			proposals[_proposalID].downVotes += 1;
		}
	}

	function executeProposal(uint _proposalID) votingCompleted returns (bool success) {
		if (proposals[_proposalID].upVotes > proposals[_proposalID].downVotes) {
			if (proposals[_proposalID].payoutAddress.send(proposals[_proposalID].amount)) {
				return true;
			} else {
				return false
			}
		} else {
			return false;
		}
		lockedAddresses[msg.sender] = false;
	}

	function transfer(address _to, uint _value) returns (bool) {
		if (lockedAddresses[msg.sender]) {
			return false;
		} else {
			token.transfer(_to, _value)
			return true;
		}
	}

	function approve(address _spender, uint _value) returns (bool) {
		if (lockedAddresses[msg.sender]) {
			return false;
		} else {
			token.approve(_spender, _value);
			return false;
		}
	}

	function transferFrom(address _from, address _to, 
		uint _value) returns (bool) {
		if (lockedAddresses[_from]) {
			return false;
		} else {
			token.transferFrom(_from, _to, _value);
		}
	}

	function payBackInvestment(uint _proposalID) returns (bool success) {
		if (msg.sender.send(proposals[_proposalID].ROI)) {
			return true;
		} else {
			return false;
		}
	}

	function withdrawEther() returns (bool) {
		if (lockedAddresses[msg.sender]) {
			return false;
		} else {

		}
	}

}