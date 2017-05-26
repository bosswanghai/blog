# tmux

### 简介

[tmux教程](http://cenalulu.github.io/linux/tmux/)

### 概念

`Session` 一组窗口的集合，通常用来概括同一个任务。session可以有自己的名字便于任务之间的切换。

`Window` 单个可见窗口。Windows有自己的编号，也可以认为和ITerm2中的Tab类似。

`Pane` 窗格，被划分成小块的窗口，类似于Vim中 C-w +v 后的效果。

### Session操作

```
操作	快捷键
查看/切换session	prefix s
离开Session	prefix d
重命名当前Session	prefix $
```

### Window操作

```
新建窗口	prefix c
切换到上一个活动的窗口	prefix space
关闭一个窗口	prefix &
使用窗口号切换	prefix 窗口号


```

### Pane操作

```
切换到下一个窗格	prefix o
查看所有窗格的编号	prefix q
垂直拆分出一个新窗格	prefix “
水平拆分出一个新窗格	prefix %
暂时把一个窗体放到最大	prefix z
```