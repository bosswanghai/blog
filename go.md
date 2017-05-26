# go
### go 简介

有开发效率：有表达力，清晰，简洁，有效率

并行机制容易开发多核和网络应用

新奇的类型系统： 构建有弹性的模块化编程

便利的垃圾回收和强大的运行时`反射`

是静态的，但看起来像动态的


### 基础

#### package

每个go程序都是由包组成的

程序的入口是包main

包名与导入路径的最后一个目录保持一致  "math/rand"

`包导入`

import "fmt"

import "math/rand"

<==>

import (
	"fmt"
	"math/rand"
)

`包导出`

即包的私有属性和公有属性

在包中，首字母大写是public的，小写是private的。
Foo/FOO都是公有的，foo是私有的


eg

```
package main

import (
	"fmt"
	"math/rand"
)

func main() {
	fmt.Println("My favorite number is", rand.Intn(10))
}

```

#### 函数

- 类型

变量和函数都是类型后置

当两个或多个连续的函数命名参数是同一类型，则除了最后一个类型之外，其他都可以省略

- 返回值

```
多值返回
func func_name(x, y int) (int, int, string){}
```
```
返回值命名
Go 的返回值可以被命名，并且就像在函数体开头声明的变量那样使用。
裸返回


```


eg

```
func add(x int, y int) int {
	return x+y
}

func add(x, y int) int {
	return x+y
}
```

#### 变量

- 变量定义

var x int

- 变量初始化

var x, y int = 1, 2

var x, y, z = true, 1, "haha"

- 短声明变量

在函数中， := 简洁赋值语句在明确类型的地方，可以用于替代 var 定义。

函数外的每个语句都必须以关键字开始（ var 、 func 、等等）， := 结构不能使用在函数外。


#### 类型

```
bool

string

int  int8  int16  int32  int64
uint uint8 uint16 uint32 uint64 uintptr

byte // uint8 的别名

rune // int32 的别名
     // 代表一个Unicode码

float32 float64

complex64 complex128

```

```
变量组

var (
	ToBe   bool       = false
	MaxInt uint64     = 1<<64 - 1
	z      complex128 = cmplx.Sqrt(-5 + 12i)
)
```

变量的格式化输出

```
%T 表示类型
%v 表示数值

```

变量的零值

```
变量在定义时候，没有被初始化会被复制为零值

字符串 ""

数字 0

bool false

```

#### 类型转换

```
var b = T(a)

需要显示的指定T的类型

```


#### 类型推导

定义一个变量不显示指定其类型，会自动根据右侧变量的类型进行推导

var b = a
则b的类型和a的类型的一致的

#### 常量

常量定义与变量类似，使用const关键字

const str [string] = "haha"


### 循环控制

#### for

go只有一个循环控制for

```
for i:=1; i<100; i++ {
	sum += i
}
```
for条件不需要用()括起来，但是主体必须用{}

初始化和后置项都是可选的

```
for ; sum < 100; {

}

for sum < 100 {

}

```

死循环 for {}

#### 判断条件

`if`

```
if x < 0 {
	fmt.Println(x)
}

if x := var_b {}

```


```
if {
} else {
}

```
#### switch

```
	switch os := runtime.GOOS; os {
	case "darwin":
		fmt.Println("OS X.")
	case "linux":
		fmt.Println("Linux.")
	default:
		// freebsd, openbsd,
		// plan9, windows...
		fmt.Printf("%s.", os)
	}

```

没有条件的switch <==> switch true

```
switch {
	case bool1:
	case bool2:
	default:

}

switch会匹配第一个为true的数值

这种结构最好不要用，用if else 比较合适

```

#### defer

defer会延迟函数的执行，直到上层函数返回

延迟的函数调用被压入一个栈中。当函数返回时， 会按照后进先出的顺序调用被延迟的函数调用。

### 复杂类型

#### 指针

```
var p *int
var a int = aa
p = &a

```

`go不指针指针运算`


#### 结构体

```

type student struct {
    id int
    name string
}

使用

v := student{1,1}

v.id = 10

```

结构体指针的引用和结构体对象一样，都是ptr.item


结构体文法

使用 Name: 语法可以仅列出部分字段。（字段名的顺序无关。）

```
type Vertex struct {
	X, Y int
}

var (
	v1 = Vertex{1, 2}  // 类型为 Vertex
	v2 = Vertex{X: 1}  // Y:0 被省略
	v3 = Vertex{}      // X:0 和 Y:0
	p  = &Vertex{1, 2} // 类型为 *Vertex
)

func main() {
	fmt.Println(v1, p, v2, v3)
}

显示结果
{1 2} &{1 2} {1 0} {0 0}

```

#### 数组

var arr_int [10]int

有10个整数的数组，不能改变大小，从0开始

> 数组初始化

#### slice

slice的零值是nil，长度和容量都是0

```
s := []int{2, 3, 5, 7, 11, 13}

len(s)

```

##### slice中包含slice

```
game := [][]string{
		[]string{"abcd", "haha"}
}

strings.join(game[0], " ")
```

#### slice切片

s[a,b]

a<=  <b

s[a,a] 表示空[]

s[a,a+1]返回s[a]

s[a:]从下表a开始到结束

s[:b]从下表0开始到b)


#### 构造slice

func make(type, size IntergerType) type

指定长度是5的slice

s := make([]int , 5)

还可以指定容量

```
s:=make([]int, 0, 5)
len(s) = 0
cap(s) = 5

s=s[:cap(s)] len(s)=5, cap(s)=5

```

#### 向slice中追加元素

```
func append(s []T, vs ...T) []T

s=append(s, 1,2,3,4)

```
#### range

for 循环的 range 格式可以对 slice 或者 map 进行迭代循环。

`每次迭代 range 将返回两个值，下标和拷贝`


```
	for i, v := range pow {
		fmt.Printf("2**%d = %d\n", i, v)
	}

```

通过"_"来忽略返回值。

go的多值返回和_忽略返回值和lua比较像似。

#### map

map必须由make创造

```
定义
var mp map[string] int;

赋值
mp = make(map[string] int)

mp["wang"]=1


var m = map[string]Vertex{
	"Bell Labs": Vertex{
		40.68433, -74.39967,
	},
	"Google": Vertex{
		37.42202, -122.08408,
	},
}

```

go语言的赋值都是用的{}


#### map操作

插入元素
map[key]=v

获得元素
a=map[ke]

删除元素
delete(m, key)

检查key是否存在
a, ok = m[k]


#### 函数值

函数值也可以作为参数进行传递，相当于函数指针

```
func compute(fn func(float64, float64) float64) float64 {
	return fn(3, 4)
}

```

#### 函数闭包

Go 函数可以是一个闭包。闭包是一个函数值，它引用了函数体之外的变量。 这个函数可以对这个引用的变量进行访问和赋值；换句话说这个函数被“绑定”在这个变量上。

对同一个闭包函数引用两次，实际上会生成两个函数闭包对象，互补干扰，如果函数闭包的对象不是公有属性的话。


### 方法和接口

#### 方法

Go 没有类。然而，仍然可以在结构体类型上定义方法。

```

type Vertex struct {
	X, Y float64
}

func (v *Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
	v := &Vertex{3, 4}
	fmt.Println(v.Abs())
}


```


可以对包中的任意类型定义方法，不仅仅是结构体

使用方式如下

```
func (v type) func_name() type_ret{
	return v+1
}

```

选择(v type)或者(v *type)作为接收者

使用指针接收者的情况：

- 避免在每个方法中使用拷贝值

- 方法可以修改接收者指向的值


#### 接口

接口是一组方法定义的集合

```

定义

type Abser interface {
	Abs() int
}


使用

var a Abser

f := MyFloat(-math.Sqrt2)
v := Vertex{3, 4}

a = f  // a MyFloat 实现了 Abser
a = &v // a *Vertex 实现了 Abser
a = v // error 因为没有定义v的实现

type MyFloat float64  //宏定义

func (f MyFloat) Abs() float64 {
	if f < 0 {
		return float64(-f)
	}
	return float64(f)
}

type Vertex struct {
	X, Y float64
}

func (v *Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}


```

注意： 只有引用指针的时候，才能修改对象本身的属性，接口本身可以是指针或者对象的父类。


#### 错误

Go 程序使用 error 值来表示错误状态。

error是go的一个内建接口，fmt在输出的时候会尝试匹配error

```
package main

import (
	"fmt"
	"time"
)

type MyError struct {
	When time.Time
	What string
}

func (e *MyError) Error() string {
	return fmt.Sprintf("at %v, %s",
		e.When, e.What)
}


func run() error {
	return &MyError{
		time.Now(),
		"it didn't work",
	}
}

func main() {
	if err := run(); err != nil {
		fmt.Println(err)
	}
}

```


#### Reader接口

#### Web服务器

#### 图片

### 并发

#### goroutine

go的轻量级线程

go f(x,y,z)

goroutine 在相同的地址空间中运行，因此访问共享内存必须进行同步。sync 提供了这种可能，不过在 Go 中并不经常用到，因为有其他的办法。

#### channel

channel 是有类型的管道，可以用 channel 操作符 <- 对其发送或者接收值。

```
1. 创建channel

channel必须使用make创建

var ch channel = make(chan type)  // type是指管道的类型，可以是int/string等

2. 数据流方向

ch <- v    // 将 v 送入 channel ch。
v := <-ch  // 从 ch 接收，并且赋值给 v。

3. 阻塞情况

默认情况下，在另一端准备好之前，发送和接收都会阻塞。这使得 goroutine 可以在没有明确的锁或竞态变量的情况下进行同步。

```

#### 缓冲channel

channel带缓冲，由make第二个数值确定

make(chan int, 100)


```
	ch := make(chan int, 2)
	ch <- 1
	ch <- 2
	fmt.Println(<-ch)
	fmt.Println(<-ch)

```

#### channel的遍历和关闭

发送端调用close(c)关闭channel

接收端 v, ok = <-c
通过判断ok的数值来判断发送端是否关闭，ok=false如果发送端关闭了

for i := range c 会循环读取channel直到channel被关闭

只有发送端才能close channel，向一个已经关闭的channel发送数据会造成panic。通常情况下channel不需要关闭，关闭的场景经常是在要终止接收端的range循环的时候使用

#### select

select使得go的线程在多通道通信的情况下挂起，直到select的子用例可以执行。 当多个子用例可以同时执行的时候，会算计选择一个用例执行.

```

func fibonacci(c, quit chan int) {
	x, y := 0, 1
	for {
		select {
		case c <- x:
			x, y = y, x+y
		case <-quit:
			fmt.Println("quit")
			return
		}
	}
}

func main() {
	c := make(chan int)
	quit := make(chan int)
	go func() {
		for i := 0; i < 10; i++ {
			fmt.Println(<-c)
		}
		quit <- 0
	}()
	fibonacci(c, quit)
}

```

select 可以增加default选项，来处理其他的case没有准备好的情况下的处理情况。

```
select {
case <- c:
default:
    todo default
}

```

#### 互斥

go标准处理互斥使用的是sync.Mutex库

import "sync"

sync.Mutex下有两个方法，Lock和Unlock

```

// SafeCounter is safe to use concurrently.
type SafeCounter struct {
	v   map[string]int
	mux sync.Mutex
}

// Inc increments the counter for the given key.
func (c *SafeCounter) Inc(key string) {
	c.mux.Lock()
	// Lock so only one goroutine at a time can access the map c.v.
	c.v[key]++
	c.mux.Unlock()
}


```


### others

empty interface
a set of methods
a type: all type implement from this type

empty interface的第二个特性可以用来做模板

```
type T interface{}

func test(t T) {
    fmt.Println(t)
}

test(11)
test("abc")

```

### 错误处理

go没有try catch finally,选择了使用error，panic, recover来处理错误

```
    defer func() {
        fmt.Println("in")
        if err := recover(); err != nil {
            fmt.Println(err)
        }
        fmt.Println("out")
    }()

    panic(e)


type MyError struct {
    When time.Time
    What string
}

func (e *MyError) Error() string {
    return fmt.Sprintf("at %v, %s", e.When, e.What)
}

func run() error {
    return &MyError{
        time.Now(),
        "this is my error",
    }
}

```


#### 自省和反射




