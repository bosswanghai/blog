# SSH端口转发

### ssh功能

* SSH 会自动加密和解密所有 SSH 客户端与服务端之间的网络数据

* 端口转发（tcp tunneling 隧道） 提供相应的加解密功能
	
```
加密 SSH Client 端至 SSH Server 端之间的通讯数据
	
突破防火墙的限制完成一些之前无法建立的 TCP 连接
```


### ssh端口静态转发

* 本地转发


appclient appserver sshclient ssh server

sshclient(A) --> sshserver(C)

A(7001) -- (389)C (假如C只限定允许是用localhost进行访问)

`ssh -L <local port>:<remote host>:<remote port> <SSH hostname>`

A: ssh -L 7001:localhost(C):389 C

```
A建立本地 7001端口到远程： ssh -L 7001:localhost(远程localhost或127.0.0.1):9876 root@10.0.2.116( == -l root 10.0.2.116)

```

* 远程转发

sshclient(c)-->sshclient(A)

`ssh -R <local port>:<remote host>:<remote port> <SSH hostname>`


```
C执行: ssh -R 7001(A):localhost(C):9876(C) bosswanghai@10.0.2.19

相当于从C发起了到A的SSH连接

```

> **不管是本地转发或者远程转发，C的服务端口都是9876是固定的，ssh server端口是22也是固定的**


* 多主机转发

appclient A, appserver B, sshclient C, sshserver D
AC一侧 A->C  || BD一侧 B->D

`sshclient C： ssh -g -L 7001:<B>:9876 <D>`

-g gateway 保证其他主机可以连接到该端口

```
A给D9876端口发消息

curl localhost/rsp -v -x "C:7001"

该命令传递到D执行的最终结果相当于D给自己的9876端口发了个命令
curl localhost/rsp 

```

### ssh端口动态转发

`ssh -D <local port> <SSH Server>`

以多主机转发为例

sshclient c执行： ssh -D 7001 <ssh>	

### 补充

* -N参数  表示连接后不登录到对端shell

* -f参数 表示后台执行

* -o ProxyCommand="connect -H web-proxy.oa.com:8080 %h %p "

加上了-o ProxyCommand="connect -H web-proxy.oa.com:8080 %h %p "这个参数，就让我们的ssh连接建立在了一个http代理上了，这个应用对于在公司内网里面非常实用。

其中ProxyCommand指定了使用connect程序来进行代理。通常还可以使用corkscrew来达到相同的效果。

附connect的安装。

如果你是Ubuntu或者Debain系列的使用

sudo apt-get install connect-proxy

* 断开链接保护

一段时间没法消息：Write failed: Broken pipe

-o ServerAliveInterval=60

让其每隔一段时间就发送一些消息，想服务器说明我还活着，不管关闭了我们的连接


