# Fabric

### fabric是什么

Fabric 是一个 Python (2.5-2.7) 的库和命令行工具，用来提高基于 SSH 的应用部署和系统管理效率。

### fabric安装

pip install fabric

### fabric使用

##### 运行文件

fab默认执行当前目录的fabfile.py文件，fabfile.py由自己编写生成。

`fabfile.py`

def hello():
    print("Hello world!")
    
fab hello

指定其他文件名

fab -f othername.py hello

##### 常用命令

from fabric.api import *


`带参数执行`

fab hello:value=11,name=22

def hello(name, value):
    print name, value
    
    
`任务执行过程`

```

定义 fabfile 任务，并用 fab 执行；

用 local 调用本地 shell 命令；

通过 settings 修改 env 变量；

处理失败命令、提示用户、手动取消任务；

以及定义主机列表、使用 run 来执行远程命令
```

* 用 local 调用本地 shell 命令

```
  lcd("dir")
  local("shell command")
  是在dir下执行shell command
  !=
  local("cd dir")
  local("shell command")
  是在当前目录执行shell command
  

```

* 通过 settings 修改 env 变量

  env.hosts=['user@ip:port', 'user2@ip2:port2'] #ssh要用到的参数

  env.password = 'pwd'

* 处理失败命令、提示用户、手动取消任务

  from fabric.contrib.console import confirm

  def test(name, value):
    with settings(warn_only=True):
        result=local("abcd")
    if result.failed and not confirm("Tests failed. Continue anyway?"):
        abort("Aborting at user request.")

  
* 以及定义主机列表、使用 run 来执行远程命令

```
  with cd("dir"):  # remote: cd dir  
     run("remote shell command")
  进入dir并且执行remote shell command
  
  cd("dir")
  run("remote shell command")
  最终是在remote: ~目录下执行remote shell command
  <==>
  run("cd dir")
  run("remote shell command")
  
  
```

##### 多服务器混搭

```

-#操作一致的服务器可以放在一组，同一组的执行同一套操作
env.roledefs = {
            'testserver': ['user1@host1:port1',],
            'realserver': ['user2@host2:port2', ]
            }

-#env.password = '这里不要用这种配置了，不可能要求密码都一致的，明文编写也不合适。打通所有ssh就行了'

@roles('testserver')
def task1():
    run('ls -l | wc -l')

@roles('realserver')
def task2():
    run('ls ~/temp/ | wc -l')

def dotask():
    execute(task1)
    execute(task2)
```

在程序执行的时候，提示输入密码


##### 扩展

* 颜色

```
from fabric.colors import *
from fabric.api import *

def show():
    print green("hello")

```

* 批量密码管理

```
env.hosts = [
        'host1',
        'host2'
]
-# 注意: 要使env.passwords生效, host格式必须是  user@ip:port 端口号一定要显式写出来,即使是使用的默认22端口
env.passwords = {
    'host1': "pwdofhost1",
    'host2': "pwdofhost2",
}

或者
env.roledefs = {
'testserver': ['host1:22', 'host2:22'],
'realserver': ['host3:22', ]
}
-# 注意: 要使env.passwords生效, host格式必须是  user@ip:port 端口号一定要显式写出来,即使是使用的默认22端口
env.passwords = {
    'host1:22': "pwdofhost1",
    'host2:22': "pwdofhost2",
    'host3:22': "pwdofhost3",
}

```





