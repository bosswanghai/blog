# Nsq
### nsq简介
NSQ 是实时的分布式消息处理平台，其设计的目的是用来大规模地处理每天数以十亿计级别的消息。

NSQ 具有`分布式`和`去中心`化拓扑结构，该结构具有无单点故障、故障容错、高可用性以及能够保证消息的可靠传递的特征。


### nsq原理
NSQ 由 3 个守护进程组成：

nsqd 是接收、队列和传送消息到客户端的守护进程。

nsqlookupd 是管理的拓扑信息，并提供了最终一致发现服务的守护进程。

nsqadmin 是一个 Web UI 来实时监控集群（和执行各种管理任务）。

在 NSQ 数据流建模为一个消息流和消费者的树。一个话题（topic）是一个独特的数据流。一个 通道（channel） 是消费者订阅了某个 话题 的逻辑分组。

话题（topic）和通道（channel），NSQ 的核心基础，最能说明如何把 Go 语言的特点无缝地转化为系统设计。

Go 语言中的通道（channel）（为消除歧义以下简称为“go-chan”）是实现队列一种自然的方式，因此一个 NSQ 话题（topic）/通道（channel），其核心，只是一个缓冲的 go-chan Message指针。缓冲区的大小等于 --mem-queue-size 的配置参数。



### nsq搭建

[nsq 安装](http://wiki.jikexueyuan.com/project/nsq-guide/installing.html)

### nsq使用
- 启动 nsqlookupd

- 启动 nsqd --lookupd-tcp-address=127.0.0.1:4160

- nsqadmin --lookupd-http-address=127.0.0.1:4161

- nsq_to_file --topic=test --output-dir=/tmp --lookupd-http-address=127.0.0.1:4161 可以指定topic和channel

- curl -d 'hello world 1' 'http://127.0.0.1:4151/put?topic=test'

- 在浏览器中打开 http://127.0.0.1:4171/ 就能查看 nsqadmin 的 UI 界面和队列统计数据



