[toc]

# 杂项

# 高并发

## 消息队列

### 应用

1. 场景（架构、代码）

	* 解耦（推送媒体发布状态；
	* 异步（多机房备份存储；转码；
	* 削峰（发博结果；

2. 问题

	* 增加依赖，降低可用性
	* 增加组件，提高复杂性
	* 一致性

3. 对比
	
|   | 单机吞吐量 | topic数量对吞吐量的影响 | 时效性 | 可用性 | 可靠性 | 功能支持 | 社区活跃度 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Kafka | 10w | 几百topics时，吞吐量大幅度降低 | ms以内 | 非常高（分布式，多副本，少数及其宕机不丢失数据） | 优化参数后能不丢失 | 简单的MQ功能，主要用于大数据领域的实时计算及日志采集 | 极高 |
| ActiveMQ | 1w |  | ms | 高（主从） | 较低概率丢失 | 功能极其完备 | 低 |
| RabbitMQ | 1w |   | us | 高（主从） | 基本不丢 | 并发能力强，性能极好，延时很低（基于erlang） | 较高 |
| RocketMQ | 10w | 几千topics时，吞吐量小幅度降低 | ms | 非常高（分布式） | 优化参数后能不丢失 | 功能完善，扩展性好 | 一般 |
| MCQ |  |  |  |  |  |  |
| Trigger |  |  |  |  |  |  |

### 原理及实现

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


