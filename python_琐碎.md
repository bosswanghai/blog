# python 琐碎

### 琐碎点

##### string.format

自python2.6开始，新增了一种格式化字符串的函数str.format()

`它通过{}和:来代替%。`

** 通过位置 **

```
In [1]: '{0},{1}'.format('kzc',18)
Out[1]: 'kzc,18'
In [2]: '{},{}'.format('kzc',18)
Out[2]: 'kzc,18'
In [3]: '{1},{0},{1}'.format('kzc',18)
Out[3]: '18,kzc,18'
```

** 通过关键字参数 **

```
In [5]: '{name},{age}'.format(age=18,name='kzc')
Out[5]: 'kzc,18'

```

** 通过对象属性 **

```

class Person:
    def __init__(self,name,age):
        self.name,self.age = name,age
        def __str__(self):
            return 'This guy is {self.name},is {self.age} old'.format(self=self)

In [2]: str(Person('kzc',18))
Out[2]: 'This guy is kzc,is 18 old'

```

** 通过下标 **

```
In [7]: p=['kzc',18]
In [8]: '{0[0]},{0[1]}'.format(p)
Out[8]: 'kzc,18'

```

##### 参数*args和**kargs，tuple和dict

t = ("a",1,2)

d = {name="wang",age=11}

他们可以作为参数进行传递
test_args(*args) -- tuple传参对应着args

test_kargs(**kargs) -- dict传参对应着kargs


##### 迭代器
generator: 生成器保存的是算法，调用next就可以取出下一个数值，增加yield可以是的一个普通函数变为迭代器，
           生成器都是iterator对象
iterable: 迭代的本质是一个一个取数据，因此可以被for用来迭代的都可以被称为Iterable
iterator: 迭代器本身内置了iter方法，可以通过dir(obj)来查看，迭代器对象不是指迭代数据本身，而是一个取迭代对象的算法，这个算法不关心对象的整体数据，它把对象
          看做成一个数据流，相当于对数据流做流式处理

for循环适用类型:
集合类数据
generator：包括生成器和带yield的生成器函数
判断一个对象是否是可迭代的：isinstance([], Iterable)

next适用类型：
generator即iterator
最后抛出StopIteration表示迭代终止


把list、dict、str等Iterable变成Iterator可以使用iter()函数
将类定义为可迭代对象，需要定义__iter__和next方法


```
def generator(t):
    for v in t:
        yield v

t = (1,2,3,4)

g = generator(t)

print next(g)
print next(g)
print next(g)
print next(g)

it = iter(t)

print next(it)
print next(it)
print next(it)
print next(it)


class Gen(object):
    def __init__(self, n):
        self.id = 0
        self.n = n

    def __iter__(self):
        return self

    def __str__(self):
        return "test class str method"

    def next(self):
        if self.id < self.n:
            v = self.id
            self.id += 1
        else:
            raise StopIteration()
        return v

g = Gen(3)
print str(g)
print next(g)
print next(g)
print next(g)
print next(g)

```


##### 调试

调试方法:
python -m pdb my_script.py

设置断点：
pdb.set_trace()

```
c: 继续执行
w: 显示当前正在执行的代码行的上下文信息
a: 打印当前函数的参数列表
s: 执行当前代码行，并停在第一个能停的地方（相当于单步进入）
n: 继续执行到当前函数的下一行，或者当前行直接返回（单步跳过）
```

##### 装饰器
```
def log(fn):
    def wrapper():
        print "hello 1"
        fn()
        print "hello 2"
    return wrapper

def log2(fn):
    def wrapper():
        print "hello 3"
        fn()
        print "hello 4"
    return wrapper

@log
@log2
def hello(v = None):
    print v or "abc"

hello() ## means two thing, hello = decorator(hello), hello()
## hello = log(log2(hello)), hello()
```

以类的方式声明装饰器

```
class Dec(object):
    def __init__(self, fn):
        print("this is init")
        self.fn = fn

    def __call__(self):
        print "this is call fn"
        self.fn()


@Dec
def myfunc():
    print "my func"

myfunc() ## means two steps: myfunc = Dec(myfunc), myfunc()

```


##### list/dict遍历

```
list遍历

a = ["a", "b", "c", "d"]

直接取值
for i in a:
    print i

取索引
for i in xrange(len(a)):
    print i, a[i]

enumerate取索引取值
for i, el in enumerate(a):
    print i, el

从1开始遍历
for i, el in enumerate(a, 1):
    print i, el



```


```
dict遍历

d = {'a': 1, 'c': 3, 'b': 2, 'd': 4}

for k in d:
    print k, d[k]


for k, v in d.iteritems():
    print k, v


```

#### lambda

lambda是一种简写匿名函数，使得代码简洁，类似于for .. in .. if ..

```
a=['a','b','c']

g = lambda x: x + "test"

for v in a:
    print(g(v))


# filter, map, reduce
foo = [2, 18, 9, 22, 17, 24, 8, 12, 27]

print filter(lambda x: x % 3 == 0, foo)
print [x for x in foo if x % 3 == 0]


print map(lambda x: x + 100, foo)
print [x + 100 for x in foo]

print reduce(lambda x,y: x + y, foo)
```

处理字符串将空格替换为下划线
processFunc = lamda x: "_".join(x.split(" ")) or lambda x: x

#### 反射
反射是根据函数类等名字的字符串得到具体的方法或者类名的一种方法，在java的web框架中使用较多
print getattr(t, "method_test", "default method")
print hasattr(t, "method")


#### mutation 变动对象
- python中的list对象是可变动的，即对同一个对象重新命名，结果就是两个变量名即两个指针指向同一个对象

- python中的函数定义的时候，默认参数只会被运行一次，而不是每次都会被运行，这时候会产生一些诡异的现象。

```
def test(x, t = []):
    t.append(x)
    return t

print test(1) #output 1
print test(2) #output 1,2
```

所以正常使用的时候，函数定义列表的时候应该如下的：
def test(x, t = None)

#### slots
python类在初始化的时候，会以字典的形式保留字典属性，这时候会有很多无关的额外属性，这些属性在小类，被使用
频率很高的时候，会占用多余的内存，通过__slots__来指定哪一些字段需要保留在类字典中可以节约不少内存

```
class Test(object):
    __slots__ = ["name"]
    def __init__():
        self.name = "wang"

```

#### 自省对象

dir: 可以打印对象的所有属性和方法，包括内置的__

type: 可以打印对象的类型

id: 可以打印对象唯一id


```
class Test(object):
    def method(self):
        pass

t = Test()

print dir(t)
print type(t)
print id(t)
```

#### 对象属性设置

```
class Test(object):

    @property
    def score(self):
        return self.score

    @score.setter
    def score(self, value):
        if not isinstance(value, int):
            raise Exception("score type is not int")
        if value < 0 or value > 100:
            raise ValueError("score is beyond valid range")
        self.score = value

t = Test()
t.score = 10
print t.score

t.score = "ab"
print t.score
```

通过property方法声明对象属性
通过score.setter声明设置类型


#### 进程
```
from multiprocessing import Process

def run_proc2(*args):
    print 'run child process  ', args

if 'main':
    print 'main process start ..'
    p = Process(target = run_proc2, args = ('test1','test2'))
    p.start()
    p.join()
    print 'main process end'

```

进程池使用

```
def long_time_task(name):
    print 'run task {} .. '.format(name)
    start = time.time()
    time.sleep(random.random()*3)
    end = time.time()
    print 'Task %s run %0.2f seconds. ' % (name, (end-start))

print 'Parent process pid %s' % os.getpid()
p = Pool()
for i in range(5):
    p.apply_async(long_time_task, args=(i,))

p.close()
p.join()

print 'all process done'
```

进程间通信

```
def write(q):
    for v in ['A', 'B', 'C', 'D']:
        print 'Put %s to queue..' % v
    q.put(v)
    time.sleep(random.random())

def read(q):
    while True:
        v = q.get(True)
        print 'Get %s from queue ..' % v

q = Queue()
pw = Process(target=write, args=(q,))
pr = Process(target=read, args=(q,))

pw.start()
pr.start()
time.sleep(3)
pw.join()
pr.terminate()

```

#### 线程
```
import time, threading

def thread_worker(*args):
    print 'thread  start .. ' , args, threading.current_thread().name

t = threading.Thread(target = thread_worker, name = "thread worker", args =
        (1,2))
t.start()

t.join()
print 'all thread end'

```
线程互斥

```
threadLock = threading.Lock()

threadLock.acquire()
threadLock.release()

```

#### 协程

协程的本质其实就是程序内部的自我协调，不需要额外启动线程，不需要额外的锁，因此效率高。
高效利用cpu的方式就是多进程+进程内部使用协程

```
import time

def consumer():
    r = ''
    while True:
        n = yield r
        if not n:
            return
        print "consume %s " % n
        time.sleep(1)
        r = "200 ok"

def producer(c):
    c.next() //TypeError: can't send non-None value to a just-started generator
             // 需要额外先启动生成器
    n = 0
    while n < 5:
        n += 1
        print "producer snd %s " % n
        r = c.send(n)
        print "produer recv %s " % r

    c.close()

c = consumer()
producer(c)

```

#### * **
*: unpack tuple
**: unpack dict

两种用法：

```
def test(x, y):
    print x,y

    t = (1,2)

    test(*t)
```

```
t = (1,2)
def test2(*args):
    print args

    test2(1,2)
```

第一种表示将一个tuple数组进行unpack；第二种表示将所有参数进行pack程一个tuple
同理， ** 对应着dict


#### map
rv = map(function, iterable)
对每一个可迭代对象使用function函数
