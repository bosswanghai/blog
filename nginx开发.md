# Nginx开发

## nginx体系架构

## nginx 模块调用原理



### 编译
通过./configure --help可以查看编译选项，为了增加gdb调试信息，使用./configure --with-cc-opt='-g -o0'和make CFLAGS="-g -o0"

configure是个shell脚本，按顺序调用如下文件
auto/options，编译配置选型
auto/init  初始化文件编译生成路径，包括Makefile和objs/ngx_modules.c，ngx_modules.c是根据模块动态生成的，保存一个ngx模块结构体和ngx名字结构体，目的是为了把所有的自定义模块动态的编译进去。
auto/sources ngx源码文件


### 调试

- gdb调试
- systemtap+flame graph打印执行流程

[systemtap+flame graph使用](http://xuclv.blog.51cto.com/5503169/1184517)

## nginx 模块开发


### hellow 指令模块
目的： 在ngx.conf中新增一条hello指令，可以打印配置中的回显，该模块属于http模块，指令在content阶段生效。

```
        location /hello_world {
            hello_world haha;
        }
```

实现：
配置文件修改
auto/options中增加

```
HTTP_HELLO_WORLD=YES
在if [ $HTTP = NO ]; then中添加
HTTP_HELLO_WORLD=NO
```

auto/modules中增加

```
if [ $HTTP_HELLO_WORLD = YES ]; then
    ngx_module_name=ngx_http_hello_world_module
    ngx_module_incs=
    ngx_module_deps=
    ngx_module_srcs=src/http/modules/ngx_http_hello_world_module.c
    ngx_module_libs=
    ngx_module_link=$HTTP_HELLO_WORLD

    . auto/module
fi

```

c文件位置src/http/modules/ngx_http_hello_world_module.c

文件内容
```


```


