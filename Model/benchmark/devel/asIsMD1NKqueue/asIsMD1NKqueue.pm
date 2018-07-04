fdctmc

//model specific constant
const int K = 5; // number of customers who exist
const int N = 2; // capacity of the queue

// rates
const double THINKING_RATE = 0.9;

module asIsMD1NKqueue

fdelay service = 1.0;  	

	thinkingCustomers: [0..K] init K; // number of customers who are still thinking about making a service request.
	queueSize: [0..N] init 0; // number of customers in the queue
	serving: [0..1] init 0; // 0- currently not serving. 1-currently serving

	[thinking] (thinkingCustomers>0) & (queueSize<N) -> (THINKING_RATE * thinkingCustomers): (serving'=1) & (queueSize'=queueSize+1) & (thinkingCustomers'=thinkingCustomers-1);

	[serving] (queueSize>1) --service-> (thinkingCustomers'=thinkingCustomers+1) & (queueSize'=queueSize-1);

	[servingLast] (queueSize=1)  --service-> (thinkingCustomers'=thinkingCustomers+1) & (queueSize'=queueSize-1) & (serving'=0);

endmodule

