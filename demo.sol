pragma solidity ^0.4.11;

contract Purchase {
	address seller;
	address buyer;
	uint value;
	enum State { Created, Confirmed, Disabled }
	State state;
	// Modifier acts a a macro that prepends or appends to functions
	// Modifier can be used to replace various condition checkers
	modifier require(bool c) { if (!c) throw; _; }
	modifier inState(State s) { if (state != s) throw; _; }
	modifier onlyBuyer() { if (msg.sender != buyer) throw; _; }
	modifier onlySeller() { if (msg.sender != seller) throw; _; }
	// Event behaves similar to function with no implementation, but has
	// side effect of storing data, where pertinent, onto blockchain for easy access
	event PurchaseConfirmed();
	event Received();
	event Refunded();

	function Purchase() 
	    require(msg.value % 2 == 0) 
	    payable
    {
		// Constructor function that creates the contract
		seller = msg.sender;
		value = msg.value / 2;
		// Not need to put state in constructor; default is first value
		// specified in the enum
	}
	function confirmPurchase() 
		inState(State.Created) 
		require(msg.value != 2 * value)
		payable
	{
		buyer = msg.sender;
		state = State.Confirmed;
		PurchaseConfirmed();
	}
	function confirmReceived() 
		inState(State.Confirmed) 
		onlyBuyer
	{
		buyer.send(value);
		seller.send(this.balance);
		state = State.Disabled;
		Received();
	}
	function refundBuyer() 
		inState(State.Confirmed)
		onlySeller
	{
		buyer.send(2*value);
		seller.send(this.balance);
		state = State.Disabled;
		Refunded();
	}
}
