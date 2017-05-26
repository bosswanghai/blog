# Kafka

### 消息队列
含义：消息队列技术是分布式应用间交换信息的一种技术

`通讯方式`

点对点

多点广播

发布/订阅

集群

### kafka原理

作为一层中间中间存储介质，隔离生产者和消费者。

[kafka 存储原理](http://tech.meituan.com/kafka-fs-design-theory.html)


`名词解释`

Broker：Kafka 集群包含一个或多个服务器，这种服务器被称为 broker

Topic：每条发布到 Kafka 集群的消息都有一个类别，这个类别被称为 Topic。（物理上不同 Topic 的消息分开存储，逻辑上一个 Topic 的消息虽然保存于一个或多个 broker 上，但用户只需指定消息的 Topic 即可生产或消费数据而不必关心数据存于何处）。

Partition：Partition 是物理上的概念，每个 Topic 包含一个或多个 Partition。

Producer：负责发布消息到 Kafka broker。

Consumer：消息消费者，向 Kafka broker 读取消息的客户端。

Consumer Group：每个 Consumer 属于一个特定的 Consumer Group（可为每个 Consumer 指定 group name，若不指定 group name 则属于默认的 group）。

`交互流程`

1. kafka可存储的信息格式
信息是一个字节数组，程序员可以在这些字节数组中存储任何对象，支持的数据格式包括 String、JSON、Avro

2. 信息模型
消息模型可以分为两种， 队列和发布-订阅式。 队列的处理方式是 一组消费者从服务器读取消息，一条消息只有其中的一个消费者来处理。在发布-订阅模型中，消息被广播给所有的消费者，接收到消息的消费者都可以处理此消息。Kafka为这两种模型提供了单一的消费者抽象模型： 消费者组

同一个组内的消费者，是按照队列的方式来接收。不同组之间，是按照发布订阅方式来接收。

3. 可靠性保证
  保序
  topic配置了复制因子( replication facto)为N， 那么可以允许N-1服务器当掉而不丢失任何已经增加的消息

### 配置方法

[配置参数详解](http://colobu.com/2015/03/11/kafka-configuration-parameters/)

* 单机版
broker配置文件
config/server.properties

启动zookeeper
bin/zookeeper-server-start.sh config/zookeeper.properties

启动kafka
bin/kafka-server-start.sh config/server.properties



* 集群版本

cp config/server.properties config/server-1.properties config/server-2.properties

分别启动这两个kafka

bin/kafka-server-start.sh config/server-1.properties &


```
config/server-1.properties:
    broker.id=1
    port=9093
    log.dir=/tmp/kafka-logs-1

config/server-2.properties:
    broker.id=2
    port=9094
    log.dir=/tmp/kafka-logs-2
```


### 使用方法

[kafka 快速入门](http://colobu.com/2014/08/06/kafka-quickstart/)

- list topic

bin/kafka-topics.sh --list --zookeeper 10.18.210.207:2181,10.18.210.208:2181,10.18.210.209:2181

- describe topic

./bin/kafka-topics.sh --zookeeper 192.168.60.13:2181 --describe --topic uplog_nginx

```
第一行显示该topic概览
Topic:uplog_nginx    PartitionCount:128    ReplicationFactor:1    Configs:

后面的显示信息：
Topic: uplog_nginx    Partition: 0    Leader: 4    Replicas: 4    Isr: 4

leader 是在给出的所有partitons中负责读写的节点，每个节点都有可能成为leader
replicas 显示给定partiton所有副本所存储节点的节点列表，不管该节点是否是leader或者是否存活。
isr 副本都已同步的的节点集合，这个集合中的所有节点都是存活状态，并且跟leader同步

```

- create topic

bin/kafka-topics.sh --create --zookeeper 10.18.210.207:2181,10.18.210.208:2181,10.18.210.209:2181 --replication-factor 1 --partitions 1 --topic basp_basp

bin/kafka-topics.sh --describe --zookeeper 10.18.210.207:2181,10.18.210.208:2181,10.18.210.209:2181 --topic  ws_vod


- producer

bin/kafka-console-producer.sh --broker-list 10.18.210.207:9092,10.18.210.208:9093,10.18.210.209:9094 --topic test_test


- consumer

bin/kafka-console-consumer.sh  --zookeeper  10.18.210.207:2181,10.18.210.208:2181,10.18.210.209:2181  --topic test_topic [--from-beginning]

- delete topic

stop kafka   集群要每天机器都要关闭

./bin/kafka-server-stop.sh ./config/server-1.properties

删除zookeeper 中的topic记录

-# /usr/local/share/zookeeper/bin/zkCli.sh -server 10.18.210.207:2181,10.18.210.208:2181,10.18.210.209:2181
rm -rf /brokers/topics/*  或者 deleteall /brokers/topics/sometopic

删除kafka 的日志项

cd /tmp/kafa-logs

rm -rf topics(topic对应的文件夹) 注意是集群中多台机器

### 集群监控

[kafka manager](https://github.com/yahoo/kafka-manager)

### 技术选型

[IBM KAFKA](https://www.ibm.com/developerworks/cn/opensource/os-cn-kafka/)

`kafka与flume区别`

Kafka 是一个通用型系统。你可以有许多的生产者和消费者分享多个主题。相反地，Flume 被设计成特定用途的工作，特定地向 HDFS 和 HBase 发送出去。

Flume 拥有许多配置的来源 (sources) 和存储池 (sinks)。然后，Kafka 拥有的是非常小的生产者和消费者环境体系，Kafka 社区并不是非常支持这样。

Flume 可以在拦截器里面实时处理数据。这个特性对于过滤数据非常有用。Kafka 需要一个外部系统帮助处理数据

无论是 Kafka 或是 Flume，两个系统都可以保证不丢失数据。

Flume 和 Kafka 可以一起工作的。如果你需要把流式数据从 Kafka 转移到 Hadoop，可以使用 Flume 代理 (agent)，将 kafka 当作一个来源 (source)，这样可以从 Kafka 读取数据到 Hadoop。



