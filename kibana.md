# KIBANA

### 查询

kibana支持两种查询

- es本身搜索语法

QueryDsl: json串搜索格式


- lucene搜索语法

域名+”:”+搜索的项名

##### es查询语法
略

#### lucene搜索语法

```
AND查询
title:”The Right Way” AND text:go

OR查询
title:”The Right Way” OR text:go

范围查询
mod_date:[20020101 TO 20030101]

匹配查询
? 匹配一个
* 匹配多个

不能以*或者?开头，放在中间和结尾都可以

模糊搜索
最后加上符号”~”
roam~  将找到形如foam和roams的单词
注意：使用模糊查询将自动得到增量因子（boost factor）为0.2的搜索结果

临近搜索
Lucene还支持查找相隔一定距离的单词。邻近搜索是在短语最后加上符号”~”。例如在文档中搜索相隔10个单词的”apache”和”jakarta”，这样写：
“jakarta apache”~10

NOT操作符排除那些含有NOT符号后面项的文档。这和集合的差运算相同。符号！可以代替符号NOT。

+
“+”操作符或者称为存在操作符，要求符号”+”后的项必须在文档相应的域中存在。
搜索必须含有”jakarta”，可能含有”lucene”的文档，使用查询：

+jakarta apache


-
“-”操作符或者禁止操作符排除含有”-”后面的相似项的文档。
搜索含有”jakarta apache”，但不是”jakarta lucene”，使用查询：
“jakarta apache” -”jakarta lucene”

分组
(jakarta OR apache) AND website
这个要求属于同一个搜索项，比如说key: jakarta website
不能是key:jakarta key:website，如果是后面这种形式，必须使用key:jakarta AND key:website

转义特殊字符（Escaping Special Characters）
Lucene支持转义特殊字符，因为特殊字符是查询语法用到的。现在，特殊字符包括
+ – && || ! ( ) { } [ ] ^ ” ~ * ? : \
转义特殊字符只需在字符前加上符号\,例如搜索(1+1):2，使用查询
\(1\+1\)\:2

```



