# toml

### 概要
TOML　的全称是　Tom's Obvious, Minimal Language

TOML 的目标是成为一个极简的配置文件格式。TOML 被设计成可以无歧义地被映射为哈希表，从而被多种语言解析。

TOML 是大小写敏感的。

### 使用

注释 `#`

##### 字符串

字符串和 JSON 的定义一致，只有一点除外：　TOML 要求使用　UTF-8 编码。

注释以引号包裹，里面的字符必须是　UTF-8 格式。引号、反斜杠和控制字符（U+0000 到 U+001F）需要转义。


```
"I'm a string. \"You can quote me\". Name\tJos\u00E9\nLocation\tSF."

```

`常用的转义序列`

```

\b     - backspace       (U+0008)
\t     - tab             (U+0009)
\n     - linefeed        (U+000A)
\f     - form feed       (U+000C)
\r     - carriage return (U+000D)
\"     - quote           (U+0022)
\/     - slash           (U+002F)
\\     - backslash       (U+005C)
\uXXXX - unicode         (U+XXXX)

```

##### 整数、浮点数

整数的尺寸最小为64位。

##### 布尔值

布尔值永远是小写。

true
false

##### 日期时间

使用　ISO 8601　完整格式。

```
1979-05-27T07:32:00Z
```

##### 数组

数组使用方括号包裹。空格会被忽略。元素使用逗号分隔。注意，`不允许混用数据类型`。

```
[ 1, 2, 3 ]
[ "red", "yellow", "green" ]
[ [ 1, 2 ], [3, 4, 5] ]
[ [ 1, 2 ], ["a", "b", "c"] ] # 这是可以的。
[ 1, 2.0 ] # 注意：这是不行的。

```

数组可以多行。也就是说，除了空格之外，方括号间的换行也会被忽略。在关闭方括号前的最终项后的逗号是允许的。

##### 表格

`表格（也叫哈希表或字典）是键值对的集合。它们在方括号内，自成一行。注意和数组相区分，数组只有值。`

[table]

在此之下，直到下一个　table 或　EOF 之前，是这个表格的键值对。是无序的。

你可以随意缩进，使用 Tab 或空格。为什么要缩进呢？因为你可以嵌套表格

```
[dog.tater]
type = "pug"
以上等价于如下的 JSON 结构：

{ "dog": { "tater": { "type": "pug" } } }
```

[x.y.z.w] # 可以直接写

空表是允许的，其中没有键值对。

然而你不能多次定义键和表格。这么做是不合法的

##### 表格数组

最后要介绍的类型是表格数组。表格数组可以通过包裹在双方括号内的表格名来表达。使用相同的双方括号名称的表格是同一个数组的元素。表格按照书写的顺序插入。双方括号表格如果没有键值对，会被当成空表。

```
[[products]]
name = "Hammer"
sku = 738594937

[[products]]

[[products]]
name = "Nail"
sku = 284758393
color = "gray"
等价于以下的　JSON 结构：

{
  "products": [
    { "name": "Hammer", "sku": 738594937 },
    { },
    { "name": "Nail", "sku": 284758393, "color": "gray" }
  ]
}

```

`注意` products是个数组

```
[[fruit]]
  name = "apple"

  [fruit.physical]
    color = "red"
    shape = "round"
```  
    


