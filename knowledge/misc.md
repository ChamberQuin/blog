[toc]

# 杂项

# 高并发

## 消息队列

### 问题、场景和对比

1. 问题

	* 增加依赖，降低可用性
	* 增加组件，提高复杂性
	* 一致性
	
2. 场景（架构、代码）

	* 解耦（推送媒体发布状态；
	* 异步（多机房备份存储；转码；
	* 削峰（发博结果；

3. 对比
	
|   | 单机吞吐量 | topic数量对吞吐量的影响 | 时效性 | 可用性 | 可靠性 | 功能支持 | 社区活跃度 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Kafka | 10w | 几百topics时，吞吐量大幅度降低 | ms以内 | 非常高（分布式，多副本，少数及其宕机不丢失数据） | 优化参数后能不丢失 | 简单的MQ功能，主要用于大数据领域的实时计算及日志采集 | 极高 |
| ActiveMQ | 1w |  | ms | 高（主从） | 较低概率丢失 | 功能极其完备 | 低 |
| RabbitMQ | 1w |   | us | 高（主从） | 基本不丢 | 并发能力强，性能极好，延时很低（基于erlang） | 较高 |
| RocketMQ | 10w | 几千topics时，吞吐量小幅度降低 | ms | 非常高（分布式） | 优化参数后能不丢失 | 功能完善，扩展性好 | 一般 |
| MCQ |  |  |  |  |  |  |
| Trigger |  |  |  |  |  |  |

### 机制及实现

MQ的基本要求是**数据不能多，也不能少**，即保证可用性、幂等性、可靠性。

#### 可用性

##### RabbitMQ可用性

RabbitMQ**基于主从**（非分布式）实现高可用。

RabbitMQ有三种模式：单机、普通集群、镜像集群。

1. 普通集群模式（无高可用）
	
	多台机器上启动多个实例，**创建的queue只放在一个实例上**，实例间同步queue的元数据，元数据记录了queue所在实例。消费时，如果本地实例没有需要的queue，则本地实例会从queue所在实例上拉取数据。
	
	使用时，消费者要么**随机连接一个实例并拉取数据**，要么**固定连接queue所在实例并消费数据**，前者有**数据拉取的开销**，后者有**单实例性能瓶颈**。
	
	由于queue单点，当queue所在实例宕机，会导致数据不可用，直到**持久化的数据所在的实例被恢复**。
	
	所以，普通集群模式能提高吞吐量，但没管高可用。
	
2. 镜像集群模式（高可用）

	多台机器上启动多个实例，**queue的元数据、消息同时存在于多个实例上**，即**每个实例都有queue的完整镜像**。生产消息时，会**自动同步消息到多个实例的queue**。
	
	由于多份完整镜像，**性能开销大**，**无法线性扩展**。
	
##### Kafka可用性

Kafka由多个broker组成，每个broker是一个节点。topic可以划分为多个partition，每个partition可以存放于不同的broker上，每个partition存放一部分数据。

Kafka是**分布式消息队列**，每个节点只存放部分queue数据；RabbitMQ是传统消息队列，每个节点存放完整的queue数据。

Kafka 0.8之前没有HA，任一broker宕机，则落在上面的partition无法读写。Kafka 0.8提供了**replica**方式的HA，所有replica选举1个leader。leader处理生产/消费，也负责同步数据到replica。Kafka会均匀地将replica分散到不同broker，保证容错性。

1. 生产

	生产者写leader，leader落盘，replica主动从leader拉数据，同步后replica给leader发ack，leader收完所有ack后，会返回写成功的 消息给生产者。（据说有其他模式，可以调整）
	
2. 消费

	消费者只读leader，而不读replica，可以规避主从一致性问题，降低复杂度。
	但只有当消息被所有replica都同步成功（即返回ack）时，消息才能被消费。

#### 幂等性

RabbitMQ、RocketMQ、Kafka，都有可能会出现消息重复消费的问题，通常幂等性由consumer保证，而不是MQ。

consumer可以通过**查询-更新**、**唯一性**等保证幂等性。

##### Kafka幂等性

Kafka中，offset表示消息序号，produce消息会增加offset，consume消息时会定时提交已消费消息的offset，下次从offset而不是从头开始消费。

当consumer消费了消息但还没提交offset时就重启了，会导致部分消息重复消费。

#### 可靠性

丢数据可能发生在Producer、MQ、Consumer中。

##### RabbitMQ可靠性

1. Producer -> MQ

	因网络等原因丢失数据，可以通过RabbitMQ提供的事务功能 `channel.txSelect` ，再发送消息。如果消息没被RabbitMQ接收，生产者会收到异常报错，可以回滚事务 `channel.txRollback`，然后重试发送；如果收到了消息，可以提交事务 `channel.txCommit`。
	
	但是，RabbitMQ的事务机制会比较耗性能，会**降低吞吐量**。
	
	还可以通过开启**confirm**模式，Producer每次写消息都会分配唯一id。如果写入了RabbitMQ，RabbitMQ会回ack；如果没写入RabbitMQ，RabbitMQ会回调Producer的**nack**接口，Producer可以重试。此外，Producer还能结合业务自己维护id状态。

2. MQ
	
	RabbitMQ消息先写内存，可以**开启持久化**，在RabbitMQ回复后会自动读之前存的数据。
	但是，如果消息还没来得及持久化，RabbitMQ就挂了，还是会丢少量数据，但概率较小。
	
	设置持久化有两个步骤
	
	* 创建queue时设为持久化，则RabbitMQ会持久化queue**元数据**
	* 消息的 `deliveryMode` 设为2，则Rabbit会持久化消息

3. MQ -> Consumer

	因网络、Consumer异常等原因没消费数据但被RabbitMQ误认为已消费，可以通过RabbitMQ提供的 **ack机制**，即关闭RabbitMQ的自动ack，改为Producer调api显式ack。如果RabbitMQ认为消息没处理完，会将消息分配给其他Consumer。
	
综上，可以通过**生产者开启confirm**、**MQ开启持久化**、**Consumer自定义ack**保证可靠性。

##### Kafka可靠性

1. Producer -> MQ

	由于leader只在replica都同步完数据后，才认为写成功，所以不会丢。生产者会无限重试，直到成功。
	
2. MQ

	broker宕机后重新选partition的leader时，如果凉了的leader还有数据没同步到replica，会丢数据。
	
	参考raft选主的策略，可以设置如下参数避免丢失
	
	* `replication.factor > 1` 保证每个partition至少2个副本
	* `min.insync.replicas > 1` 保证leader至少感知到1个replica还和自己保持联系，确保新老leader接替
	* `acks=all` 保证消息写入所有replica后才认为写成功
	* `retries=MAX` 保证写失败时无限重试（？？？有风险吧？？？）
	
#### 顺序性

不同的key叫并发，同一个key才叫乱序，乱序常发生在

* 一个queue多个consumer，consumer顺序，但consumer处理速度不同导致落地乱序

其他情况的乱序应该由MQ保证

* 一个key多个queue，producer写queue乱序
* 一个key多个queue，consumer读queue乱序

解决方案有2个路子

1. 1个topic，1个partition，1个consumer，consumer单线程消费，适用吞吐量低的场景
2. consumer维护n个内存队列，相同的key落同一内存队列，然后起n个线程分别消费n个内存队列，适用吞吐量较高的场景

#### 延迟及过期失效

消息堆积按严重性有三种情况

* 消息延迟
* 消息过期失效但没丢
* 消息丢失

消息堆积问题需要防患于未然，预防大于治疗

* 隔离，重要消息写独立的queue，MQ磁盘预留更多冗余
* 降级，consumer要支持降级，负载过高时考虑无损降级、有损降级非核心功能
* 报警，监控堆积状态、消费状态，尽早发现、处理

但真堆积了也别方，先明确是写入/消费的问题

* 写入过多，先定位消息来源，来源有问题就干掉，没问题就扩容consumer
* 消费过慢，先无脑重启尝试恢复消费速度，重启无效就无脑扩容，扩容无效就无脑扩queue，优先解决问题，再查慢的原因

##### RabbitMQ过期失效

RabbitMQ可以设置过期时间，当消息在queue中既要超过一定时间会被清理掉。需要重新找回丢失数据，写到queue中。

#### 设计MQ

TBC

问题 + 解决原理 + 实际例子

## 缓存

### 问题、场景和对比

1. 问题和场景

	引入多级存储，解决IO速度不匹配的问题，实现低延迟、高并发。

2. 引入的新问题
	
	* 数据不一致
	* 可用性强依赖缓存，如缓存穿透引发服务雪崩，缓存本身雪崩等
	* 缓存并发竞争，如并发写同一个key，但顺序不对等

3. 对比
	
	|   | 数据结构 | 集群模式 | 性能 | 线程模型 |
	| --- | --- | --- | --- | --- |
	| Redis | string,hash,list,set,sorted set,pub/sub | cluster(v3.x+) | 单核，适用小数据 | 单线程 |
	| Memcached | string | 调用方同步 | 多核，适用100k以上大数据 | 多线程 |

### Redis原理及实现

#### 线程模型

TBC

> 单线程也效率高的原因
1. 纯内存操作
2. 基于非阻塞的IO多路复用
3. C执行较快
4. 单线程避免了上下文切换（占比多少？？）

#### 数据类型、存储结构（TBC）、实际应用

1. string
	* 配置
2. hash
	* 字段差异较大的结构化数据（TBC）
3. list
	* 分页（为什么不内存分页）
	* 消息队列
4. set
	* 全局集合操作，如自动去重、求交并差集（为什么不内存操作）
5. sorted set
	* 延迟队列
6. pub/sub
	* 直播推送消息

#### 过期策略

定期删除 + 惰性删除

1. 定期删除

	默认间隔100ms随机抽取检查设置了过期时间的key，过期则删除
	
2. 惰性删除

	取key时检查是否过期，过期则删除

#### 内存淘汰

如果没过期，且内存不足以容纳新写入数据时，执行内存淘汰机制

1. noeviction

	不淘汰，内存不足时写报错
	
2. allkeys-lru

	键空间中移除最近最少使用的key
	
3. allkeys-random

	键空间中移除随机的key
	
4. volatile-lru

	设置了过期时间的键空间中，移除最近最少使用的key
	
5. volatile-random

	设置了过期时间的键空间中，移除随机的key
	
6. volatile-ttl

	设置了过期时间的键空间中，移除最早过期的key
	
#### 手写代码
	
LinkedHashMap

``` java
class LRUCache<K, V> extends LinkedHashMap<K, V> {
    private final int CACHE_SIZE;

    /**
     * 传递进来最多能缓存多少数据
     *
     * @param cacheSize 缓存大小
     */
    public LRUCache(int cacheSize) {
        // true 表示让 linkedHashMap 按照访问顺序来进行排序，最近访问的放在头部，最老访问的放在尾部。
        super((int) Math.ceil(cacheSize / 0.75) + 1, 0.75f, true);
        CACHE_SIZE = cacheSize;
    }

    @Override
    protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
        // 当 map中的数据量大于指定的缓存个数的时候，就自动删除最老的数据。
        return size() > CACHE_SIZE;
    }
}
```

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


