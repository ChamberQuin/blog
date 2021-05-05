[toc]

# Tomcat连接机制

# 基本概念
1. Connector

	Connector是本地 *监听* 端口的抽象。
	
	* ProtocolHandler
		* Endpoint 网络IO
		* ConnectionHandler
		* setSoLinger, setSoTimeout, setTcpNoDelay
	* Adapter 请求处理器的代理
	* Request/Response

	支持
	
	* HTTP1.1
		* BIO
		* NIO
		* NIO2
		* APR/native?
	* AJP

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
	


高效/高性能（传输二进制，简单连接池？）
与常用反向代理模块mod_jk, mod_proxy集成
Tomcat提供丰富的协议转换API，对HTTP姿势友好

``` java
    protected final ProtocolHandler protocolHandler;
    protected Adapter adapter = null;
```

``` java
    public Adapter getAdapter();
    public Executor getExecutor();

    /**
     * Initialise the protocol.
     */
    public void init() throws Exception;


    /**
     * Start the protocol.
     */
    public void start() throws Exception;


    /**
     * Pause the protocol (optional).
     */
    public void pause() throws Exception;


    /**
     * Resume the protocol (optional).
     */
    public void resume() throws Exception;


    /**
     * Stop the protocol.
     */
    public void stop() throws Exception;


    /**
     * Destroy the protocol (optional).
     */
    public void destroy() throws Exception;
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

