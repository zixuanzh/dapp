pragma solidity ^0.4.8;

import './StandardToken.sol'

contract DAO {
	StandardToken token;
	uint tokenBuyPeriod;
	enum DAOState = {buyState, investState};
	DAOState currentDAOState;
	address DAOOwner;
	uint tokenPrice;
	// uint tokenSupply; //number of tokens bought
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
	mapping(address => (proposal => uint)) addressProposals; //keep track of where the token is locked to
	// mapping(address => uint) tokenBalance; //number of tokens owned by each

	funciton DAO(uint tokenCost, uint tokenSellLength) {
		token = new StandardToken();
		buyPeriod = now + tokenSellLength;
		currentDAOState = DAOState.buyState;
		DAOOwner = msg.sender;
		uint tokenPrice = tokenCost;
		uint tokenSupply = 0;
	}

	modifier atDAOState(DAOState _state) {
		if (_state == currentDAOState) {_;}
	}

	modifier updateDAOState() {
		if (now > tokenBuyPeriod && currentDAOState == DAOState.buyState) {
			// currentDAOState = DAOState.investState;
			currentDAOState = DAOState(uint(currentDAOState) + 1);
			_;
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

	// modifier tokenNotLocked(address _address) {
	// 	if (!lockedAddresses[_address]) {_;}
	// }

	modifier tokenInvested(address _address, uint _proposalID) {
		if (addressProposals[_address][_proposalID]) {_;}
	}

	function invest() payable atDAOState(DAOState.buyState) returns (bool) {
		uint numToken = msg.value / tokenPrice;
		if (token.mint(msg.sender, numToken)) {return true};
	}

	function newProposal(address _recipient, uint _amount, 
		string _description, uint _amountROI, uint votingPeriod) updateDAOState atDAOState(DAOState.investState)
			returns (uint proposalID) {
		proposals[proposalNum] = Proposal({
				upVotes: 0,
				downVotes: 0,
				payoutAddress: _recipient,
				description: _description,
				amount: _amount,
				ROI: _amountROI,
				votingEnds: now + votingPeriod
			});
		proposalNum += 1;
		return proposalNum;
	}

	function vote(uint _proposalID, bool _supportProposal) stillVoting(_proposalID) {
		lockedAddresses[msg.sender] = true;
		addressProposals[msg.sender][_proposalID] = true;
		numToken = token.balanceOf[msg.sender]
		if (_supportProposal) {
			proposals[_proposalID].upVotes += numToken;
		} else {
			proposals[_proposalID].downVotes += numToken;
		}
	}

	function executeProposal(uint _proposalID) votingCompleted tokenLocked(msg.sender, _proposalID) returns (bool success) {
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
		addressProposals[msg.sender][_proposalID] = false;
	}

	function transfer(address _to, uint _value) onlyUnlockedToken(msg.sender) returns (bool) {
		token.transfer(_to, _value)
		return true;
	}

	function approve(address _spender, uint _value) onlyUnlockedToken(msg.sender) returns (bool) {
		token.approve(_spender, _value);
		return true;
	}

	function transferFrom(address _from, address _to, 
		uint _value) onlyUnlockedToken(_from) returns (bool) {
			token.transferFrom(_from, _to, _value);
			return true;
	}

	function payBackInvestment(uint _proposalID) payable returns (bool success) {
		if (msg.sender.send(proposals[_proposalID].ROI)) {
			return true;
		} else {
			return false;
		}
	}

	function withdrawEther() onlyUnlockedToken(msg.sender) returns (bool) {
		etherAmount = token.balanceOf(msg.sender) * tokenPrice;
		token.distroy(msg.sender);
		msg.sender.send(etherAmount);
	}

}