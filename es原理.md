# ES原理

### 原理

##### 概念

- index 逻辑命名空间，指向一个或者多个shards

- shards  index实际存储的分片

```
集群扩展时，会自动增加分片

shards分为两种: primary shards和replica shards。主分片和从分片

** 每一个文档属于一个主分片 **

从分片只是主分片的一个副本，它用于提供数据的冗余副本，在硬件故障时提供数据保护，
同时服务于搜索和检索这种*只读*请求。

索引中的主分片的数量在索引创建后就固定下来了，但是从分片的数量可以随时改变。

PUT /blogs
{
"settings" : {
"number_of_shards" : 3,
"number_of_replicas" : 1
}
}


```

- segments shards在磁盘实际存储为segments：以[倒排索引](https://zh.wikipedia.org/wiki/%E5%80%92%E6%8E%92%E7%B4%A2%E5%BC%95)的方式组织。

一个segments可以包含多个index的数据，它是磁盘缓冲区中的内容每秒刷到磁盘上形成的，后续还会对这些文件做一下合并。



##### 数据从外部接收到写入磁盘过程

[segment、buffer和translog对实时性的影响](http://kibana.logstash.es/content/elasticsearch/principle/realtime.html)
es中有一个commit文件管理物理系盘上的segments文件。新接收的数据首先到达`内存`，然后由`内存`到达`磁盘缓冲区`，再由磁盘缓冲区写入`磁盘segments`，最后再更新commit文件。 

*由于写到磁盘比较慢，这里使用了`磁盘缓冲`到达准实时调试的目的，只要在磁盘缓冲区中，就可以检索磁盘缓冲区中的segment文件*

为了防止由磁盘缓冲区写到磁盘时候，由于一些异常引起数据丢失，es提供了translog机制来保证数据不丢失。

`tanslog`

```
保存了和内存buf一样的内容，当内存buf中的数据在最终落盘前，translog始终存在，则当数据出现丢失的时候，从translog中恢复数据。
当数据在commit最终更新完成后，translog中的内容被删除，即`flush`

对于 flush 操作，Elasticsearch 默认设置为：每 30 分钟主动进行一次 flush，或者当 translog 文件大小大于 512MB (老版本是 200MB)时，主动进行一次 flush。这两个行为，可以分别通过 index.translog.flush_threshold_period 和 index.translog.flush_threshold_size 参数修改。
如果对这两种控制方式都不满意，Elasticsearch 还可以通过 index.translog.flush_threshold_ops 参数，控制每收到多少条数据后 flush 一次。
```

`translog可靠性保证`

```
默认情况下，Elasticsearch 每 5 秒，或每次请求操作结束前，会强制刷新 translog 日志到磁盘上。
后者是 Elasticsearch 2.0 新加入的特性。为了保证不丢数据，每次 index、bulk、delete、update 完成的时候，一定触发刷新 translog 到磁盘上，才给请求返回 200 OK。这个改变在提高数据安全性的同时当然也降低了一点性能。

如果你不在意这点可能性，还是希望性能优先，可以在 index template 里设置如下参数：
{
    "index.translog.durability": "async"
}
```


文件真正同步到磁盘上有个参数refresh_interval间隔可以设置，默认是1s，也可以设置多秒后再刷新到一次磁盘。

```
 curl -XPOST http://127.0.0.1:9200/logstash-2015.06.21/_settings -d'
{ "refresh_interval": "10s" }

如果是导入历史数据的场合，那甚至可以先完全关闭掉：
 # curl -XPUT http://127.0.0.1:9200/logstash-2015.05.01 -d'
{
  "settings" : {
    "refresh_interval": "-1"
  }
}'
在导入完成以后，修改回来或者手动调用一次即可：
 # curl -XPOST http://127.0.0.1:9200/logstash-2015.05.01/_refresh

```


##### segment merge
es存入数据的本质就是"开新文件"segments

- 带来的问题

```
因为默认每 1 秒，都会有一个新文件产生，每个文件都需要有文件句柄，内存，CPU 使用等各种资源。一天有 86400 秒，设想一下，每次请求要扫描一遍 86400 个文件，这个响应性能绝对好不了
```

- 解决的方法

```
ES 会不断在后台运行任务，主动将这些零散的 segment 做数据归并，尽量让索引内只保有少量的，每个都比较大的，segment 文件。这个过程是有独立的线程来进行的，并不影响新 segment 的产生。归并过程中，尚未完成的较大的 segment 是被排除在检索可见范围之外的
```

- 归并程序带来的问题

```
segment 归并的过程，需要先读取 segment，归并计算，再写一遍 segment，最后还要保证刷到磁盘，非常消耗磁盘IO和CPU

```

- 解决方法

```
默认情况下，归并线程的限速配置 indices.store.throttle.max_bytes_per_sec 是 20MB

磁盘转速较高，甚至使用 SSD 盘的服务器来说，这个限速是明显过低的，可以调到100m

 curl -XPUT http://127.0.0.1:9200/_cluster/settings -d'
{
    "persistent" : {
        "indices.store.throttle.max_bytes_per_sec" : "100mb"
    }
}'

```

- 归并策略


```
index.merge.policy.floor_segment 默认 2MB，小于这个大小的 segment，优先被归并。
index.merge.policy.max_merge_at_once 默认一次最多归并 10 个 segment
index.merge.policy.max_merge_at_once_explicit 默认 optimize 时一次最多归并 30 个 segment。
index.merge.policy.max_merged_segment 默认 5 GB，大于这个大小的 segment，不用参与归并。optimize 除外。
```

也加大 flush 间隔，尽量让每次新生成的 segment 本身大小就比较大。

- optimize 接口

```
默认的最大 segment 大小是 5GB，不建议增加index.merge.policy.max_merged_segment配置，这样的结果会导致过多的index落到过大的segment文件里，解析花费时间太多。为了减小segment文件，还可以通过optimize选型来手动压缩segments。 curl -XPOST http://127.0.0.1:9200/logstash-2015-06.10/_optimize?max_num_segments=1

如果一个index过大，则它必然存在于很多segments文件中，那么检索该index则会造成大量的资源浪费。
解决办法，合理组织es的index方式，比如说按天索引。


```

##### 写请求如何确定数据的节点和分片

```routing和replica的读写过程```

- 路由计算

作为一个没有额外依赖的简单的分布式方案，ES 在这个问题上同样选择了一个非常简洁的处理方式，对任一条数据计算其对应分片的方式如下：
shard = hash(routing) % number_of_primary_shards

每个数据都有一个 `routing` 参数，默认情况下，`就使用其 _id` 值。将其 _id 值计算哈希后，对索引的主分片数取余，就是数据实际应该存储到的分片 ID。

`由于取余这个计算，完全依赖于分母，所以导致 ES 索引有一个限制，索引的主分片数，不可以随意修改。因为一旦主分片数不一样，所以数据的存储位置计算结果都会发生改变，索引数据就完全不可读了。`

- 副本一致性

`半同步机制`： 当master收到写入请求，根据hash计算出属于的shard，找到该shard所在的主分片，主分片写入完成后，同步给所有从分片，当一个从分片完成后，主分片所在的节点向master汇报写入完成。

异步 replication 通过在客户端发送请求的 URL 中加上 ?replication=async/one，该方式已经废弃。
同步 all


`timeout` 如果集群出现异常，有些分片当前不可用，ES 默认会等待 1 分钟看分片能否恢复

##### shard 的 allocate 控制

某个 shard 分配在哪个节点上，一般来说，是由 ES 自动决定的。以下几种情况会触发分配动作

```
新索引生成
索引的删除
新增副本分片
节点增减引发的数据均衡
```

** 节点增删会引发数据平衡 **


`es的分片控制逻辑`

```
cluster.routing.allocation.enable   该参数用来控制允许分配哪种分片
默认是 all，包括primaries 和 new_primaries。none 则彻底拒绝分片

cluster.routing.allocation.allow_rebalance 该参数用来控制什么时候允许数据均衡
默认是 indices_all_active，即要求所有分片都正常启动成功以后，才可以进行数据均衡操作，否则的话，在集群重启阶段，会浪费太多流量了。

cluster.routing.allocation.cluster_concurrent_rebalance 该参数用来控制集群内同时运行的数据均衡任务个数。

cluster.routing.allocation.node_initial_primaries_recoveries 该参数用来控制节点重启时，允许同时恢复几个主分片

cluster.routing.allocation.node_concurrent_recoveries 该参数用来控制节点除了主分片重启恢复以外其他情况下，允许同时运行的数据恢复任务。

indices.recovery.concurrent_streams 该参数用来控制节点从网络复制恢复副本分片时的数据流个数。

indices.recovery.max_bytes_per_sec 该参数用来控制节点恢复时的速率。
```

- reroute 接口

es除了本身shard的自动选择外，也可以手动完成对分片的分配选择的控制，操作的方法是通过reroute接口

reroute 接口支持三种指令：allocate，move 和 cancel。常用的一般是 allocate 和 move

```
allocate 指令
因为负载过高等原因，有时候个别分片可能长期处于 UNASSIGNED 状态，我们就可以手动分配分片到指定节点上。默认情况下只允许手动分配副本分片，所以如果是主分片故障，需要单独加一个 allow_primary 选项

 # curl -XPOST 127.0.0.1:9200/_cluster/reroute -d '{
  "commands" : [ {
        "allocate" :
            {
              "index" : "logstash-2015.05.27", "shard" : 61, "node" : "10.19.0.77", "allow_primary" : true
            }
        }
  ]
}'

注意，如果是历史数据的话，请提前确认一下哪个节点上保留有这个分片的实际目录，且目录大小最大。然后手动分配到这个节点上。以此减少数据丢失。

```

```
move 指令
因为负载过高，磁盘利用率过高，服务器下线，更换磁盘等原因，可以会需要从节点上移走部分分片
curl -XPOST 127.0.0.1:9200/_cluster/reroute -d '{
  "commands" : [ {
        "move" :
            {
              "index" : "logstash-2015.05.22", "shard" : 0, "from_node" : "10.19.0.81", "to_node" : "10.19.0.104"
            }
        }
  ]
}'

```

- 节点下线

节点下线通过命令手动去m转义每一个分片太过麻烦，这时候可以通过如下配置实现。

```
curl -XPUT 127.0.0.1:9200/_cluster/settings -d '{
  "transient" :{
      "cluster.routing.allocation.exclude._ip" : "10.0.0.1"
   }
}'

```

Elasticsearch 集群就会自动把这个 IP 上的所有分片，都自动转移到其他节点上。等到转移完成，这个空节点就可以毫无影响的下线了。

`和 _ip 类似的参数还有 _host, _name 等。此外，这类参数不单是 cluster 级别，也可以是 index 级别。`

- 冷热数据的读写分离

```
实施方案

N 台机器做热数据的存储, 上面只放当天的数据。这 N 台热数据节点上面的 elasticsearc.yml 中配置 node.tag: hot
之前的数据放在另外的 M 台机器上。这 M 台冷数据节点中配置 node.tag: stale
模板中控制对新建索引添加 hot 标签：
{
 "order" : 0,
 "template" : "*",
 "settings" : {
   "index.routing.allocation.require.tag" : "hot"
 }
}
每天计划任务更新索引的配置, 将 tag 更改为 stale, 索引会自动迁移到 M 台冷数据节点
 # curl -XPUT http://127.0.0.1:9200/indexname/_settings -d'
{
"index": {
   "routing": {
      "allocation": {
         "require": {
            "tag": "stale"
         }
      }
  }
}
}'
这样，写操作集中在 N 台热数据节点上，大范围的读操作集中在 M 台冷数据节点上。避免了堵塞影响

```

##### 集群自动发现

ES 是一个 P2P 类型(使用 gossip 协议)的分布式系统

* 同一个集群配置

在无阻碍的网络下，所有配置了相同 cluster.name 的节点都自动归属到一个集群中。

* multicast 方式

只配置 cluster.name 的集群，其实就是采用了默认的自动发现协议，即组播(multicast)方式。
使用组播地址 224.2.2.4 ，以 54328 端口建立组播组发送 clustername 信息


Elasticsearch 2.0 开始，为安全考虑，默认不分发 multicast 功能。依然希望使用 multicast 自动发现的用户，需要单独安装:

bin/plugin install discovery-multicast

* unicast 方式

配置里提供几台节点的地址，ES 将其视作 gossip router 角色，借以完成集群的发现。由于这只是 ES 内一个很小的功能，所以 gossip router 角色并不需要单独配置，每个 ES 节点都可以担任。所以，采用单播方式的集群，各节点都配置相同的几个节点列表作为 router 即可。

```
discovery.zen.minimum_master_nodes: 3
discovery.zen.ping.timeout: 100s
discovery.zen.fd.ping_timeout: 100s
discovery.zen.ping.multicast.enabled: false
discovery.zen.ping.unicast.hosts: ["10.19.0.97","10.19.0.98","10.19.0.99","10.19.0.100"]
```





### 配置数据查看

配置文件中，有对配置数据的描述

/usr/yupoo/app/elasticsearch/config/elasticsearch.yml

配置文件中的数据以json串的形式导入es中，通过kibana上的marvel插件，可以进行查看



### 集群

- 角色划分


client

master

data

[节点详细介绍](http://yemengying.com/2016/03/21/elasticsearch-settings2/)

- 角色之间的差异

node.master: true/false

node.name: "1.7.5-192.168.60.13"

network.host: 192.168.60.13

node.data: true/false

discovery.zen.ping.unicast.hosts: ["192.168.60.14", "192.168.60.15", "192.168.60.16", "192.168.60.17"   ## 配置所有的master，如果已经是master，则排除自己

- 节点扩容

只要第二个节点与第一个节点的 cluster.name 相同，它就能自动发现并加入到第一个节点的集群中。如





### 集群检查

`master节点执行命令`

##### 集群普通health

```

GET /_cluster/health

[root@ES-ZJ-LNA-013 config]# curl 192.168.60.13:9200/_cluster/health\?pretty
{
  "cluster_name" : "elasticsearch-uplog",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 25,
  "number_of_data_nodes" : 18,
  "active_primary_shards" : 8896,
  "active_shards" : 8899,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0
}

```

`字段解释`

`status` 最重要的字段，健康状态

```
green 所有主分片和从分片都可用
yellow 所有主分片可用，但存在不可用的从分片
red 存在不可用的主要分片

```

`其他字段解释`

```
number_of_nodes 集群内的总节点数。
number_of_data_nodes 集群内的总数据节点数。
active_primary_shards 集群内所有索引的主分片总数。
active_shards 集群内所有索引的分片总数。
relocating_shards 正在迁移中的分片数。
initializing_shards 正在初始化的分片数。
unassigned_shards 未分配到具体节点上的分片数。

```

##### level health

接口请求的时候，可以附加一个 level 参数，指定输出信息以 indices 还是 shards 级别显示。当然，一般来说，indices 级别就够了。

```
 # curl -XGET http://127.0.0.1:9200/_cluster/health?level=indices
{
   "cluster_name": "es1003",
   "status": "red",
   "timed_out": false,
   "number_of_nodes": 38,
   "number_of_data_nodes": 27,
   "active_primary_shards": 1332,
   "active_shards": 2380,
   "relocating_shards": 0,
   "initializing_shards": 0,
   "unassigned_shards": 1
   "indices": {
      "logstash-2015.05.31": {
         "status": "green",
         "number_of_shards": 81,
         "number_of_replicas": 0,
         "active_primary_shards": 81,
         "active_shards": 81,
         "relocating_shards": 0,
         "initializing_shards": 0,
         "unassigned_shards": 0
      },
      "logstash-2015.05.30": {
         "status": "red",
         "number_of_shards": 81,
         "number_of_replicas": 0,
         "active_primary_shards": 80,
         "active_shards": 80,
         "relocating_shards": 0,
         "initializing_shards": 0,
         "unassigned_shards": 1
      },
      ...
   }
}

```

`具体确定 unassign shard 的情况，更推荐使用 kopf 工具在页面查看。`

##### 节点状态监控接口

curl -XGET 127.0.0.1:9200/_nodes/stats

```
{
   "cluster_name": "elasticsearch_zach",
   "nodes": {
      "UNr6ZMf5Qk-YCPA_L18BOQ": {
         "timestamp": 1408474151742,
         "name": "Zach",
         "transport_address": "inet[zacharys-air/192.168.1.131:9300]",
         "host": "zacharys-air",
         "ip": [
            "inet[zacharys-air/192.168.1.131:9300]",
            "NONE"
         ],
...
```

##### 索引状态监控接口

