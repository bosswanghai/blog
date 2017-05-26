# docker

### docker是什么
在 LXC 的基础上 Docker 进行了进一步的封装，让用户不需要去关心容器的管理，
使得操作更为简便。用户操作 Docker 的容器就像操作一个快速轻量级的虚拟机一
样简单。

### 为什么用docker
更快速的交付和部署

更高效的虚拟化

Docker 容器的运行不需要额外的 hypervisor 支持，它是内核级的虚拟化，因此可
以实现更高的性能和效率。


更轻松的迁移和扩展

更简单的管理


### docker概念

镜像 image

容器 container

仓库 repository


* 镜像

Docker 镜像（Image）就是一个只读的模板。

一个镜像可以包含一个完整的 ubuntu 操作系统环境，里面安装好了需要的应用

Docker 提供了一个很简单的机制来创建镜像或者更新现有的镜像，用户甚至可以
直接从其他人那里下载一个已经做好的镜像来直接使用。

* 容器

Docker 利用容器（Container）来运行应用

容器是从镜像创建的运行实例。它可以被启动、开始、停止、删除。每个容器都是
相互隔离的、保证安全的平台。

`注：镜像是只读的，容器在启动的时候创建一层可写层作为最上层。`

* 仓库

仓库（Repository）是集中存放镜像文件的场所。

仓库分为公开仓库（Public）和私有仓库（Private）两种形式。

仓库存放镜像，镜像有tag


### docker安装

### docker使用

##### 镜像获取

docker pull

```
官网下载
下面的例子将从 Docker Hub 仓库下载一个 Ubuntu 12.04 操作系统的镜像。
sudo docker pull ubuntu:12.04

该命令实际上相当于 $ sudo docker pull
registry.hub.docker.com/ubuntu:12.04

```

```
从其他仓库下载。 从其它仓库下载时需要指定完整的仓库注册服务器地址
sudo docker pull dl.dockerpool.com:5000/ubuntu:12.04

```

##### 使用镜像

如创建一个容器，让其中运行 bash 应用

$ sudo docker run -t -i ubuntu:12.04 /bin/bash

root@fe7fc4bd8fc9:/#

##### 镜像查询

```
root@tom-All-Series:~# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
heka                latest              2d4299d3cd6b        16 hours ago        237.7 MB
hello-world         latest              c54a2cc56cbb        12 weeks ago        1.848 kB

来自于哪个仓库，比如 ubuntu
镜像的标记，比如 14.04
它的 ID 号（唯一）
创建时间
镜像大小

```

##### 创建镜像

* 修改已有镜像

docker commit -m -a container_id tag

* 利用 Dockerfile 来创建镜像

```

新建一个目录和一个 Dockerfile
$ mkdir sinatra
$ cd sinatra
$ touch Dockerfile
Dockerfile 中每一条指令都创建镜像的一层，例如：
 # This is a comment
FROM ubuntu:14.04
MAINTAINER Docker Newbee <newbee@docker.com>
RUN apt-get -qq update
RUN apt-get -qqy install ruby ruby-dev
RUN gem install sinatra

Dockerfile 基本的语法是
使用 # 来注释
FROM 指令告诉 Docker 使用哪个镜像作为基础
接着是维护者的信息
RUN 开头的指令会在创建中运行，比如安装一个软件包，在这里使用 apt-get
来安装了一些软件
编写完成 Dockerfile 后可以使用 docker build 来生成镜像。
sudo docker build -t="ouruser/sinatra:v2" .

-t 标记来添加 tag，指定新的镜像的用户信息。 “.” 是 Dockerfile 所在的路
径（当前目录），也可以替换为一个具体的 Dockerfile 的路径


```


`注意一个镜像不能超过 127 层`

* 从本地文件系统导入

要从本地文件系统导入一个镜像，可以使用 openvz（容器虚拟化的先锋技术）的
模板来创建.

[openvz 模板下载地址](https://openvz.org/Download/templates/precreated)

sudo cat ubuntu-14.04-x86_64-minimal.tar.gz |docker import - ub
untu:14.04


##### 修改镜像

```
$ sudo docker run -t -i training/sinatra /bin/bash
root@0b2616b0e5a8:/#


在容器中添加 json package(一个 ruby gem)。
root@0b2616b0e5a8:/# gem install json

sudo docker commit -m "Added json gem" -a "Docker Newbee" 0b26
16b0e5a8 ouruser/sinatra:v2

 -m 来指定提交的说明信息，跟我们使用的版本控制工具一样； -a 可以
指定更新的用户信息；之后是用来创建镜像的容器的 ID；最后指定目标镜像的仓库
名和 tag 信息。创建成功后会返回这个镜像的 ID 信息。

```

`容器ID 0b2616b0e5a8`

 docker tag 命令来修改镜像的标签


##### 上传镜像

* docker hub

sudo docker push ouruser/sinatra

##### 保存和加载镜像

保存

docker save

sudo docker save -o ubuntu_14.04.tar ubuntu:14.04

加载

docker load

sudo docker load --input ubuntu_14.04.tar ubuntu:14.04

或者

sudo docker load < ubuntu_14.04.tar

##### 删除镜像

sudo docker rmi training/sinatra

`在删除镜像之前要先用 docker rm 删掉依赖于这个镜像的所有容器`


##### 清理所有未打过标签的本地镜像

sudo docker rmi $(docker images -q -f "dangling=true")

<==>

sudo docker rmi $(docker images --quiet --filter "dangling=true")

##### 镜像实现原理

Docker 使用 Union FS 将这些不同的层结合到一个镜像中去。
通常 Union FS 有两个用途, 一方面可以实现不借助 LVM、RAID 将多个 disk 挂到
同一个目录下,另一个更常用的就是将一个只读的分支和一个可写的分支联合在一
起，Live CD 正是基于此方法可以允许在镜像不变的基础上允许用户在其上进行一
些写操作。 Docker 在 AUFS 上构建的容器也是利用了类似的原理。

#### docker 容器

##### 启动

* 新建并启动
docker run -t -i image

```
当利用 docker run 来创建容器时，Docker 在后台运行的标准操作包括：
检查本地是否存在指定的镜像，不存在就从公有仓库下载
启动
46
利用镜像创建并启动一个容器
分配一个文件系统，并在只读的镜像层外面挂载一层可读写层
从宿主主机配置的网桥接口中桥接一个虚拟接口到容器中去
从地址池配置一个 ip 地址给容器
执行用户指定的应用程序
执行完毕后容器被终止
```

* 启动已经停止的容器

docker start

##### 后台运行

需要让 Docker在后台运行而不是直接把执行命令的结果输出在当前
宿主机下。此时，可以通过添加 -d 参数来实现。

查看 docker ps

##### 查看log

sudo docker logs [container ID or NAMES]

##### 终止容器

* sudo docker stop

查看已经终止的容器 docker ps -a

* 只启动了一个终端的容器，用户通过 exit 命令或 Ctrl+d 来退出终端时，
所创建的容器立刻终止


启动 docker start

重启 docker restart

##### 进入容器

docker attach

```
sudo docker run -idt ubuntu
243c32535da7d142fb0e6df616a3c3ada0b8ab417937c853a9e1c251f499f550
$ sudo docker ps
CONTAINER ID IMAGE COMMAND CREA
TED STATUS PORTS NAMES
243c32535da7 ubuntu:latest "/bin/bash" 18 s
econds ago Up 17 seconds nostalgi
c_hypatia
$sudo docker attach nostalgic_hypatia
root@243c32535da7:/#

```

nsenter

##### 导出和导入容器

* 导出容器

```
$ sudo docker ps -a
CONTAINER ID IMAGE COMMAND CREA
TED STATUS PORTS NA
MES
7691a814370e ubuntu:14.04 "/bin/bash" 36 h
ours ago Exited (0) 21 hours ago te
st
$ sudo docker export 7691a814370e > ubuntu.tar

```

* 导入容器

```
cat ubuntu.tar | sudo docker import - test/ubuntu:v1.0

或者

sudo docker import http://example.com/exampleimage.tgz example/
imagerepo

```


`*注：用户既可以使用 docker load 来导入镜像存储文件到本地镜像库，也可以
使用 docker import 来导入一个容器快照到本地镜像库。这两者的区别在于容
器快照文件将丢弃所有的历史记录和元数据信息（即仅保存容器当时的快照状
态），而镜像存储文件将保存完整记录，体积也要大。此外，从容器快照文件导入
时可以重新指定标签等元数据信息。`

##### 删除容器

sudo docker rm trusting_newton

`如果要删除一个运行中的容器，可以添加 -f 参数。Docker 会发送 SIGKILL
信号给容器`


##### 清理所有处于终止状态的容器

用 docker ps -a 命令可以查看所有已经创建的包括终止状态的容器，如果数量
太多要一个个删除可能会很麻烦，用 docker rm $(docker ps -a -q) 可以全
部清理掉。

`注意：这个命令其实会试图删除所有的包括还在运行中的容器，不过就像上面提过
的 docker rm 默认并不会删除运行中的容器。`

##### 退出容器

```
先按，ctrl+p
再按，ctrl+q
```

### 仓库 Docker Hub

##### login

docker hub注册后可以用docker login命令行登录

##### search

docker search centos

-s N 指定N星以上的评价

docker pull centertos

##### 私有仓库

docker-registry创建私有仓库


