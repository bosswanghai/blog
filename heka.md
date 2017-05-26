# heka

## heka简介

logstash强依赖于Java_JDK，出现了heka替代品，由于是由go语言实现，heka性能高，
decoder/filter/encoder阶段采用了sandbox，集合了lua/go插件开发，使得开发效率更高。

## heka安装

[官网](https://github.com/mozilla-services/heka.git)下载后，按照说明安装即可。

```
source build.sh

source env.sh

cd build

make install

```

最终heka的所有内容会安装到当前build目录下，包括heka的bin包和其所使用的sandbox

编译go写的heka插件
在  {heka root}/cmake/plugin_loader.cmake 文件中 ， 通过 add_external_plugin 指定需要参与编译的目录或 git 地址
```
add_external_plugin(git https://github.com/mozilla-services/heka-mozsvc-plugins 6fe574dbd32a21f5d5583608a9d2339925edd2a7)
add_external_plugin(git https://github.com/example/path <tag> util filepath)
add_external_plugin(git https://github.com/bellycard/heka-sns-input :local)
# The ':local' tag is a special case, it copies {heka root}/externals/{plugin_name} into the Go
# work environment every time `make` is run. When local development is complete, and the source
# is checked in, the value can simply be changed to the correct tag to make it 'live'.
# i.e. {heka root}/externals/heka-sns-input -> {heka root}/build/heka/src/github.com/bellycard/heka-sns-input

```
:local标志就是代表从第一步创建的externals目录获取源码，否则就会自动的从此git地址checkout源码来编译，所以插件开发阶段此处应该是:local。

然后重新编译 heka  就可以完成插件的编译

## heka运行

heka 使用Lua sandbox decoder运行会报错误
```
panic: runtime error: cgo argument has Go pointer to Go pointer

解决办法

export GODEBUG=cgocheck=0

```


## heka配置

```
[hekad]
maxprocs = 2
share_dir = "/usr/local/share/heka"

[NewlineSplitter]
type = "TokenSplitter"
delimiter = '\n'

[JsonDecoder]
type = "SandboxDecoder"
filename = "lua_decoders/json.lua"
    [JsonDecoder.config]
    type = "artemis"
    payload_keep = true
    map_fields = true
    Severity = "severity"


[TcpInput]
address = "127.0.0.1:5565"
keep_alive=true
decoder="JsonDecoder"
splitter = "NewlineSplitter"


[PayloadEncoder]

[LogOutput]
message_matcher = "TRUE"
encoder="PayloadEncoder"

```

## heka命令

