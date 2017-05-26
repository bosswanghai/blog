# FFI

### 介绍
FFI 库，是 LuaJIT 中*最重要*的一个扩展库。它允许从纯 Lua 代码调用`外部C函数`，使用 `C 数据结构`。

在 JIT 编译过的代码中，调用 C 函数，可以被内连处理，`不同于`基于 Lua/C API 函数调用。  说明FFI库比正常的LUA/C API调用高效很多。


### 使用

[doc](http://blog.csdn.net/alexwoo0501/article/details/50636785)

##### 调用C函数

```
local ffi = require("ffi")
ffi.cdef[[
int printf(const char *fmt, ...);
]]
ffi.C.printf("Hello %s!", "world")
```

* 加载 FFI 库。
* 为函数增加一个函数声明。这个包含在 中括号 对之间的部分，是标准C语法。
* 调用命名的 C 函数——非常简单。

> 使用标准C库的命名空间 ffi.C。通过符号名 ("printf") 索引这个命名空间，自动绑定标准 C 库。索引结果是一个特殊类型的对象，当被调用时，执行 printf 函数。传递给这个函数的参数，从 Lua 对象自动转换为相应的 C 类型。

##### 复杂调用

`ffi接口返回的是cdata类型的数据结构或者单位，Lua不能直接打印。`



```
lua中的local str在ffi中默认的是string，如果要传递给c的函数参数，两种方式
a. c函数中使用const char *
b.
local text = "text"
local c_str = ffi.new("char[?]", #text)
ffi.copy(c_str, text)
lib.drawText(fb, px, py, c_str, color)

加载so
local zlib = ffi.load(ffi.os == "Windows" and "zlib1" or "z")
若A.so对B.so有依赖，则在A.so load前，先ffi.load("B", true)，true表示加载到全局空间。


指针
ffi.new 返回的对应c里面的指针
返回的数值应该是地址，返回的应该是地址，但是是C


数组
local buf = ffi.new("uint8_t[?]", n)
? 表示可变数组
n 表示数组长度

返回的是一个int *的指针，相当于数组首地址


整数
local buflen = ffi.new("unsigned long[1]")

申请了一个字节的数组，类型是unsigned long*

传入null参数可以直接设置为nil


返回值

字符串
ffi.new("const char [?]", strnum)
申请了char *的数组

ffi.new("const char *[?]", strnum)

申请了可变长数组，长度为n
类型为 char **

ffi.string(buf, [buflen])
返回一个lua的string对象

如果buf为null，则会发生segfault
cdata的NULL对象可以用lua nil进行判断


For example:

a= some_c_data_which_is_NULL_pointer
print(a) -- prints cdata<somectype>: NULL
print(a == nil) -- it's true!! kind of useful…

-- and now, a very common Lua idiom, since a == nil...
print(a or "hello") -- guess what, it prints cdata<somectype>: NULL
print(ffi.string(a or "hello")) -- WTF! segmentation fault!!1!!eleven1!
print(ffi.string(a ~= nil a or "hello")) -- this one works, but unnecessarily 
verbose


```

##### 使用C数据结构

[openresty ffi](https://moonbingbing.gitbooks.io/openresty-best-practices/content/lua/FFI.html)

```
ffi.cdef [[
struct student {
int a,
char c,
} Stu;
]]

local stu = Stu(1,'c')

local stu = ffi.new("Stu",{1, 'c'})
```

##### idiom

如果要传递参数int *，需要在lua中先x=ffi.new(int[1])，x[0]=11

如果要传递char *，对于c读取lua字符串，可以直接传递lua字符串str='abcd'。对于lua包含c返回char *，需要先申请str=ffi.new("char ")

```
Idiom	C code	Lua code
Pointer dereference
int *p;	x = *p;
*p = y;	x = p[0]
p[0] = y
Pointer indexing
int i, *p;	x = p[i];
p[i+1] = y;	x = p[i]
p[i+1] = y
Array indexing
int i, a[];	x = a[i];
a[i+1] = y;	x = a[i]
a[i+1] = y
struct/union dereference
struct foo s;	x = s.field;
s.field = y;	x = s.field
s.field = y
struct/union pointer deref.
struct foo *sp;	x = sp->field;
sp->field = y;	x = s.field
s.field = y
Pointer arithmetic
int i, *p;	x = p + i;
y = p - i;	x = p + i
y = p - i
Pointer difference
int *p1, *p2;	x = p1 - p2;	x = p1 - p2
Array element pointer
int i, a[];	x = &a[i];	x = a+i
Cast pointer to address
int *p;	x = (intptr_t)p;	x = tonumber(
 ffi.cast("intptr_t",
          p))
Functions with outargs
void foo(int *inoutlen);	int len = x;
foo(&len);
y = len;	local len =
  ffi.new("int[1]", x)
foo(len)
y = len[0]
Vararg conversions
int printf(char *fmt, ...);	printf("%g", 1.0);
printf("%d", 1);
 	printf("%g", 1);
printf("%d",
  ffi.new("int", 1))
```

##### To Cache or Not to Cache

ffi需要缓冲空间而不是具体的函数，这是由于ffi的机制导致的。

local funca, funcb = ffi.C.funca, ffi.C.funcb -- Not helpful!

local C = ffi.C          -- Instead use this!

local lib = ffi.load(...)  -- Instead use this!