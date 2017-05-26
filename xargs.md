# xargs

[xargs](http://man.linuxde.net/xargs)

### 介绍

xargs命令是给其他命令传递参数的一个过滤器，也是组合多个命令的一个工具。它擅长将标准输入数据转换成命令行参数，xargs能够处理管道或者stdin并将其转换成特定命令的命令参数。xargs也可以将单行或多行文本输入转换为其他格式，例如多行变单行，单行变多行。


`xargs的默认命令是echo，空格是默认定界符`。这意味着通过管道传递给xargs的输入将会包含换行和空白，不过通过xargs的处理，`换行和空白将被空格取代`。

### 使用

多行变单行

```
cat test.txt

a b c
d e f

cat test.txt|xargs

a b c d e f

```



`-n` 多行输出

```
cat test.txt

a b c
d e f

cat test.txt|xargs -n2

a b
c d
e f

```

`-d` 自定义界符

```
echo "nameXnameXnameXname" | xargs -dX 

name name name name

```

读取stdin，将格式化后的参数传递给命令行

```
xargs的一个选项-I，使用-I指定一个替换字符串{}，这个字符串在xargs扩展时会被替换掉，当-I与xargs结合使用，每一个参数命令都会被执行一次：

cat arg.txt 
aaa 
bbb 
ccc

----

cat arg.txt | xargs -I {} ./sk.sh -p {} -l 

-p aaa -l 
-p bbb -l 
-p ccc -l 

```

`-I`后面替换的字符串`{}`也可以不指定，直接使用第二个`{}`
```
ls *.jpg | xargs -n1 -I cp {} /data/images

```

xargs和find结合使用

```
用rm 删除太多的文件时候，可能得到一个错误信息：/bin/rm Argument list too long. 用xargs去避免这个问题： 

find . -type f -name "*.log" -print0 | xargs -0 rm -f

xargs -0将\0作为定界符。 

统计一个源代码目录中所有php文件的行数： 
find . -type f -name "*.php" -print0 | xargs -0 wc -l 

查找所有的jpg 文件，并且压缩它们： 
find . -type f -name "*.jpg" -print | xargs tar -czvf images.tar.gz

```

xargs其他应用 

```
假如你有一个文件包含了很多你希望下载的URL，你能够使用xargs下载所有链接：
cat url-list.txt | xargs wget -c

```



