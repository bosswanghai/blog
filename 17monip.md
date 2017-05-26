# 17MonIp

### 存储文件

17monipdb.dat

```
    The 17mon dat file format in bytes:

        -----------
        | 4 bytes |                     <- offset number
        -----------------
        | 256 * 4 bytes |               <- first ip number index
        -----------------------
        | offset - 1028 bytes |         <- ip index
        -----------------------
        |    data  storage    |
        -----------------------
```

- offset number 表示前三段字节的整个偏移量

- first ip number index 存储着两段映射关系：

```

a.存储着ip第一个字节和该区域之间的映射关系

该区域每四个字节为一段，ip字段和该区域的映射关系是
ip_offset = ip1*4
ip_offset[1-4]即为目标区域

b.存储着该区域和ip index区域之间的映射关系

start_len = ip_offset[1-4]

start_len与ip index区域之间的映射关系为
start_len*8 + 1024 + 1 -3


```



ip index 每8个字节一个分段，byte2uint32(0,index[6],index[5],index[4])是data storage的索引， index[7]是data storage的长度。由此完成了ip索引和data storage之间的映射关系。


ip
