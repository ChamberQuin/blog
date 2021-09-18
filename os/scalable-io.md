# Scalable I/O

1. Basics
	
	Web services, Distributed Objects, etc.
	
	Most have same basic structure, but differ in nature and cost of each step(XML parsing, File transfer, Web page generation, computational services, ...)
		
	* 	Read request
	* 	Decode request
	* 	Process service
	* 	Encode reply
	* 	Send reply
	
	Classic serivce design
	
	![](media/16297998364945.jpg)
	
	Classic ServerSocket Loop
	
	![](media/16298011369190.jpg)

2. Scalability Goals
	* Graceful degradation under increasing load (more clients)
	* Continuous improvement with increasing resources (CPU, memory, disk, bandwidth)
	* Also meet availability and performance goals
		* Short latencies
		* Meeting peak demand
		* Tunable quality of service
	* Divide-and-conquer is usually the best approach for achieving any scalability goal

3. Divide and Conquer
	
	* Divide processing into small tasks
		* Each task performs an action without blocking
	* Execute each task when it is enabled
		* Here, an IO event usually serves as trigger
			![](media/16298059904417.jpg)
		* Basic mechanisms supported in java.nio
			* *Non-blocking* reads and writes
			* *Dispatch* tasks associated with sensed IO events
		* Endless variation possible
			* A family of event-driven designs
		
4. Event-Driven Designs
	
	优缺点
	
	* Usually more efficient than alternatives
	
5. Reactor Pattern
	
	Events in AWT
	
	![](media/16298064320477.jpg)

	Basic reactor design with single thread
	
	![](media/16298065986367.jpg)
	
	* *Reactor* responds to IO events by dispatching the appropriate handler

	API in java.nio

	* Channels
	
	![](media/16298719458690.jpg)
	
	![](media/16298719619896.jpg)
	
	![](media/16298719767980.jpg)
	
	![](media/16298757027994.jpg)
	
	![](media/16298757136927.jpg)
	
	![](media/16298757253389.jpg)
	
	Multithreaded Designs
	
	* Strategically add threads for scalability
		* Mainly applicable to multiprocessors
	* Worker Threads
		* Reactors should quickly trigger handlers
			* Handler processing slows down Reactor
		* Offload non-IO processing to other threads
	* Multiple Reactor Threads
		* Reactor threads can saturate doing IO
		* Distribute load to other reactors
			* Load-balance to match CPU and IO rates
	
	Worker Threads
	
	* Offload non-IO processing to speed up Reactor thread
	
	Worker Thread Pools
	
	![](media/16298764971908.jpg)
	
	![](media/16298765226293.jpg)
	
	Coordinating Tasks
	
	* Handoffs
	
	Using Multiple Reactors
	
	![](media/16298766806408.jpg)
	
	TBC
