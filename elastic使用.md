# ELASTIC使用

Elasticsearch是一个基于Apache Lucene(TM)的高性能的、实时的、分布式的搜索引擎.

### 与elastic交互

```
1.java api | port 9300
节点客户端：node client
不存放数据，知道数据在集群的位置，转发请求到相应节点上。
传输客户端：transport client
自己不加入集群，转发请求到节点？？有node client 为何还要transport client

2.非Java方式：
以json为交互数据的restful api方式
```

### curl 执行 rest命令

```
Relational DB -> Databases -> Tables -> Rows -> Columns
Elasticsearch -> Indices 索引  -> Types 文档 -> Documents 行 -> Fields 列
在es中，索引相当于字典，基于此进行查询，排序，过滤等


创建索引
curl -XPUT "http://localhost:9200/music/"

创建文档
curl -XPUT "http://localhost:9200/music/songs/1" -d '
{ "name": "Deck the Halls", "year": 1885, "lyrics": "Fa la la la la" }'

查看文档
curl -XGET "http://localhost:9200/music/songs/1"
{"_index":"music","_type":"songs","_id":"1","_version":1,"found":true,"_source":
{ "name": "Deck the Halls", "year": 1885, "lyrics": "Fa la la la la" }}

curl -XGET "http://localhost:9200/music/songs/1/_source"
只查看实际的内容


更新文档

全量更新
curl -XPUT "http://localhost:9200/music/lyrics/1" -d '{ "name": 
"Deck the Halls", "year": 1886, "lyrics": "Fa la la la la" }'

局部更新
# curl -XPOST 'http://127.0.0.1:9200/logstash-2015.06.21/testlog/AU4ew3h2nBE6n0qcyVJK/_update' -d '{
    "doc" : {
        "user" : "someone"
    }
}'




删除文档
curl -XDELETE "http://localhost:9200/music/lyrics/1"

也支持通配符删除
curl -XDELETE http://127.0.0.1:9200/logstash-2015.06.0*

从文件中插入文档
curl -XPUT "http://localhost:9200/music/lyrics/2" -d @caseyjones.json


```

##### 查询

`?q=`后面的部分为query语法

已经存储的数据结构如下

```

{"took":240,"timed_out":false,"_shards":{"total":27,"successful":27,"failed":0},"hits":{"total":1,"max_score":0.11506981,"hits":[{"_index":"logstash-2015.06.21","_type":"testlog","_id":"AU4ew3h2nBE6n0qcyVJK","_score":0.11506981,"_source":{
    "date" : "1434966686000",
    "user" : "chenlin7",
    "mesg" : "first message into Elasticsearch"
}}]}}

```


```
全文检索: q=first

单字段的全文检索： q=msg:first

单字段精确索引： 数据字段加上双引号 q=msg:"first"

多个索引条件组合：可以使用 NOT, AND 和 OR 来组合检索，注意必须是大写

字段是否存在：_exists_:user 表示要求 user 字段存在，_missing_:user 表示要求 user 字段不存在；

通配符：用 ? 表示单字母，* 表示任意个字母。比如 fir?t mess*；

正则：需要比通配符更复杂一点的表达式，可以使用正则。比如 mesg:/mes{2}ages?/。注意 ES 中正则性能很差，而且支持的功能也不是特别强大，尽量不要使用。

近似搜索：用 ~ 表示搜索单词可能有一两个字母写的不对，请 ES 按照相似度返回结果。比如 frist~；


```

```

使用比较符
curl -XGET "http://localhost:9200/music/lyrics/_search?q=year:1900


限制字段
curl -XGET "http://localhost:9200/music/lyrics/_search?q=year:>1900&fields=year"

限制字段查询结果分析
a.单条记录
{
  "_index" :   "megacorp",
  "_type" :    "employee",
  "_id" :      "1",
  "_version" : 1,
  "found" :    true,
  "_source" :  {  -- 命中的情况
      "first_name" :  "John",
      "last_name" :   "Smith",
      "age" :         25,
      "about" :       "I love to go rock climbing",
      "interests":  [ "sports", "music" ]
  }
}

b.汇总结果
{
    "took": 6,    -- 查询花费毫秒
    "timed_out": false,  --是否超时
    "_shards": {  --集群化服务节点信息
        "total": 5,  -- 分片，可以在于一个或多个节点，一个节点可以存多份。一个索引可以指向一个或者多个节点
        "successful": 5,  -- ?
        "failed": 0  -- ?
    },
    "hits": {  -- 命中情况
        "total": 2,  -- 返回总记录数
        "max_score": 1.0,  -- 全文搜索
        "hits": [{
            "_index": "music",  -- 索引
            "_type": "lyrics",  -- 文档
            "_id": "1",  -- 文档中的索引
            "_score": 1.0,  -- 全文搜索命中长度，只有一个field，返回了1
            "fields": {
                "year": [1920]
            }
        }, {
            "_index": "music",
            "_type": "lyrics",
            "_id": "3",
            "_score": 1.0,
            "fields": {
                "year": [1909]
            }
        }]
    }
}
took --查询花费毫秒
time_out --是否超时
_shards集群化服务总节点数，成功数，失败数
hits对象：{

}

搜索
1.简单搜索
curl -XGET "http://localhost:9200/upyun/employ/_search"
curl -XGET "http://localhost:9200/upyun/employ/_search?age>20&fields=age"
curl -XGET "http://localhost:9200/upyun/employ/_search?q>age:20"  <==>
curl -XGET "http://localhost:9200/upyun/employ/_search?age>20"  <==>
curl -XGET "http://localhost:9200/upyun/employ/_search?q=age>20"

2.使用dsl语句
dsl(domain specific language特定领域语言)以json请求体的形式出现。

3.过滤器搜索
{
    "query" : {
        "filtered" : {
            "filter" : {
                "range" : {  -- 区间过滤器
                    "age" : { "gt" : 30 } <1>
                }
            },
            "query" : {
                "match" : {  -- 匹配
                    "last_name" : "smith" <2>
                }
            }
        }
    }
}
4.全文搜索
查询条件
{
    "query" : {
        "match" : {
            "about" : "rock climbing"
        }
    }
}

返回结果：
{
   ...
   "hits": {
      "total":      2,
      "max_score":  0.16273327,  -- 最大评分
      "hits": [
         {
            ...
            "_score":         0.16273327, <1>  -- 相关性评分
            "_source": {
               "first_name":  "John",
               "last_name":   "Smith",
               "age":         25,
               "about":       "I love to go rock climbing",
               "interests": [ "sports", "music" ]
            }
         },
         {
            ...
            "_score":         0.016878016, <2>
            "_source": {
es进行全文搜索并返回相关性最大的结果集

5.短语搜索
{
    "query" : {
        "match_phrase" : {  -- 不是相关性查询，进行精确匹配
            "about" : "rock climbing"
        }
    }
}

6.高亮搜索
{
    "query" : {
        "match_phrase" : {
            "about" : "rock climbing"
        }
    },
    "highlight": {
        "fields" : {
            "about" : {}
        }
    }
}

聚合（aggregations）
纯聚合
⇒ curl -XGET "http://localhost:9200/upyun/employ/_search" -d '
quote> {
quote> "aggs":{
quote> "all_ages":{
quote> "terms":{"field": "age"}
quote> }
quote> }
quote> }
quote> '
{"took":41,"timed_out":false,"_shards":{"total":5,"successful":5,"failed":0},"hits":{"total":3,"max_score":1.0,"hits":[{"_index":"upyun","_type":"employ","_id":"2","_score":1.0,"_source":
{
"first_name" : "Jane",
"last_name" : "Smith",
"age" : 32,
"about" : "I like to collect rock albums",
"interests": [ "music" ]
}
},{"_index":"upyun","_type":"employ","_id":"1","_score":1.0,"_source":
{
"first_name" : "John",
"last_name" : "Smith",
"age" : 25,
"about" : "I love to go rock climbing",
"interests": [ "sports", "music" ]
}
},{"_index":"upyun","_type":"employ","_id":"23","_score":1.0,"_source":
{
"first_name" : "Douglas",
"last_name" : "Fir",
"age" : 35,
"about": "I like to build cabinets",
"interests": [ "forestry" ]
}
}]},"aggregations":{"all_ages":{"doc_count_error_upper_bound":0,"sum_other_doc_count":0,"buckets":[{"key":25,"doc_count":1},{"key":32,"doc_count":1},{"key":35,"doc_count":1}]}}}%

聚合+匹配
{
  "query": {
    "match": {
      "last_name": "smith"
    }
  },
  "aggs": {
    "all_interests": {
      "terms": {
        "field": "interests"
      }
    }
  }
}
分级聚合
GET /megacorp/employee/_search
{
    "aggs" : {
        "all_interests" : {
            "terms" : { "field" : "interests" },
            "aggs" : {
                "avg_age" : {
                    "avg" : { "field" : "age" }  --avg平均
                }
            }
        }
    }
}
  "all_interests": {
     "buckets": [
        {
           "key": "music",
           "doc_count": 2,
           "avg_age": {
              "value": 28.5
           }
        },
        {
           "key": "forestry",
           "doc_count": 1,
           "avg_age": {
              "value": 35
           }
        },
        {
           "key": "sports",
           "doc_count": 1,
           "avg_age": {
              "value": 25
           }
        }
     ]
  }

```




