## hindsight简介

用来代替heka的，heka有一些天然缺陷，比如cpu利用率不达标，日志可能丢失等。

## 安装

依赖

```
Clang 3.1 or GCC 4.7+
CMake (3.0+) - http://cmake.org/cmake/resources/software.html
lua_sandbox (1.1+) - https://github.com/mozilla-services/lua_sandbox
hindsight中使用的lua函数接口由lua_sandbox实现，如果要安装hindsight，则必须要安装lua_sandbox

```

```
git clone https://github.com/mozilla-services/hindsight.git
cd hindsight
mkdir release
cd release

# Linux
cmake -DCMAKE_BUILD_TYPE=release ..
cmake -DCMAKE_BUILD_TYPE=debug ..  ## 调试模式
make
ctest
cpack -G TGZ # (DEB|RPM|ZIP)

# Cross platform support is planned but not supported yet

```

lua_sandbox_extensions 安装
```
- 修改CMakeLists.txt，去掉不相关的依赖组建
- kafka老版本中的一些头文件不在其中，升级后的版本存放位置， https://github.com/edenhill/librdkafka.git

make install 后的默认位置
/usr/local/share/heka/lua_modules/

```

将lua_sandbox和hindsight安装后，将lua_sandbox.zip解压到指定目录，同时将设置so依赖路径
export LD_LIBRARY_PATH=/opt/job/hindsight/luasandbox-1.2.4-Linux/lib/

禁用掉不相关的lua_sandbox_extensions组件，如postgres,systemd

systemd作用

## 使用

https://github.com/mozilla-services/hindsight.git

https://github.com/mozilla-services/lua_sandbox.git

https://github.com/mozilla-services/lua_sandbox_extensions.git

## hindsight.cfg配置
cfg配置文件本质是一个lua文件
```
output_path             = "output"
output_size             = 64 * 1024 * 1024
sandbox_load_path       = "load"
sandbox_run_path        = "run"
sandbox_install_path    = "/app/usr/share/luasandbox/sandboxes/heka"
analysis_threads        = 1
analysis_lua_path       = "/app/lib/luasandbox/modules/?.lua"
analysis_lua_cpath      = "/app/lib/luasandbox/modules/?.so"
io_lua_path             = analysis_lua_path .. ";/app/lib/luasandbox/io_modules/?.lua"
io_lua_cpath            = analysis_lua_cpath .. ";/app/lib/luasandbox/io_modules/?.so"
max_message_size        = 64 * 1024
backpressure            = 0
backpressure_disk_free  = 4

input_defaults = {
  -- see: Default Sandbox Configuration Variables
  -- output_limit           = 64 * 1024
  -- memory_limit           = 8 * 1024 * 1024
  -- instruction_limit      = 1e6
  -- preserve_data          = false
  -- restricted_headers     = false
  -- ticker_interval        = 0
  -- shutdown_on_terminate  = false
}

analysis_defaults = {
  -- see: Default Sandbox Configuration Variables
}

output_defaults = {
  -- see: Default Sandbox Configuration Variables
  -- remove_checkpoints_on_terminate = false
  -- read_queue = "both"
}

```

组建默认安装路径如下，不推荐。

```
-- hindsight安装到了如下目录
/usr/local/bin/hindsight
/usr/local/share/luasandbox/sandboxes

-- lua_sandbox 安装到了如下目录，分别是提供lua_sandbox相关的头文件和依赖的so
/usr/local/share/luasandbox
/usr/local/include/luasandbox
/usr/local/lib

-- lua_sanbox_extensions安装到了如下目录，分别是
/share/luasandbox/sandboxes/heka
/lib/luasandbox/modules
/lib/luasandbox/io_modules

```

推荐 在生成文件的时候，使用tar打包后，放到指定目录。


### hindsight 运行过程

运行过程概述

```
hindsight 最初加载所有的input/output/analysis模块，而后监控load路径中的配置数据，如果添加了新的配置，
则不需要重启Hindsight，会直接将改文件拷贝到run目录下的对应模块，进行动态加载，也可以对已有模块进行替换。

inotify监控文件句柄，监视句柄变化
启动input/analysis/output模块，各个阶段都可以包含多个plugin，每个plugin作为一个独立的线程运行

动态load模块
while(true){
    监视句柄变化，处理动态加载的配置
}

处理句柄变化阶段，有两种方式：
1.根据配置文件直接处理
2.根据lua插件进行处理

根据lua插件进行处理，需要调用lua_sandbox，设置为黑盒环境，调用lua文件中的process_message()进行处理，
process_message是可以包含参数的

```


内部消息传递
```
input模块将多个输入源的消息处理后，最终产生统一的消息格式存放在output/input/*log

各个analysis模块将各个input模块产生消息分别放在output/analysis/*log中进行存放

output会将output/input(analysis)/*log的内部数据经过处理后，输出到对应的外部存储、文件等，产生的目录根据配置文件配置的output_dir产生

内部消息的读取是通过checkpoint{id=文件名, offset=文件量}来控制读取的位置，checkpoint在实现的时候作为一个公用变量，input/output plugins
通过加锁来保证一致性。
hindsight被干掉后，再次启动保证读的一致性，是通过output/hindsight.cp来保证的
_G['analysis->output.heka_debug'] = '0:3914184'  output.heka_debug组建读取analysis的进度
_G['analysis'] = '0:3914184' analysis模块的进度
_G['input->analysis0'] = '32:27413907'  analysis模块读取input模块的进度
_G['input->output.heka_debug'] = '32:27413907'  output.heka_debug组件产生的读取input模块的进度
_G['input'] = '32:27413907' input模块产生的checkpoint数据



内部消息是以protobuf格式进行传递的

typedef struct lsb_heka_message
{
  lsb_const_string raw;
  lsb_const_string uuid;
  lsb_const_string type;
  lsb_const_string logger;
  lsb_const_string payload;
  lsb_const_string env_version;
  lsb_const_string hostname;
  lsb_heka_field *fields;
  long long timestamp;
  int       severity;
  int       pid;
  int       fields_len;
  int       fields_size;
} lsb_heka_message;

```

heka 消息格式

- heka table message

hash based table message

```
{
Uuid        = "data",               -- auto generated if not a 16 byte raw binary UUID or a 36 character human readable UUID
Logger      = "nginx",              -- defaults to the Logger configuration value but can be overridden with the `restricted_headers` configuration
Hostname    = "example.com",        -- defaults to the Hostname configuration value but can be overridden with the `restricted_headers` configuration
Timestamp   = 1e9,                  -- auto generated if not a number
Type        = "TEST",
Payload     = "Test Payload",
EnvVersion  = "0.8",
Pid         = 1234,
Severity    = 6,
Fields      = {
            http_status     = 200,  -- encoded as a double
            request_size    = {value=1413, value_type=2, representation="B"} -- encoded as an integer
            }
}

```

array based table message

```
{
-- Message headers are the same as above
Fields      = {
            {name="http_status" , value=200}, -- encoded as a double
            {name="request_size", value=1413, value_type=2, representation="B"} -- encoded as an integer
            }
}

```

消息在传递的时候可以放到payload或者fields中进行传递


### lua_sandbox 开发
http://mozilla-services.github.io/lua_sandbox/doxygen/files.html
http://mozilla-services.github.io/lua_sandbox/doxygen/test_2sandbox_8h.html

hindsight devops docker
https://github.com/Securing-DevOps/logging-pipelin://github.com/Securing-DevOps/logging-pipeline

调试
```
lua_sandbox和lua_sandbox_extensions中的各自模块的源码目录下，都会包含各自的test模块，可以利用这点进行调试
开启hindsight debug模式，可以直接看到lua 模块打印的print值

```

lua_sandbox api

[api doc](http://mozilla-services.github.io/lua_sandbox/heka/message.html)

read_message()

process_message()



```
Arguments

variableName (string)
framed (returns the Heka message protobuf string including the framing header)
raw (returns the Heka message protobuf string)
size (returns the size of the raw Heka message protobuf string)
Uuid
Type
Logger
Payload
EnvVersion
Hostname
Timestamp
Severity
Pid
Fields[name]
fieldIndex (unsigned) - only used in combination with the Fields variableName use to retrieve a specific instance of a repeated field name; zero indexed
arrayIndex (unsigned) - only used in combination with the Fields variableName use to retrieve a specific element out of a field containing an array; zero indexed
zeroCopy (bool, optional default false) - returns a userdata place holder for the message variable (only valid for string types). Non string headers throw an error during construction, non string fields throw an error on data retrieval.
Return

value (number, string, bool, nil, userdata depending on the type of variable requested)

```


## 测试

压测
systemtap
valgrind
