# Mongodb

## NoSql

NoSQL(NoSQL = Not Only SQL )，意即"不仅仅是SQL"。

通过应用实践证明，关系模型是非常适合于客户服务器编程

NoSQL用于超大规模数据的存储。（例如谷歌或Facebook每天为他们的用户收集万亿比特的数据）。这些类型的数据存储不需要固定的模式，无需多余操作就可以横向扩展。

nosql分类

类型 | 代表 | 特点
-----|------|----
列存储| HBase |按列存储，基于列的操作性能高
文档存储| MongoDB| 文档存储一般用类似json的格式存储，存储的内容是文档型的。
k-v存储| MemcacheDB redis | 可以通过key快速查询到其value。一般来说，存储不管value的格式，照单全收
图存储|Neo4J|图形关系的最佳存储
对象存储|db4o|通过类似面向对象语言的语法操作数据库，通过对象的方式存取数据
xml存储| Berkeley DB XML|高效的存储XML数据，并支持XML的内部查询语法，比如XQuery,Xpath

## Mongodb

### 安装

mac: homebrew

### 启动

添加PATH后，nohup mongod --dbpath ~/data/db &

客户端链接 mango

### 命令

#### DB命令

MongoDB的默认数据库为"db"，该数据库存储在data目录中。

"show dbs" 命令可以显示所有数据的列表，空集合的数据不会被显示。

"db" 命令可以显示当前数据库对象或集合

"use dbname"命令，创建或者切换到一个指定的数据库。

"db.dropDatabase()" 删除数据库，切换到指定的数据库后，可以删除数据库



数据库名规则：
```
不能是空字符串（"")。
不得含有' '（空格)、.、$、/、\和\0 (空宇符)。
应全部小写。
最多64字节。
```

保留数据库名：

admin： 从权限的角度来看，这是"root"数据库。

local: 这个数据永远不会被复制，可以用来存储限于本地单台服务器的任意集合

config: 当Mongo用于分片设置时，config数据库在内部使用，用于保存分片的相关信息

#### 集合命令

集合相当于表

集合命名规则
```
集合名不能是空字符串""。
集合名不能含有\0字符（空字符)，这个字符表示集合名的结尾。
集合名不能以"system."开头，这是为系统集合保留的前缀。
用户创建的集合名字不能含有保留字符。有些驱动程序的确支持在集合名里面包含，这是因为某些系统生成的集合中包含该字符。除非你要访问这种系统创建的集合，否则千万不要在名字里出现$。
```

集合分类：

- capped collections： 固定大小的集合

有很高的性能以及队列过期的特性(过期按照插入的顺序)

它非常适合类似记录日志的功能 和标准的collection不同，你必须要显式的创建一个capped collection， 指定一个collection的大小，单位是字节

db.createCollection("mycoll", {capped:true, size:100000})

特点:
```
在capped collection中，你能添加新的对象。
能进行更新，然而，对象不会增加存储空间。如果增加，更新就会失败 。
数据库不允许进行删除。使用drop()方法删除collection所有的行。
注意: 删除之后，你必须显式的重新创建这个collection。
在32bit机器中，capped collection最大存储为1e9( 1X109)个字节。
```
"db.col_name.insert({"name":"wanghai"})" 插入集合

"db.collection.drop()" 删除集合

"db.col_name.find()[.pretty()]" 查看已经插入的数据

查询条件

```
等于    {<key>:<value>}    db.col.find({"by":"菜鸟教程"}).pretty()
小于    {<key>:{$lt:<value>}}    db.col.find({"likes":{$lt:50}}).pretty()
小于或等于    {<key>:{$lte:<value>}}    db.col.find({"likes":{$lte:50}}).pretty()
大于    {<key>:{$gt:<value>}}    db.col.find({"likes":{$gt:50}}).pretty()
大于或等于    {<key>:{$gte:<value>}}    db.col.find({"likes":{$gte:50}}).pretty()
不等于    {<key>:{$ne:<value>}}    db.col.find({"likes":{$ne:50}}).pretty()
```

AND

db.col_name.find({key1:val1, key2:val2})

OR

db.col_name.find({$or:[{key1:val1}, {key2:val2}]})

$type

根据数据类型返回查询结果

db.abc.find({"name":"wanghai","age":{$type: 1}})

limit方法：限制返回查询结果的记录数量

db.col_name.find().limit(number)

skip方法：跳过返回结果的前number2个数量

db.col_name.find().skip(number2)

db.col_name.find().limit(number1).skip(number2)

sort方法：返回结果排序

KEY:1 表示升序， -1表示降序

db.COLLECTION_NAME.find().sort({KEY:1})

索引：ensureIndex() 方法

语法中 Key 值为你要创建的索引字段，1为指定按升序创建索引，如果你想按降序来创建索引指定为-1即可。

db.COLLECTION_NAME.ensureIndex({KEY:1})

ensureIndex参数

```
background    Boolean    建索引过程会阻塞其它数据库操作，background可指定以后台方式创建索引，即增加 "background" 可选参数。 "background" 默认值为false。
unique    Boolean    建立的索引是否唯一。指定为true创建唯一索引。默认值为false.
name    string    索引的名称。如果未指定，MongoDB的通过连接索引的字段名和排序顺序生成一个索引名称。
dropDups    Boolean    在建立唯一索引时是否删除重复记录,指定 true 创建唯一索引。默认值为 false.
sparse    Boolean    对文档中不存在的字段数据不启用索引；这个参数需要特别注意，如果设置为true的话，在索引字段中不会查询出不包含对应字段的文档.。默认值为 false.
expireAfterSeconds    integer    指定一个以秒为单位的数值，完成 TTL设定，设定集合的生存时间。
v    index version    索引的版本号。默认的索引版本取决于mongod创建索引时运行的版本。
weights    document    索引权重值，数值在 1 到 99,999 之间，表示该索引相对于其他索引字段的得分权重。
default_language    string    对于文本索引，该参数决定了停用词及词干和词器的规则的列表。 默认为英语
language_override    string    对于文本索引，该参数指定了包含在文档中的字段名，语言覆盖默认的language，默认值为 language.

```

eg:

db.values.ensureIndex({open: 1, close: 1}, {background: true})

aggregate() 方法：主要用于处理数据(诸如统计平均值,求和等)，并返回计算后的数据结果

db.col_name.aggregate(AGGREGATE_OPERATION)






"db.col_name.findOne()"

"db.col_name.update()" 更新集合数据

update()语法格式
```
db.collection.update(
   <query>,
   <update>,
   {
     upsert: <boolean>,
     multi: <boolean>,
     writeConcern: <document>
   }
)
```

参数说明：
```
query : update的查询条件，类似sql update查询内where后面的。
update : update的对象和一些更新的操作符（如$,$inc...）等，也可以理解为sql update查询内set后面的
upsert : 可选，这个参数的意思是，如果不存在update的记录，是否插入objNew,true为插入，默认是false，不插入。
multi : 可选，mongodb 默认是false,只更新找到的第一条记录，如果这个参数为true,就把按条件查出来多条记录全部更新。
writeConcern :可选，抛出异常的级别。

db.abc.update({"name":"wanghai"},{$set:{"age":21}},{upsert: false, multi: true})
```

"db.col_name.remove()" 删除文档,2.6以后的版本：
```
db.collection.remove(
   <query>,
   {
     justOne: <boolean>,
     writeConcern: <document>
   }
)
```

参数说明：
```
query :（可选）删除的文档的条件。
justOne : （可选）如果设为 true 或 1，则只删除一个文档。
writeConcern :（可选）抛出异常的级别。
```




#### 文档命令

文档相当于行

"show collections"：查看所有文档名字

文档关联：

{
"name":"wanghai",
"age":1,
"ref":"col_addr_name",
$id: ,
$db: ,
}

#### 字段命令

字段相当于列

#### 其他

相当于表联合

主键 _id

帮助命令： db.help()
db.col_name.help()

