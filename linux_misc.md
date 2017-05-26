# Linux misc

##### linux kernerl

```
dmesg/varlog
电源温度过高
```

```
什么是Oops？从语言学的角度说，Oops应该是一个拟声词。当出了点小事故，或者做了比较尴尬的事之后，你可以说"Oops"，翻译成中国话就叫做“哎呦”。“哎呦，对不起，对不起，我真不是故意打碎您的杯子的”。看，Oops就是这个意思。在Linux内核开发中的Oops是什么呢？其实，它和上面的解释也没什么本质的差别，只不过说话的主角变成了Linux。当某些比较致命的问题出现时，我们的Linux内核也会抱歉的对我们说：“哎呦（Oops），对不起，我把事情搞砸了”。Linux内核在发生kernel panic时会打印出Oops信息，把目前的寄存器状态、堆栈内容、以及完整的Call trace都show给我们看，这样就可以帮助我们定位错误。
```

##### watch

可以将命令的输出结果输出到标准输出设备，多用于周期性执行命令/定时执行命令


```
-n或--interval  watch缺省每2秒运行一下程序，可以用-n或-interval来指定间隔的时间。
-d或--differences  用-d或--differences 选项watch 会高亮显示变化的区域。 而-d=cumulative选项会把变动过的地方(不管最近的那次有没有变动)都高亮显示出来。
-t 或-no-title  会关闭watch命令在顶部的时间间隔,命令，当前时间的输出。
```

## 调优

### 内核参数设置

sysctl

```
-n：打印值时不打印关键字； 
-e：忽略未知关键字错误； 
-N：仅打印名称； 
-w：当改变sysctl设置时使用此项； 
-p：从配置文件“/etc/sysctl.conf”加载内核参数设置； 
-a：打印当前所有可用的内核参数变量和值； 
-A：以表格方式打印当前所有可用的内核参数变量和值。

```

查看正在运行的系统参数
sysctl -a

从/etc/sysctl.conf加载配置
sysctl -p

动态设定参数

sysctl vm.swappiness=10
 

### 内存调优

内存如果不够用，可以查看系统log，或者

```
[root@ES-ZJ-LNA-030 ~]# free -h
             total       used       free     shared    buffers     cached
Mem:           23G        23G       105M       648K       6.2M        12G
-/+ buffers/cache:        10G        12G
Swap:         7.8G        42M       7.8G
```

解释

```
T[1][1] = total
T[1][2] = 程序实际使用 + cached
T[2][1] = T[1][2] - cached = 程序实际使用
T[2][2] = free + cached
```

cached 读操作使用的缓冲区
buffers 写操作使用的缓冲区

cached使用情况查看
slabtop

降低cached使用上限

1.cron手动释放

```
sync; echo 3 > /proc/sys/vm/drop_caches

```

2.降低swap使用比例

设置vm.swappiness=0 后并不代表禁用swap分区，只是告诉内核，能少用到swap分区就尽量少用到，设置vm.swappiness=100的话，则表示尽量使用swap分区，默认的值是60


```
 sysctl vm.swappiness=10
 sysctl vm.dirty_ratio=1
 sysctl vm.dirty_background_ratio=1
 sysctl vm.drop_caches=3

 或者修改/etc/sysctl.conf
 echo "vm.swappiness=10" >> /etc/sysctl.conf
 sysctl -p
 
```

3.关闭cache

[vm参数介绍](http://skyou.blog.51cto.com/2915693/558461)

```
修改/etc/sysctl.conf 添加如下选项后就不会内存持续增加
vm.dirty_ratio = 1
vm.dirty_background_ratio=1
vm.drop_caches=3
vm.swappiness =10

vm.dirty_writeback_centisecs=2
vm.dirty_expire_centisecs=3
vm.vfs_cache_pressure=163
vm.overcommit_memory=2
vm.lowmem_reserve_ratio=32 32 8
kern.maxvnodes=3

上面的设置比较粗暴，使cache的作用基本无法发挥。需要根据机器的状况进行适当的调节寻找最佳的折衷。
```

[doc](https://raj2796.wordpress.com/2009/11/09/reducing-cached-memory-usage-linux-high-memory-usage-diagnosing-and-troubleshooting-on-vmware-and-out-of-memory-oom-killer-problem-and-solution/)

[good doc2](http://www.myjishu.com/?p=80)


