[toc]

# 杂项

# 高并发

## 缓存

### 可用性

通过集群模式提高读吞吐，通过哨兵实现高可用。

#### 主从架构

> redis replication -> 主从架构 -> 读写分离 -> 读水平扩容 -> 高并发

主从机制，一主多从，主写从读（读写分离），写入w级别，读取10w级别，适用读多写少，支持读水平扩容。

1. redis replication机制

	* **异步**同步，slave会周期性确认已复制的数据量（since v2.8+）
	* 支持多slave复制
	* 支持从slave复制
	* slave复制时，不block读操作（依赖旧数据），但复制完成时，需要删除旧数据集并加载新数据集，此时会暂停服务
	* slave能横向扩容

	建议开启master node持久化，而不是用slave node作热备

	* 避免master宕机重启后数据为空，同步到slave导致slave也空了
	* 避免主从不一致时，主从切换时丢失数据

	建议备份master
	
	* 避免本地文件丢失后，能从备份rdb恢复master，确保启动时有数据
	* 虽然slave能自动接管master，也可能sentinel还没检测到master failure，master就重启并丢数据，最终导致slave也被清空

2. redis主从复制原理

	``` plantuml
	@startuml
	master <- slave: PSYNC
	note right
	1. 首次连接: 全量复制
	2. 重新连接: 部分复制
	end note
	master -> master: 生成RDB快照；内存中缓存新收到的写命令
	master -> slave: 发送RDB
	slave -> slave: 先写磁盘，再加载到内存
	master -> slave: 同步内存中缓存的写命令
	slave -> slave: 先写磁盘，再加载到内存
	@enduml
	```

	1. redis主从复制到断点续传

		主从复制时如果断网，支持断点续传（since v2.8）。
		
		master会在内存中维护一个`backlog`，master、slvae都保存`replica offset`、`master run id`，`replica offset`保存在`backlog`中。
		
		如果断网，slave会让master从上次`replica offset`继续复制，如果没找到该offset，则执行一次`resynchronization`。
		
	2. 无磁盘化复制
	
		配置`repl-diskless-sync yes`后，master在内存中直接创建RDB后发送给slave，RDB不落盘。
		
		```
		repl-diskless-sync yes
	
		# 5s后再开始复制，来等待更多slave重新连接（？？？）
		repl-diskless-sync-delay 5
		```
		
	3. slave处理过期key
		
		slave不主动过期key，只被动等待master过期key、淘汰key后，master模拟del命令同步到slave。
	
3. 复制流程

	
	
#### 哨兵机制




## 数据库

### 分库分表

### 读写分离

## 搜索引擎


# 分布式

## 系统拆分

## 分布式服务框架

## 分布式锁

## 分布式事务

## 分布式会话

# 高可用

## 隔离

## 限流

## 熔断

## 降级

# 微服务


