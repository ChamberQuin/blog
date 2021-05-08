[toc]

# Tomcat连接机制

# 基本概念
1. Connector

	Connector是本地 *监听* 端口的抽象。
	
	* ProtocolHandler
		* Endpoint
			* Acceptor
			* Handler
			* SocketProcessor
			
			* AsyncTimeout
			* LimitLatch
			* unlockAccept WHY?
		* ConnectionHandler
			* Processor
				* Set up IO
				* Read and parse request headers
				* Call adapter.service()
					* create servlet request & response
		* setSoLinger, setSoTimeout, setTcpNoDelay
	* Adapter 请求处理器的代理
	* Request/Response

	支持IO	

	* BIO
	* NIO
	* NIO2
	* APR
	
	支持协议
	
	* HTTP
	* AJP
		* 高效/高性能（传输二进制，简单连接池？）
		* 与常用反向代理模块mod_jk, mod_proxy集成
		* Tomcat提供丰富的协议转换API，对HTTP姿势友好

2. Container
	
	Container是请求处理器的抽象，负责执行请求并返回响应。
	
	* Engine
	* Host
	* Context
	* Wrapper

	关联组件
	
	* Loader
	* Logger
	* Manager
	* Realm
	* Resources
	
``` plantuml
@startuml

package tomcat {
	interface Handler {
		+ enum SocketState socketState
		// OPEN, CLOSED, LONG, ASYNC_END, SENDFILE, UPGRADING, UPGRADED, SUSPENDED
	}
	abstract Acceptor {
		+ enum AcceptorState acceptorState
		// NEW, RUNNING, PAUSED, ENDED
	}
	abstract AbstractEndpoint {
		# Acceptor[] acceptors
		# BindState bindState
		// UNBOUND, BOUND_ON_INIT, BOUND_ON_START
		--
		
	}
	
	AbstractEndpoint +-down- Handler
	AbstractEndpoint +-down- Acceptor
}

package catalina {
	class Connector
	interface Lifecycle
	class LifecycleMBeanBase implements Lifecycle {
	
	}
	interface Service extends Lifecycle {
	
	}
}

package coyote {
	interface ProtocolHandler
	abstract AbstractProtocol implements ProtocolHandler {
		- AbstractEndpoint endpoint // low-level I/O
		- AsyncTimeout async
		+ Executor executor
		# Adapter adapter
		--
		Handler getHandler()
		..
		+ init()
		+ start()
		+ pause()
		+ resume()
		+ stop()
		+ destroy()
	}
	abstract AbstractConnectionHandler implements Handler {
		- AbstractProtocol proto
		- Map<S,Processor> connections
		- RecycledProcessors recycledProcessors
	}
	class RecycledProcessors
	
	AbstractProtocol +- AbstractConnectionHandler
	AbstractProtocol +- RecycledProcessors
	AbstractProtocol --> Adapter
	AbstractProtocol --> Handler
	abstract AbstractHttp11Protocol extends AbstractProtocol
	abstract AbstractAjpProtocol extends AbstractProtocol
	abstract AbstractHttp11JsseProtocol extends AbstractHttp11Protocol
	class Http11AjpProtocol extends AbstractHttp11Protocol
	class Http11Protocol extends AbstractHttp11JsseProtocol
	class Http11NioProtocol extends AbstractHttp11JsseProtocol
	class Http11Nio2Protocol extends AbstractHttp11JsseProtocol

	interface Adapter
	class CoyoteAdapter implements Adapter
	
}

class Connector extends LifecycleMBeanBase {
	# Service service
	# ProtocolHandler protocolHandler
	# Adapter adapter
	--
	+ Connector(String protocol)
	..
	# void initInternal()
	# void startInternal()
	# void stopInternal()
	# void destroyInternal()
	..
	+ Request createRequest()
	+ Response createResponse()
}






Connector --> ProtocolHandler




@enduml
```



``` java
    protected final ProtocolHandler protocolHandler;
    protected Adapter adapter = null;
```


```
The valid state transitions for components that support Lifecycle are:
              start()
    -----------------------------
    |                           |
    | init()                    |
   NEW -»-- INITIALIZING        |
   | |           |              |     ------------------«-----------------------
   | |           |auto          |     |                                        |
   | |          \|/    start() \|/   \|/     auto          auto         stop() |
   | |      INITIALIZED --»-- STARTING_PREP --»- STARTING --»- STARTED --»---  |
   | |         |                                                            |  |
   | |destroy()|                                                            |  |
   | --»-----«--    ------------------------«--------------------------------  ^
   |     |          |                                                          |
   |     |         \|/          auto                 auto              start() |
   |     |     STOPPING_PREP ----»---- STOPPING ------»----- STOPPED -----»-----
   |    \|/                               ^                     |  ^
   |     |               stop()           |                     |  |
   |     |       --------------------------                     |  |
   |     |       |                                              |  |
   |     |       |    destroy()                       destroy() |  |
   |     |    FAILED ----»------ DESTROYING ---«-----------------  |
   |     |                        ^     |                          |
   |     |     destroy()          |     |auto                      |
   |     --------»-----------------    \|/                         |
   |                                 DESTROYED                     |
   |                                                               |
   |                            stop()                             |
   ----»-----------------------------»------------------------------
  
```

# BIO

# NIO

# NIO2

# APR

