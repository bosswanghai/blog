# vagrant
### 简介
Provider：供应商，在这里指Vagrant调用的虚拟化工具

Box：可被Vagrant直接使用的虚拟机镜像文件，大小根据内容的不同从200M-2G不等。vagrant有专门的box维护社区

Vagrantfile：Vagrant根据Vagrantfile中的配置来创建虚拟机，是Vagrant的核心。在Vagrantfile文件中你需要指明使用哪个Box（可以下载好的或自己制作，或指定在线的URL地址），虚拟机使用的内存大小和CPU，需要预安装哪些软件，虚拟机的网络配置，与host的共享目录等。

Provisioner：是Vagrant的插件的一种。

Guest Additions：这个是常在下载 base box 介绍里有的，一般用来实现host到vm的端口转发、目录共享，在开发环境上都建议装上以便测试。



### vagrant和docker比较

vagrant更适合管理虚拟机，docker更适合快速开发和部署应用程序

vagrant有良好的跨平台性，docker只能用在Linux下，如果要在mac下使用需要下载Linux  vm

### 安装

下载 virtualbox

下载[vagrant](http://downloads.vagrantup.com/)

下载系统镜像

```
$ vagrant init hashicorp/precise64
$ vagrant up
```
或者
先下载好镜像http://files.vagrantup.com/precise64.box

在启动的时候再进行指定$ vagrant box add ubuntu12_04 ~/Download/precise64.box

### 开发

- 初始化开发环境

```
$ cd ~/vagrant  # 切换目录
$ vagrant init ubuntu12_04  # 初始化,不加ubuntu12_04也可以，默认指定当前目录的Vagrantfile

```

执行init后会在当前目录下生成Vagrantfile文件，可以对vagrant进行相关配置

```
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu_12_04" #定义此虚拟机是从哪个box生成,名字就是我们box add时的名字
  config.vm.network "private_network", ip: "192.168.110.100" #私有网络配置
  config.vm.synced_folder ".", "/vagrant"  # 将当前目录映射到虚拟机上的/vagrant 目录
  #awesome configuration goes here...
end
```

- 启动

```
vagrant up # 启动环境

$ vagrant ssh  # SSH 登录
```

- 重启

```
vagrant reload

```

- 退出

```
CTRL+D
```

- 关闭

```
vagrant suspend
将虚拟机挂起，虚拟机内存都保存到硬盘上，下次可以快速恢复。
vagrant halt
将虚拟机关闭，虚拟机内存释放，下次启动要慢一点。
vagrant destroy
将虚拟机删除，所有变更都丢失，下次启动要重新克隆一个 Vagrant box。
无论那种方式关闭，要再启动 Vagrant 都是用 vagrant up 命令。

```



### 高级特性

- 文件夹共享

**当前主目录和虚拟机中的/vagrant目录是共享的**

- 插件功能

```
INSTALLING APACHE

** bootstrap.sh
#!/usr/bin/env bash

apt-get update
apt-get install -y apache2
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

** Vagrant
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/precise64"
  config.vm.provision :shell, path: "bootstrap.sh"
end
```

- 网络配置

```
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/precise64"
  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.network :forwarded_port, guest: 80, host: 4567
end

```
- shard功能

- MULTI-MACHINE

在同一个vagrant中配置多个machine

```
Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: "echo Hello"

  config.vm.define "web" do |web|
    web.vm.box = "apache"
  end

  config.vm.define "db" do |db|
    db.vm.box = "mysql"
  end
end
```

- 安装Virtualbox Guest Additions

[包括剪贴板共享等功能](http://www.crifan.com/virtualbox_guest_addtions_vs_extension_pack/)

```
安装方法可以有 vagrant-vbguest（注意这是vagrant插件，不是virtualbox插件），使用超级详细，只需执行vagrant plugin install vagrant-vbguest，默认从本地找 VBoxGuestAdditions.iso （各平台路径一般都可以找到），如果没找到则去http://download.virtualbox.org/virtualbox/%{version}/VBoxGuestAdditions_%{version}.iso 下载，直接启动vm便可安装或更新virtualbox guest additions ，甚至可以通过vagrant vbguest命令给正在运行的vm安装，缺点是 plugin install 得连网。
```

### 虚拟机管理

```
vagrant package --output NAME --vagrantfile FILE
可选参数：
--output NAME ： （可选）设置通过NAME来指定输出的文件名
--vagrantfile FILE：（可选）可以将Vagrantfile直接封进box中
```


