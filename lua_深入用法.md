# lua 深入用法

### C API

两种观点(Lua作为扩展性语言和可扩展的语言)对应的C和Lua中间有两种交互方式。第一种，C作为应用程序语言，Lua作为一个库使用；第二种，反过来，Lua作为程序语言，C作为库使用。这两种方式，C语言都使用相同的API与Lua通信，因此C和Lua交互这部分称为C API。

C API是一个C代码与Lua进行交互的函数集。他有以下部分组成：读写Lua全局变量的函数，调用Lua函数的函数，运行Lua代码片断的函数，注册C函数然后可以在Lua中被调用的函数，等等。（本书中，术语函数实际上指函数或者宏，API有些函数为了方便以宏的方式实现）

C API遵循C语言的语法形式，这Lua有所不同。

在C和Lua之间通信关键内容在于一个虚拟的栈.
几乎所有的API调用都是对栈上的值进行操作，所有C与Lua之间的数据交换也都通过这个栈来完成。另外，你也可以使用栈来保存临时变量。栈的使用解决了C和Lua之间两个不协调的问题：`第一，Lua会自动进行垃圾收集，而C要求显示的分配存储单元，两者引起的矛盾。第二，Lua中的动态类型和C中的静态类型不一致引起的混乱。`


### string 相关

```
string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end

```

### table 相关
##### __index

`访问`table中的元素，不存在的时候，寻找__index

```
Window = {}

Window.prototype = {x = 0 ,y = 0 ,width = 100 ,height = 100,}
Window.mt = {}
function Window.new(o)
	setmetatable(o ,Window.mt)
	return o
end
Window.mt.__index = function (t ,key)
	-- body
	return 1000
end
w = Window.new{x = 10 ,y = 20}
print(w.wangbin)

```

##### __newindex
`设置` table中的元素，不存在的时候，进行赋值

```
Window.mt = {}
function Window.new(o)
	setmetatable(o ,Window.mt)
	return o
end
Window.mt.__index = function (t ,key)
	return 1000
end
Window.mt.__newindex = function (table ,key ,value)
	if key == "wangbin" then
		rawset(table ,"wangbin" ,"yes,i am")
	end
end
w = Window.new{x = 10 ,y = 20}
w.wangbin = "55"
print(w.wangbin)
```

##### rawget

为了绕过`__index`

```
Window = {}

Window.prototype = {x = 0 ,y = 0 ,width = 100 ,height = 100,}
Window.mt = {}
function Window.new(o)
	setmetatable(o ,Window.mt)
	return o
end
Window.mt.__index = function (t ,key)
	return 1000
end
Window.mt.__newindex = function (table ,key ,value)
	if key == "wangbin" then
		rawset(table ,"wangbin" ,"yes,i am")
	end
end
w = Window.new{x = 10 ,y = 20}
print(rawget(w ,w.wangbin))
打印结果是:nil。这里的元表中__index函数就不再起作用了

```

##### rawset

为了绕过`__newindex`

```
Window = {}
Window.prototype = {x = 0 ,y = 0 ,width = 100 ,height = 100,}
Window.mt = {}
function Window.new(o)
	setmetatable(o ,Window.mt)
	return o
end
Window.mt.__index = function (t ,key)
	return 1000
end
Window.mt.__newindex = function (table ,key ,value)
	table.key = "yes,i am"
end
w = Window.new{x = 10 ,y = 20}
w.wangbin = "55"

```

然后我们的程序就stack overflow了。可见，程序陷入了死循环。

##### 迭代器

for后面跟几个数值，则迭代函数就需要返回多少个数值，遇到第一个为nil的，则迭代器终止。

无状态迭代器
```
local tb = {"aa", "bb", "cc"}

local function iterm(tb, idx)
        local len = #tb
        if idx > len then
             return
        end
        idx = idx + 1
        return idx, tb[idx]
end

for k, v in iterm,tb,0  do
    print(k, v)
end

```


有状态迭代器： 本质上是利用了闭包函数。
```
local tb = {"aa", "bb", "cc"}

local function iterm(tb)
    local idx = 0
    local len = #tb
    return function()
        if idx > len then
             return
        end
        idx = idx + 1
        return tb[idx]
    end
end

for k in iterm(tb) do
    print(k)
end

```

loadfile——只编译，不运行，类似于c侧调用loadbuffer

dofile加载并执行

```
    function dofile(filename)
    　　local f = assert(loadfile(filename)) --调用loadfile（的返回结果）并可处理错误
    return f()
    end

```
require——只执行一次
```
require和dofile有点像，不过又很不一样，require在第一次加载文件的时候，会执行里面的代码。
但是，第二次之后，再次加载文件，则不会重复执行了。换句话说，它会保存已经加载过的文件，不会重复加载。
```

loadstring 在>=5.2之后，已经被load进行了替换

```
1.特点：功能强大，但开销大；
2.典型用处：执行外部代码，如：用户的输入
3.错误错里：代码中如果有语法错误就会返回nil
4.理解：f = loadstring("i = i+1")  可理解为（但不完全是）f = function()  i = i+1  end
(注：这里的变量"i"是全局变量，不是指局部变量，如果没有定义全局变量"i",调用f()则会报错！，即loadstring   不涉及词法域)
loadstring本质是将其作为一个匿名函数放在c stack的顶部

```

