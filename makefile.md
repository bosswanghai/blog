# Makefile

##### 规则

```
<target> : <prerequisites> 
[tab]  <commands>

上面第一行冒号前面的部分，叫做"目标"（target），冒号后面的部分叫做"前置条件"（prerequisites）；第二行必须由一个tab键起首，后面跟着"命令"（commands）。

"目标"是必需的，不可省略；"前置条件"和"命令"都是可选的，但是两者之中必须至少存在一个。
每条规则就明确两件事：构建目标的前置条件是什么，以及如何构建。

```


##### 目标

目标可以是文件或者操作名字

目标通常是文件名，指明Make命令所要构建的对象

除了文件名，目标还可以是某个操作的名字，这称为"伪目标"

```
clean:
      rm *.o

```

但是，如果当前目录中，正好有一个文件叫做clean，那么这个命令不会执行。因为Make发现clean文件已经存在，就认为没有必要重新构建了，就不会执行指定的rm命令。

为了避免这种情况，可以明确声明clean是"伪目标"，写法如下。

```

.PHONY: clean
clean:
        rm *.o temp
```

如果Make命令运行时没有指定目标，默认会执行Makefile文件的第一个目标。

eg:  make

##### 前置条件

前置条件通常是一组文件名，之间用空格分隔。

它指定了"目标"是否重新构建的判断标准：只要有一个前置文件不存在，或者有过更新（前置文件的last-modification时间戳比目标的时间戳新），"目标"就需要重新构建


```
result.txt: source.txt
    cp source.txt result.txt

source.txt:
    echo "this is the source" > source.txt
    
```

如果需要生成多个文件，往往采用下面的写法。

```
source: file1 file2 file3

```

##### 命令

命令（commands）表示如何更新目标文件，`由一行或多行的Shell命令`组成

```
每行命令之前必须有一个tab键。如果想用其他键，可以用内置变量.RECIPEPREFIX声明。
.RECIPEPREFIX = >
all:
> echo Hello, world

```

`每行命令在一个单独的shell中执行。这些Shell之间没有继承关系。`

```
var-lost:
    export foo=bar
    echo "foo=[$$foo]"

上面代码执行后（make var-lost），取不到foo的值。因为两行命令在两个不同的进程执行。一个解决办法是将两行命令写在一行，中间用分号分隔。

var-kept:
    export foo=bar; echo "foo=[$$foo]"
另一个解决办法是在换行符前加反斜杠转义。

var-kept:
    export foo=bar; \
    echo "foo=[$$foo]"
最后一个方法是加上.ONESHELL:命令。

.ONESHELL:
var-kept:
    export foo=bar; 
    echo "foo=[$$foo]"


```

##### 语法

* 注释

`#`

* echo

```
正常情况下，make会打印每条命令，然后再执行，这就叫做回声（echoing）。

test:
    # 这是测试
执行上面的规则，会得到下面的结果。

$ make test
 # 这是测试
在命令的前面加上@，就可以关闭回声。

test:
    @# 这是测试
现在再执行make test，就不会有任何输出。
由于在构建过程中，需要了解当前在执行哪条命令，所以通常只在注释和纯显示的echo命令前面加上@。

test:
    @# 这是测试
    @echo TODO

```

* 通配符

```
通配符（wildcard）用来指定一组符合条件的文件名。Makefile 的通配符与 Bash 一致，主要有星号（*）、问号（？）和 [...] 

```

* 模式匹配

```
Make命令允许对文件名，进行类似正则运算的匹配，主要用到的匹配符是%。比如，假定当前目录下有 f1.c 和 f2.c 两个源码文件，需要将它们编译为对应的对象文件。

%.o: %.c
等同于下面的写法。

f1.o: f1.c
f2.o: f2.c
使用匹配符%，可以将大量同类型的文件，只用一条规则就完成构建。
```

* 变量和赋值符

```
Makefile 允许使用等号自定义变量。

txt = Hello World
test:
    @echo $(txt)
上面代码中，变量 txt 等于 Hello World。调用时，变量需要放在 $( ) 之中。
调用Shell变量，需要在美元符号前，再加一个美元符号，这是因为Make命令会对美元符号转义。

test:
    @echo $$HOME
有时，变量的值可能指向另一个变量。

v1 = $(v2)
上面代码中，变量 v1 的值是另一个变量 v2。这时会产生一个问题，v1 的值到底在定义时扩展（静态扩展），还是在运行时扩展（动态扩展）？如果 v2 的值是动态的，这两种扩展方式的结果可能会差异很大。
为了解决类似问题，Makefile一共提供了四个赋值运算符 （=、:=、？=、+=），它们的区别请看StackOverflow。

VARIABLE = value
 # 在执行时扩展，允许递归扩展。

VARIABLE := value
 # 在定义时扩展。

VARIABLE ?= value
 # 只有在该变量为空时才设置值。

VARIABLE += value
 # 将值追加到变量的尾端。

```

##### 内置变量（Implicit Variables）

Make命令提供一系列内置变量，比如，$(CC) 指向当前使用的编译器，$(MAKE) 指向当前使用的Make工具。这主要是为了跨平台的兼容性，详细的内置变量清单见手册。

```
output:
    $(CC) -o output input.c

```

##### 自动变量    

```
（1）$@
$@指代当前目标，就是Make命令当前构建的那个目标。比如，make foo的 $@ 就指代foo。

a.txt b.txt: 
    touch $@
等同于下面的写法。

a.txt:
    touch a.txt
b.txt:
    touch b.txt

（2）$<
$< 指代第一个前置条件。比如，规则为 t: p1 p2，那么$< 就指代p1。

a.txt: b.txt c.txt
    cp $< $@ 
等同于下面的写法。

a.txt: b.txt c.txt
    cp b.txt a.txt 
（3）$?
$? 指代比目标更新的所有前置条件，之间以空格分隔。比如，规则为 t: p1 p2，其中 p2 的时间戳比 t 新，$?就指代p2。
（4）$^
$^ 指代所有前置条件，之间以空格分隔。比如，规则为 t: p1 p2，那么 $^ 就指代 p1 p2 。
（5）$*
$* 指代匹配符 % 匹配的部分， 比如% 匹配 f1.txt 中的f1 ，$* 就表示 f1。
（6）$(@D) 和 $(@F)
$(@D) 和 $(@F) 分别指向 $@ 的目录名和文件名。比如，$@是 src/input.c，那么$(@D) 的值为 src ，$(@F) 的值为 input.c。

（7）$(<D) 和 $(<F)
$(<D) 和 $(<F) 分别指向 $< 的目录名和文件名。
所有的自动变量清单，请看手册。下面是自动变量的一个例子。

dest/%.txt: src/%.txt
    @[ -d dest ] || mkdir dest
    cp $< $@
上面代码将 src 目录下的 txt 文件，拷贝到 dest 目录下。首先判断 dest 目录是否存在，如果不存在就新建，然后，$< 指代前置文件（src/%.txt）， $@ 指代目标文件（dest/%.txt）。

```

##### 判断和循环

Makefile使用 Bash 语法，完成判断和循环。

```
ifeq ($(CC),gcc)
  libs=$(libs_for_gcc)
else
  libs=$(normal_libs)
endif

上面代码判断当前编译器是否 gcc ，然后指定不同的库文件。

LIST = one two three
all:
    for i in $(LIST); do \
        echo $$i; \
    done

 # 等同于

all:
    for i in one two three; do \
        echo $i; \
    done

上面代码的运行结果。

one
two
three


```

##### 函数

```
Makefile 还可以使用函数，格式如下。

$(function arguments)
 # 或者
${function arguments}
Makefile提供了许多内置函数，可供调用。下面是几个常用的内置函数。
（1）shell 函数
shell 函数用来执行 shell 命令

srcfiles := $(shell echo src/{00..99}.txt)
（2）wildcard 函数
wildcard 函数用来在 Makefile 中，替换 Bash 的通配符。

srcfiles := $(wildcard src/*.txt)
（3）subst 函数
subst 函数用来文本替换，格式如下。

$(subst from,to,text)
下面的例子将字符串"feet on the street"替换成"fEEt on the strEEt"。

$(subst ee,EE,feet on the street)
下面是一个稍微复杂的例子。

comma:= ,
empty:=
 # space变量用两个空变量作为标识符，当中是一个空格
space:= $(empty) $(empty)
foo:= a b c
bar:= $(subst $(space),$(comma),$(foo))
 # bar is now `a,b,c'.
（4）patsubst函数
patsubst 函数用于模式匹配的替换，格式如下。

$(patsubst pattern,replacement,text)
下面的例子将文件名"x.c.c bar.c"，替换成"x.c.o bar.o"。

$(patsubst %.c,%.o,x.c.c bar.c)
（5）替换后缀名
替换后缀名函数的写法是：变量名 + 冒号 + 后缀名替换规则。它实际上patsubst函数的一种简写形式。

min: $(OUTPUT:.js=.min.js)
上面代码的意思是，将变量OUTPUT中的后缀名 .js 全部替换成 .min.js 。

```

##### 实例

```
（1）执行多个目标

.PHONY: cleanall cleanobj cleandiff

cleanall : cleanobj cleandiff
        rm program

cleanobj :
        rm *.o

cleandiff :
        rm *.diff
上面代码可以调用不同目标，删除不同后缀名的文件，也可以调用一个目标（cleanall），删除所有指定类型的文件。
（2）编译C语言项目

edit : main.o kbd.o command.o display.o 
    cc -o edit main.o kbd.o command.o display.o

main.o : main.c defs.h
    cc -c main.c
kbd.o : kbd.c defs.h command.h
    cc -c kbd.c
command.o : command.c defs.h command.h
    cc -c command.c
display.o : display.c defs.h
    cc -c display.c

clean :
     rm edit main.o kbd.o command.o display.o

.PHONY: edit clean

```

##### doc

[reference](http://www.ruanyifeng.com/blog/2015/02/make.html)