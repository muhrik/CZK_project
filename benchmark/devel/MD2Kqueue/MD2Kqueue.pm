fdctmc

//model specific constants
const int K = 5; // number of slots in the queue

// transition costs
const double REJECT_COST=1.0; // cost for rejecting an arrival (queue full)

rewards //costs for rejecting arrivals
	[reject] true : REJECT_COST; 
endrewards

// rates
const double ARRIVAL = 0.9;    

module MD2Kqueue

fdelay service1 = 1.0;   //time required to serve arrivals in station 1
fdelay service2 = 1.0;   //time required to serve arrivals in station 2
		
	station1busy: [0..1] init 0; // station 1. 1-busy,0-idle 
	station2busy: [0..1] init 0; // station 2. 1-busy,0-idle 
	queueCapacity: [0..K] init K; // amount of free slots in the queue
	
	[reject] (queueCapacity=0) -> ARRIVAL: (queueCapacity'=queueCapacity); //nothing happens

	[accept1First] (queueCapacity=K) & (station1busy=0) -> (ARRIVAL * 0.5): (queueCapacity'=queueCapacity-1) & (station1busy'=1); // we deal with nondeterminism using weights. If both stations are free we give them equal probability
	//there is concurrency here, because both stations are idle
	[accept2First] (queueCapacity=K) & (station2busy=0) -> (ARRIVAL * 0.5): (queueCapacity'=queueCapacity-1) & (station2busy'=1); // we deal with nondeterminism using weights. If both stations are free we give them equal probability

	[accept1Second] (queueCapacity=K-1) & (station1busy=0) -> (ARRIVAL): (queueCapacity'=queueCapacity-1) & (station1busy'=1);
	// no concurrency, because one station is busy
	[accept2Second] (queueCapacity=K-1) & (station2busy=0) -> (ARRIVAL): (queueCapacity'=queueCapacity-1) & (station2busy'=1);

	[acceptEnqueue] (queueCapacity>0) & (station1busy=1) & (station2busy=1) -> (ARRIVAL): (queueCapacity'=queueCapacity-1); // both are busy

	[serve1last] (station1busy=1) & (queueCapacity>K-3) --service1-> (station1busy'=0) & (queueCapacity'=queueCapacity+1); //serve the last arrival

	[serve1next] (station1busy=1) & (queueCapacity<K-2) --service1-> (queueCapacity'=queueCapacity+1); // serve and start serving next one in the queue immediately

	[serve2last] (station2busy=1) & (queueCapacity>K-3) --service2-> (station2busy'=0) & (queueCapacity'=queueCapacity+1); //serve the last arrival

	[serve2next] (station2busy=1) & (queueCapacity<K-2) --service2-> (queueCapacity'=queueCapacity+1); // serve and start serving next one in the queue immediately

endmodule

