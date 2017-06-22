pragma solidity ^0.4.11;

contract WowBuy {
	enum State { Created, Confirmed, Disabled }
	event Created();
	event Confirmed();
	event Received();
	event Refunded();
	State state;
	address buyer;
	address seller;
	uint value;

	modifier require(bool c) { if (!c) throw; _;}
	modifier buyerOnly { if (msg.sender != buyer) throw; _;}
	modifier sellerOnly { if (msg.sender != seller) throw; _;}
	modifier inState(State s) { (if state != s) throw; _;}

	function makePurchase() 
		require(value % 2 == 0) 
		payable
	{
		seller = msg.sender;
		value = msg.value / 2;
		state = State.Created;
		Created();
	}
	function confirmPurchase()
		inState(State.Created)
		require(msg.value == 2 * value)
		payable
	{
		buyer = msg.sender;
		state = state.Confirmed;
		Confirmed();
	}
	function confirmReceived
		inState(State.Confirmed)
		buyerOnly
	{
		buyer.send(value);
		seller.send(this.balance);
		state = state.Disabled;
		Received();
	}
	function makeRefund() 
		inState(State.confirmed)
		sellerOnly
	{
		buyer.send(2*value);
		seller.send(this.balance);
		state = State.Disabled;
		Refunded()
	}
	function gambleMuch {

	}
}