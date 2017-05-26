# JVM

## 简介

JRE由JVM、java core classes、java 平台组建构成

JVM相当于提供了一个与系统无关的软件隔离平台

## 架构

JVM hotspot架构

```

java class file    ------->   class load system
									|
									|
									|
running time:  method heap  thread   pc_counter   native内部线程
									|
									|
excute: jit  gc   <------>  native interface   <----->  native method lib

```


## native method

JAVA实现平台隔离的关键，封装的是java调用c++的接口，在c++中实现了平台相关的操作。

native方法是通过java中的JNI实现的。JNI是Java Native Interface的 缩写。

目前java与dll交互的技术主要有3种：jni，jawin和jacob。

java>jni>jawin>jacob，层层包含关系，可用性外层最好。


[native 实例](http://blog.csdn.net/xw13106209/article/details/6989415)


## GC


### 简介

garbage collection

concurrent: 并发, 多个线程协同做同一件事情(有状态)

parallel: 并行, 多个线程各做各的事情(互相间无共享状态)

### 分类

上一代的垃圾收集器(串行serial, 并行parallel, 以及CMS)都把堆内存划分为固定大小的三个部分: 年轻代(young generation), 年老代(old generation), 以及持久代(permanent generation).

young: eden+survivor space(s0  s1)

old: 

permanent

内存放在这三个区域中的一个。

新的垃圾回收器 G1

### G1 GC

#### 简介

G1 (Garbage-First)是一款面向服务器的垃圾收集器,主要针对配备多颗处理器及大容量内存的机器. 以极高概率满足GC停顿时间要求的同时,还具备高吞吐量性能特征.

特点

```
可以像CMS收集器一样,GC操作与应用的线程一起并发执行
紧凑的空闲内存区间且没有很长的GC停顿时间.
需要可预测的GC暂停耗时.
不想牺牲太多吞吐量性能.
启动后不需要请求更大的Java堆.

```

#### 原理

不同于老的垃圾回收器，只有三个区域，每个heap都放在三个区域中的一个。

G1将每个heap作为一个独立区域，然后分别为他们进行上色，分别问 young, old, permanent

G1标记哪些内存区域是活动的，然后将`最空余`的heap进行优先回收，这就是所谓的garbage first: G1.

G1`不是实时`的，会将目标暂停，同时在这个阶段内`尽可能`的完成收集。

G1收集分为两个阶段：

并发：concurrent, 与应用线程一起运行, 如: 细化 refinement、标记 marking、清理 cleanup

并行：parallel, 多线程执行, 如: 停止所有JVM线程, stop the world（STW）

G1内存占用:

```
如果从 ParallelOldGC 或者 CMS收集器迁移到 G1, 您可能会看到JVM进程占用更多的内存(a larger JVM process size). 这在很大程度上与 “accounting” 数据结构有关, 如 Remembered Sets 和 Collection Sets.

Remembered Sets 简称 RSets, 跟踪指向某个heap区内的对象引用. 堆内存中的每个区都有一个 RSet. RSet 使heap区能并行独立地进行垃圾集合. RSets的总体影响小于5%.

Collection Sets 简称 CSets, 收集集合, 在一次GC中将执行垃圾回收的heap区. GC时在CSet中的所有存活数据(live data)都会被转移(复制/移动). 集合中的heap区可以是 Eden, survivor, 和/或 old generation. CSets所占用的JVM内存小于1%.

```

#### 推荐使用场景

G1的首要目标是为需要大量内存的系统提供一个保证GC低延迟的解决方案. 也就是说堆内存在6GB及以上,稳定和可预测的暂停时间小于0.5秒.

如果应用程序具有如下的一个或多个特征,那么将垃圾收集器从CMS或ParallelOldGC切换到G1将会大大提升性能.

Full GC 次数太频繁或者消耗时间太长.
对象分配的频率或代数提升(promotion)显著变化.
受够了太长的垃圾回收或内存整理时间(超过0.5~1秒)
注意: 如果正在使用CMS或ParallelOldGC,而应用程序的垃圾收集停顿时间并不长,那么继续使用现在的垃圾收集器是个好主意. 使用最新的JDK时并不要求切换到G1收集器。

#### G1实际运行过程

[G1过程](http://blog.csdn.net/renfufei/article/details/41897113)

年轻代收集： 触发STW(stop the world),将所有年轻代拷贝到新的survivor区域（统一视为年轻代区域）或者老年代区域，是并发收集的。

存活对象收集： 归属在年轻代收集中

老年代收集： 删除没有用到的老年带，把年轻代区域拷贝到老年代区域。


#### G1命令行与最佳实践

java -Xmx50m -Xms50m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 hello

```

关键命令行开关

-XX:+UseG1GC - 让 JVM 使用 G1 垃圾收集器.

-XX:MaxGCPauseMillis=200 - 设置最大GC停顿时间(GC pause time)指标(target). 这是一个软性指标(soft goal), JVM 会尽力去达成这个目标. 所以有时候这个目标并不能达成. 默认值为 200 毫秒.

-XX:InitiatingHeapOccupancyPercent=45 - 启动并发GC时的堆内存占用百分比. G1用它来触发并发GC周期,基于整个堆的使用率,而不只是某一代内存的使用比例。值为 0 则表示“一直执行GC循环)'. 默认值为 45 (例如, 全部的 45% 或者使用了45%).

```

最佳实践

```
不要设置年轻代的大小(Young Generation Size)

假若通过 -Xmn 显式地指定了年轻代的大小, 则会干扰到 G1收集器的默认行为.



什么是转移失败(Evacuation Failure)?

对 survivors 或 promoted objects 进行GC时如果JVM的heap区不足就会发生提升失败(promotion failure). 堆内存不能继续扩充,因为已经达到最大值了. 当使用 -XX:+PrintGCDetails 时将会在GC日志中显示 to-space overflow (to-空间溢出)。

这是很昂贵的操作!

GC仍继续所以空间必须被释放.
拷贝失败的对象必须被放到正确的位置(tenured in place).
CSet指向区域中的任何 RSets 更新都必须重新生成(regenerated).
所有这些步骤都是代价高昂的.
如何避免转移失败(Evacuation Failure)

要避免避免转移失败, 考虑采纳下列选项.

增加堆内存大小
增加 -XX:G1ReservePercent=n, 其默认值是 10.
G1创建了一个假天花板(false ceiling),在需要更大 'to-space' 的情况下会尝试从保留内存获取(leave the reserve memory free).
更早启动标记周期(marking cycle)
通过采用 -XX:ConcGCThreads=n 选项增加标记线程(marking threads)的数量.

```

#### JVM设置参数
[jvm设置参数](http://www.cnblogs.com/redcreen/archive/2011/05/04/2037057.html)

