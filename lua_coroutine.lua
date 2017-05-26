# Lua 协程

## coroutine lib

创建协程
co = coroutine.create(co_func)
参数： 协程函数
返回值： 协程对象

暂停执行
v1, v2 = coroutine.yield(rsm_arg1, rsm_arg2...)
参数：传递给resume，作为resume的返回值
返回值：resume参数传递过来的数值


执行协程
ret, v1, v2 = coroutine.resume(co, co_arg1, co_arg2 ...)
参数： 传递给co，作为yield的返回值
返回值： ret：true/false，判断协程执行是否出错
         v1,v2..: yield的参数传递过来的数值

coroutine.running()
取得当前正在执行的协程对象co

协程有三个状态：suspend,running,dead

执行过程：
创建协程对象后，并不执行，在调用resume的时候触发第一次执行，这时候参数是传递给co_func的参数；
此时，resume处于挂起状态，直到遇到第一个yield，给resume传递数据，同时使得co挂起，resume得以
继续执行；如果后续没有新的resume，则yield后续的对象不会被执行。

## 利用协程实现的生产者消费者代码

```
local queue = {}
local len = 10

local function consumer(queue)
    for k,v in ipairs(queue) do
        print("consumer: ", v)
        queue[k] = nil
    end
    local queue = coroutine.yield(queue)
    print("queue len: ", #queue)
end

co = coroutine.create(consumer)

local function producer()
    while #queue < 10 do
        queue[#queue+1]= "consumer id: " .. tostring(#queue+1)
    end
    local ret, queue = coroutine.resume(co, queue)
    if ret ~= true then
        print("consume err!")
        return
    end
    coroutine.resume(co, queue)
end

producer()

```

## 协程和函数回调的对比

相同点:

都可以实现同一个进程内部的任务切换

都可以实现无锁非阻塞调度

差一点：

协程实现的对象，业务逻辑看起来更加清晰明确，有一个协程对象调度器coroutine统一管理；

函数回调方式，相当于调用者要维护调用逻辑和调度逻辑两部分功能。

