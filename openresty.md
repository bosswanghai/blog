# openresty

### 参数相关

ngx.var.args  包含了参数的最原始形式，`eg: c=3&d=4`，是可以修改的

ngx.var.arg_c是某个具体的参数，如果存在多个c参数的话，就是一个table，不可以被修改。
当修改完ngx.var.args后，ngx.var.arg_c也会被随之修改。

### 变量

##### 变量生效范围
```
ngx_lua 变量范围
a.进程间
lua_shared_dict
b.进程内
lua中的全局变量
c.请求内
local lua 变量， ngx.ctx

nginx  location匹配命令
  ● 已=开头表示精确匹配
如 A 中只匹配根目录结尾的请求，后面不能带任何字符串。
  ● ^~ 开头表示uri以某个常规字符串开头，不是正则匹配
  ● ~ 开头表示区分大小写的正则匹配;
  ● ~* 开头表示不区分大小写的正则匹配
  ● / 通用匹配, 如果没有其它匹配,任何请求都会匹配到
顺序 no优先级：
(location =) > (location 完整路径) > (location ^~ 路径) > (location ~,~* 正则顺序) > (location 部分起始路径) > (/)
nginx rewrite指令: http://seanlook.com/2015/05/17/nginx-location-rewrite/
last和break区别：  
  location ~ /Print1{
        rewrite ^/(.*) /Print2 last;
        content_by_lua 'ngx.say("print1")';
    }

    location ~ /Print2{
        content_by_lua 'ngx.say("print2")';
    }
---回显  print2

  location ~ /Print1{
        rewrite ^/(.*) /Print2 break;
        content_by_lua 'ngx.say("print1")';
    }

    location ~ /Print2{
        content_by_lua 'ngx.say("print2")';
    }
---回显  print1


  location ~ /Print1{
        rewrite ^/(.*) /Print2;
        content_by_lua 'ngx.say("print1")';
    }

    location ~ /Print2{
        content_by_lua 'ngx.say("print2")';
    }
---回显  print2
```

##### nginx 内置变量
```
1.nginx 变量：
set $a hello;
set $b "$a, $a";
echo $a;
注： 变量是全局可见的，变量的创建和使用是分开的，创建变量是在nginx初始化的阶段，变量的使用是在具体的处理阶段，每一个处理location都会创建一个副本。
set/geo指令不仅有赋值的作用，还有创建变量的作用。如果直接使用变量，可能nginx都无法启动。
nginx变量的生命周期，单独的location或者发生了location内部跳转的地方，比如用echo_exec或者rewrite使用。301和302是利用了浏览器进行外部跳转，不一样。
Nginx 内建变量最常见的用途就是获取关于请求或响应的各种信息：
$uri  $request_uri区别：$uri是去除host外，？之前的部分;$request_uri是包含host和?的部分
$arg_变量群，eg: $arg_name是uri中包含了name的时候，$arg_name是name的未解码的数值。$arg_name可以匹配name或者NAME，Name等
许多内部变量是只读的，比如$uri或者$request_uri等。应当避免对它们的赋值，可能会出现意想不到的后果。
支持改写的变量$args:用来获取当前uri的参数串（?后面的部分），并且可以修改。
proxy_pass http://127.0.0.1:8091/test
Nginx 模块在创建变量时，可以选择是否为变量分配存放值的容器，以及是否自己提供与读写操作相对应的“存取处理程序”。
不是所有的 Nginx 变量都拥有存放值的容器。拥有值容器的变量在 Nginx 核心中被称为“被索引的”（indexed）；反之，则被称为“未索引的”（non-indexed）。
nginx对uri的参数处理不是在读取的时候就进行处理和变量存储，而是当使用了$args_name的时候，才去解析和处理。
map $args $foo
{
    default 0;
    debug 1;
};
用户变量$foo的数值邮nginx内建变量$args来决定。 default是系统默认的，即直接取$foo的时候，$foo为0. 如果将$args设置为debug,则$foo为1（注：对$arg的设置是在uri中，因为map 指令其实是一个比较特殊的例子，因为它可以为用户变量注册“取处理程序”，而且用户可以自己定义这个“取处理程序”的计算规则。而“取处理程序”只有在该用户变量被实际读取时才会执行，这是一种惰性求值）.
请求：
主请求：由http外部发起的，包括echo_exec和rewrite指令。
子请求：由 Nginx 正在处理的请求在 Nginx 内部发起的一种级联请求。“子请求”在外观上很像 HTTP 请求，但实现上却和 HTTP 协议乃至网络通信一点儿关系都没有。它是 Nginx 内部的一种抽象调用，目的是为了方便用户把“主请求”的任务分解为多个较小粒度的“内部请求”，并发或串行地访问多个 location 接口，然后由这些 location 接口通力协作，共同完成整个“主请求”。当然，“子请求”的概念是相对的，任何一个“子请求”也可以再发起更多的“子子请求”，甚至可以玩递归调用（即自己调用自己）。当一个请求发起一个“子请求”的时候，按照 Nginx 的术语，习惯把前者称为后者的“父请求”（parent request）。其执行是按照配置的顺序串行执行。 Nginx 核心在实现“子请求”的时候，就只调用了若干个 C 函数，完全不涉及任何网络或者 UNIX 套接字（socket）通信。我们由此可以看出“子请求”的执行效率是极高的。
eg:echo_location
变量的独立空间，每个请求的location都会创建一个独立的副本空间，继承父请求的或者外来的。

请求对于location跳转后，变量的影响。
一些 Nginx 模块发起的“子请求”却会自动共享其“父请求”的变量值容器，比如ngx_auth_request。
 ngx_echo， ngx_lua，以及 ngx_srcache 在内的许多第三方模块都选择了禁用父子请求间的变量共享
内建变量都作用于当前请求：
 location /main {
        echo "main uri: $uri";
        echo_location /sub;
    }

    location /sub {
        echo "sub uri: $uri";
    }
请求 /main 的结果是
    $ curl 'http://localhost:8080/main'
    main uri: /main
    sub uri: /sub

不幸的是，并非所有的内建变量都作用于当前请求。少数内建变量只作用于“主请求”，比如由标准模块 ngx_http_core 提供的内建变量 $request_method.
 location /main {
        set $var main;
        auth_request /sub;
        echo "main: $var";
    }
由auth_request发起的自请求，会改变var的数值，也就是说实现了父子请求的变量共享。
nginx内建变量：
大部分的内建变量都作用于当前请求，例外情况：
  location /main {
        echo "main method: $request_method";
        echo_location /sub;
    }

    location /sub {
        echo "sub method: $request_method";
    }

总结： 特殊的请求方法：ngx_auth_request或者特殊的内建变量：$request_method对于请求而言，都有特殊的地方。
我们并不能通过标准的 $request_method 变量取得“子请求”的请求方法。为了达到我们最初的目的，我们需要求助于第三方模块 ngx_echo 提供的内建变量 $echo_request_method：
    location /main {
        echo "main method: $echo_request_method";
        echo_location /sub;
    }

    location /sub {
        echo "sub method: $echo_request_method";
    }
如果真如前面那部分读者所担心的，内建变量的值缓存在共享变量的父子请求之间起了作用，这无疑是灾难性的。我们前面在 （五） 中已经看到 ngx_auth_request 模块发起的“子请求”是与其“父请求”共享一套变量的。下面是一个这样的可怕例子：
    map $uri $tag {
        default     0;
        /main       1;
        /sub        2;
    }

    server {
        listen 8080;

        location /main {
            auth_request /sub;
            echo "main tag: $tag";
        }

        location /sub {
            echo "sub tag: $tag";
        }
    }
这里我们使用久违了的 map 指令来把内建变量 $uri 的值映射到用户变量 $tag 上。当 $uri 的值为 /main 时，则赋予 $tag 值 1，当 $uri 取值 /sub 时，则赋予 $tag 值 2，其他情况都赋 0. 接着，我们在 /main 接口中先用 ngx_auth_request 模块的 auth_request 指令发起到 /sub 接口的子请求，然后再输出变量 $tag 的值。而在 /sub 接口中，我们直接输出变量 $tag. 猜猜看，如果我们访问接口 /main，将会得到什么样的输出呢？
    $ curl 'http://localhost:8080/main'
    main tag: 2


执行顺序：
1.不同的nginx模块有不同的执行阶段，最特殊的是content阶段，只能有一个模块。在其他的同一个处理阶段，不同模块的执行顺序不一定。
绝大多数 Nginx 模块在向 content 阶段注册配置指令时，本质上是在当前的 location 配置块中注册所谓的“内容处理程序”（content handler）。每一个 location 只能有一个“内容处理程序”，因此，当在 location 中同时使用多个模块的 content 阶段指令时，只有其中一个模块能成功注册“内容处理程序”。
echo 和content_by_lua不能同时执行。一个location里面可以连续写两个echo，但是一个location里面不能连续写两个content_by_lua
ngx_proxy 模块的 proxy_pass 指令和 echo 指令也不能同时用在一个 location 中
index autoindex只作用于以/结尾的请求。
location / {
        root /var/www/;
    }
location / 中没有使用运行在 content 阶段的模块指令，于是也就没有模块注册这个 location 的“内容处理程序”，处理权便自动落到了在 content 阶段“垫底”的那 3 个静态资源服务模块。首先运行的 ngx_index 和 ngx_autoindex 模块先后看到当前请求的 URI，/index.html 和 /hello.html，并不以 / 结尾，于是直接弃权，将处理权转给了最后运行的 ngx_static 模块。ngx_static 模块根据 root 指令指定的“文档根目录”（document root），分别将请求 URI /index.html 和 /hello.html 映射为文件系统路径 /var/www/index.html 和 /var/www/hello.html，在确认这两个文件存在后，将它们的内容分别作为响应体输出，并自动设置 Content-Type、Content-Length 以及 Last-Modified 等响应头。
Nginx 处理请求的过程一共划分为 11 个阶段，按照执行顺序依次是 post-read、server-rewrite、find-config、rewrite、post-rewrite、preaccess、access、post-access、try-files、content 以及 log.
最先执行的 post-read 阶段在 Nginx 读取并解析完请求头（request headers）之后就立即开始运行。
post-read 阶段之后便是 server-rewrite 阶段。
配置语句 set $a hello 直接写在了 server 配置块中，因此它就运行在 server-rewrite 阶段。而 server-rewrite 阶段要早于 rewrite 阶段运行，因此写在 location 配置块中的语句 set $b "$a, world" 便晚于外面的 set $a hello 语句运行。
紧接在 server-rewrite 阶段后边的是 find-config 阶段。这个阶段并不支持 Nginx 模块注册处理程序，而是由 Nginx 核心来完成当前请求与 location 配置块之间的配对工作。换句话说，在此阶段之前，请求并没有与任何 location 配置块相关联。因此，对于运行在 find-config 阶段之前的post-read 和 server-rewrite 阶段来说，只有 server 配置块以及更外层作用域中的配置指令才会起作用。这就是为什么只有写在 server 配置块中的 ngx_rewrite 模块的指令才会运行在 server-rewrite 阶段，这也是为什么前面所有例子中的 ngx_realip 模块的指令也都特意写在了 server 配置块中，以确保其注册在 post-read 阶段的处理程序能够生效。
运行在 find-config 阶段之后的便是我们的老朋友 rewrite 阶段。由于 Nginx 已经在 find-config 阶段完成了当前请求与 location 的配对，所以从 rewrite 阶段开始，location 配置块中的指令便可以产生作用。前面已经介绍过，当 ngx_rewrite 模块的指令用于 location 块中时，便是运行在这个rewrite 阶段。另外， ngx_set_misc 模块的指令也是如此，还有 ngx_lua 模块的 set_by_lua 指令和 rewrite_by_lua 指令也不例外。
rewrite 阶段再往后便是所谓的 post-rewrite 阶段。这个阶段也像 find-config 阶段那样不接受 Nginx 模块注册处理程序，而是由 Nginx 核心完成 rewrite 阶段所要求的“内部跳转”操作（如果 rewrite 阶段有此要求的话）。
这里在 location /foo 中通过 rewrite 指令把当前请求的 URI 无条件地改写为 /bar，同时发起一个“内部跳转”，最终跳进了 location /bar 中。这里比较有趣的地方是“内部跳转”的工作原理。“内部跳转”本质上其实就是把当前的请求处理阶段强行倒退到 find-config 阶段，以便重新进行请求 URI 与 location 配置块的配对。比如上例中，运行在 rewrite 阶段的 rewrite 指令就让当前请求的处理阶段倒退回了 find-config 阶段。由于此时当前请求的 URI 已经被 rewrite 指令修改为了 /bar，所以这一次换成了 location /bar 与当前请求相关联，然后再接着从 rewrite 阶段往下执行。
不过这里更有趣的地方是，倒退回 find-config 阶段的动作并不是发生在 rewrite 阶段，而是发生在后面的 post-rewrite 阶段。上例中的 rewrite 指令只是简单地指示 Nginx 有必要在 post-rewrite 阶段发起“内部跳转”。这个设计对于 Nginx 初学者来说，或许显得有些古怪：“为什么不直接在 rewrite 指令执行时立即进行跳转呢？”答案其实很简单，那就是为了在最初匹配的 locat

ion 块中支持多次反复地改写 URI

post-read:  解析完http header
server-rewrite: set $var value;
find-config: 不支持nginx注册处理程序，完成配置中location块于server的配对工作。
rewrite: ngx_set_misc, set_by_lua, rewrite_by_lua
post-write:不接受nginx注册处理程序，完成rewrite的跳转。
preacess: ngx_limit_req 和 ngx_limit_zone 前者可以控制请求的访问频度，而后者可以限制访问的并发度。
access: 用于访问权限的设置
post-access:
try-files: 对于静态访问的文件，依次处理
content: 对http头部做一些处理后，进行跳转
log:


test.lua文件:
调用ngx_lua_module的api接口进行编程
https://github.com/openresty/lua-nginx-module#nginx-api-for-lua

3.request.lua
ngx.var ： nginx 变量，如果要赋值如 ngx.var.b = 2，此变量必须提前声明；另外对于 nginx location 中使用正则捕获的捕获组可以使用 ngx.var [捕获组数字]获取；
ngx.req.get_headers：获取请求头，默认只获取前100，如果想要获取所以可以调用ngx.req.get_headers(0)；获取带中划线的请求头时请使用如 headers.user_agent 这种方式；如果一个请求头有多个值，则返回的是 table；
ngx.req.get_uri_args：获取 url 请求参数，其用法和 get_headers 类似；
ngx.req.get_post_args：获取 post 请求内容体，其用法和 get_headers 类似，但是必须提前调用 ngx.req.read_body() 来读取 body 体（也可以选择在 nginx 配置文件使用lua_need_request_body on;开启读取 body 体，但是官方不推荐）；
ngx.req.raw_header：未解析的请求头字符串；
ngx.req.get_body_data：为解析的请求 body 体内容字符串。
如上方法处理一般的请求基本够用了。另外在读取 post 内容体时根据实际情况设置 client_body_buffer_size 和 client_max_body_size 来保证内容在内存而不是在文件中。

4.response.lua
return ngx.exit(200)  
ngx.header：输出响应头；
ngx.print：输出响应内容体；
ngx.say：通ngx.print，但是会最后输出一个换行符；
ngx.exit：指定状态码退出。
ngx.redirect()没有生效？？？？？？？？？？

5.ngx lua处理阶段：
Nginx 共11个处理阶段，而相应的处理阶段是可以做插入式处理，即可插拔式架构；另外指令可以在 http、server、server if、location、location if 几个范围进行配置：
指令                          所处处理阶段                                       使用范围                              解释
init_by_lua                   loading-config                                    http                                  nginx Master进程加载配置时执行；通常用于初始化全局配置/预加载Lua模块                                 

init_worker_by_lua            starting-worker                              http                                  每个Nginx Worker进程启动时调用的计时器，如果Master进程不允许则只会在init_by_lua之后调用；通常用于定时拉取配置/数据，或者后端服务的健康检查

set_by_lua                    rewrite                                           server,server if,location,location if 设置nginx变量，可以实现复杂的赋值逻辑；此处是阻塞的，Lua代码要做到非常快；   
通过set实现的url跳转控制没有那么灵活，所以把控制的逻辑实现最终交给set_by_lua来实现

rewrite_by_lua                rewrite tail                                      http,server,location,location if           rrewrite阶段处理，可以实现复杂的转发/重定向逻辑；

access_by_lua                 access tail                                      http,server,location,location if           请求访问阶段处理，用于访问控制

content_by_lua                content                                          location，location if                         内容处理器，接收请求处理并输出响应

header_filter_by_lua          output-header-filter                       http，server，location，location if     设置header和cookie

body_filter_by_lua            output-body-filter                           http，server，location，location if     对响应数据进行过滤，比如截断、替换。

log_by_lua                    log                                                   http，server，location，location if     log阶段处理，比如记录访问量/统计平均响应时间


a)init_by_lua
每次 Nginx 重新加载配置时执行，可以用它来完成一些耗时模块的加载，或者初始化一些全局配置；在 Master 进程创建 Worker 进程时，此指令中加载的全局变量会进行 Copy-OnWrite，即会复制到所有全局变量到 Worker 进程。
脚本的声明要放在http中，不能放在server中，因为是一个初始化脚本;
不能加ngx.exit()，还没到退出的时候

b)init_worker_by_lua
用于启动一些定时任务，比如心跳检查，定时拉取服务器配置（主要还是定时器的使用）等等；此处的任务是跟 Worker 进程数量有关系的，比如有2个 Worker 进程那么就会启动两个完全一样的定时任务。
放在http部分进行声明，和init_by_lua一样，是全局性的配置，不需要放在单独的server里面。

c)set_by_lua
设置 nginx 变量，我们用的 set 指令即使配合 if 指令也很难实现负责的赋值逻辑；
语法 set_by_lua_file $var lua_file arg1 arg2...; 在 lua代码中可以实现所有复杂的逻辑，但是要执行速度很快，不要阻塞；该lua在执行的时候会发生阻塞，所以这边的lua脚本效率一定要高。
set_by_lua中不能执行ngx.say()，但是可以执行ngx.log，也就是说不能作为回显的作用

d)rewrite_by_lua
执行内部 URL 重写或者外部重定向，典型的如伪静态化的 URL 重写。其默认执行在 rewrite 处理阶段的最后。
rewrite功能就是，使用nginx提供的全局变量或自己设置的变量，结合正则表达式和标志位实现url重写以及重定向。rewrite只能放在server{},location{},if{}中，并且只能对域名后边的除去传递的参数外的字符串起作用，例如 http://seanlook.com/a/we/index.php?id=1&u=str 只对/a/we/index.php重写。语法rewrite regex replacement [flag];
nginx的rewrite规则参考：

已=开头表示精确匹配
^~ 开头表示uri以某个常规字符串开头，不是正则匹配
~ 开头表示区分大小写的正则匹配;
~* 开头表示不区分大小写的正则匹配
/ 通用匹配, 如果没有其它匹配,任何请求都会匹配到

-f和!-f用来判断是否存在文件
-d和!-d用来判断是否存在目录
-e和!-e用来判断是否存在文件或目录
-x和!-x用来判断文件是否可执行

init：上下文为init_by_lua或init_by_lua_file；
init_worker：上下文为init_worker_by_lua或init_worker_by_lua_file；
ssl_cert：上下文为ssl_certificate_by_lua_block 或 ssl_certificate_by_lua_file；
set：上下文为 set_by_lua或 set_by_lua_file；
rewrite：上下文为rewrite_by_lua 或 rewrite_by_lua_file；
balancer：上下文为balancer_by_lua_block或 balancer_by_lua_file；
access：上下文为access_by_lua 或 access_by_lua_file；
content：上下文为content_by_lua或 content_by_lua_file；
header_filter：上下文为body_filter_by_lua或 body_filter_by_lua_file；
body_filter：上下文为log_by_lua或log_by_lua_file；
log：上下文为log_by_lua或 log_by_lua_file；
timer：上下文为使用ngx.timer的回调函数；


e)利用nginx搭建文件服务器
http://www.centoscn.com/nginx/2015/0128/4578.html

/home/html/abc的使用
alias和root区别
location /abc/ {
    alias /home/html/abc/;
}
location /abc/ {
    root /home/html/;
}

nginx流量复制：
1.tcpcopy
2.httpluamodule
eg:根据cookie进行不同的流量分发：
a)可以用map实现 b)可以手动获取cookie数值，然后进行分发
eg:进行流量复制：
在lua中进行串行复制
用ngx.location.capture_multi
用协程实现：ngx.thread.spawn

nginx upstream引流：
在http节点下，添加upstream节点
在location下添加proxy_pass，这样upstream会引流到节点下。

@表示重定向
error_page 404 = @redirection

local @redirection{
    content_by_lua_file xxxx;
    http_proxy http://back_end/xxxx
    http_proxy http://xxx.com/error.html
}

rewrite详细解释：
1.http://nginx.org/en/docs/http/ngx_http_rewrite_module.html
rewrite regex replacement [flag];
[flag]
last:表示继续需找Location进行重定向;
break:停止处于同一作用域的后续代码的执行;
redirect：302重定向，前提是replacement不是以http://和https://开头;
permanent：301永久定向。
301和302都对于用户来说，表现是一样的，都相当于浏览器发生两次跳转。对于服务端来说，302容易被视为垃圾处理。

rewite不能只针对uri生效，不包括域名和http参数
location /download/（带download和不带download是有区别的，带download只能用break,而不能用last） {
    rewrite ^(/download/.*)/media/(.*)\..*$ $1/mp3/$2.mp3 break;
    rewrite ^(/download/.*)/audio/(.*)\..*$ $1/mp3/$2.ra  break;
    return  403;
}
格式：只对uri部分生效
rewrite regex replacement [flag];
如果其中某步URI被重写，则重新循环执行1-3，直到找到真实存在的文件；循环超过10次，则返回500 Internal Server Error错误。
last : 相当于Apache的[L]标记，表示完成rewrite
break : 停止执行当前虚拟主机的后续rewrite指令集
redirect : 返回302临时重定向，地址栏会显示跳转后的地址
permanent : 返回301永久重定向，地址栏会显示跳转后的地址
因为301和302不能简单的只返回状态码，还必须有重定向的URL，这就是return指令无法返回301,302的原因了。这里 last 和 break 区别有点难以理解：
last一般写在server和if中，而break一般使用在location中
last不终止重写后的url匹配，即新的url会再从server走一遍匹配流程，而break终止重写后的匹配
break和last都能组织继续执行后面的rewrite指令
break和last只在location中有区别，break表示跳转后还在本location的作用域，last表示发生了新的跳转匹配。


```

### nginx misc

```
nginx子请求： 包括ngx.location.capture(uri)，都是从 server rewrite phase 开始执行起的，同时会跳过 access phase.


```

### 调试
##### nginx 调试
[nginx coredump](https://github.com/y123456yz/reading-code-of-nginx-1.9.2/blob/master/nginx-1.9.2/nginx-coredump%E6%96%87%E4%BB%B6%E8%B0%83%E8%AF%95%E6%8A%80%E5%B7%A7.c)

##### nginx lua 调试

```
1.watch命令可以查看内存，监控全局变量的内存信息会更好一些：
watch *(ngx_shm_zone_init_pt *)0xXXXXX

2.宏定义
info macro MAC_NAME
p MAC_NAME
如果要调试宏，需要将-g选项更改为--ggdb3，得到的编译文件会比较大。
如果运行到main，info macro MAC_NAME无法显示，可以先list宏的文件位置再去查询。原因是gdb将当前代码列表作为一个作用域。r

3.cgdb

4.strace/pstack
strace:  -p pid / -o filename / -f 跟踪其通过fork产生的子进程/ -t 系统调用的发起时间/ -T 系统调用的消耗时间
pstack 进程号： 查看函数调用堆的关系

5.获得nginx程序执行的完整流程：
方法很多： system tap/ gcc -finstrument- functions 提供函数调用追踪记录功能。  其他方法？？

将地址转换为函数名： addr2line -e a -a 0x400566

6.打桩测试：
对于slab机制，直接观看不明显，打桩测试然后再gdb跟踪

7.特殊应用逻辑的调试：
对于IE/火狐发出请求的行为已经固定； 对于构造curl/wget的源码定制比较困难；
解决方法：自己写socket通信的客户端。

8. lua调试
http://wiki.jikexueyuan.com/project/lua/debugging.html
```

##### openresty lua调试
```
1.lua脚本调试：
A用zerobrane:
进行本地测试：
A配置环境变量
export ZBS=/opt/zbstudio
export LUA_PATH="./?.lua;$ZBS/lualibs/?/?.lua;$ZBS/lualibs/?.lua"
export LUA_CPATH="$ZBS/bin/linux/x64/?.dll;$ZBS/bin/linux/x64/clibs/?.dll"

/opt/zbstudio/lualibs/?/?.lua;/opt/zbstudio/lualibs/?.luac
/opt/zbstudio/bin/linux/x64/?.dll;/opt/zbstudio/bin/linux/x64/clibs/?.dll
用zerobrane加载lua后启动即可。

B openresty lua调试
修改nginx.conf文件
    lua_package_path "$prefix/app/lib/?.lua;$prefix/app/etc/?.lua;$prefix/app/src/?.lua;$prefix/../luajit/share/lua/5.1/?.lua;/opt/zbstudio/lualibs/?/?.lua;/opt/zbstudio/lualibs/?.lua;";
    lua_package_cpath "$prefix/app/lib/?.so;$prefix/../luajit/lib/lua/5.1/?.so;/opt/zbstudio/bin/linux/x64/?.so;/opt/zbstudio/bin/linux/x64/clibs/?.so;";
在脚本中增加如下配置：
require('mobdebug').start('127.0.0.1')
require('mobdebug').done()
启动远程ie进行调试：
起动IDE，执行调试。
我们IDE菜单上的project-> project directory-> choose选择打开，我们这个工程的目录，
选set from current file, 把工程中的test.lua作为当前要处理的文件。
下面关键的一点，在project 菜单里，一定要点选 "Start Debugger Server"。

B用lua debug进行调试

nginx调试方法，在编译的时候打开debug选项
http://blog.sina.com.cn/s/blog_6d579ff40100xm7t.html


2. 在构造 OpenResty 时，启用其 ./configure 脚本的 --with-debug 选项，此时会开启 LuaJIT 
的断言检查和 API 检查。 

3. 配置 nginx 生成 core dump 文件（见文档 
http://wiki.nginx.org/Debugging#Core_dump ），这样你可以在 nginx worker 崩溃时得到 
core dump 文件。然后你可以使用 gdb 对此 core dump 进行分析，比如使用 bt full 命令得到崩溃位置上完整的 C 
调用栈轨迹。也可以使用我们的 nginx gdb utils 项目中的工具从 core dump 
得到更多的信息：https://github.com/openresty/nginx-gdb-utils#readme 特别是其中的 
lbt、lgc、lgcstat、lvmst 这些gdb 扩展命令。 

4. 检查你使用的 OpenResty 以外的 Lua C 模块或者使用了使用了 LuaJIT FFI 的 Lua 模块（即 Lua 
库），以及是否使用了 OpenResty 以外的 NGINX C 模块。这些我们未测试过的 Lua 库或者 NGINX 
模块可能会引入我们无法控制的内存问题。 

5. 尝试使用 Valgrind memcheck 工具运行你的 nginx 
应用，检查是否有内存问题。在此运行模式下，建议使用下面的命令构造 OpenResty: 

     ./configure --with-debug --with-no-pool-patch \ 
           --with-luajit-xcflags='-DLUAJIT_USE_SYSMALLOC -DLUAJIT_USE_VALGRIND' 

然后在 valgrind 运行模式下，在 nginx.conf 中作如下配置： 

    worker_processes  1; 
    daemon off; 
    master_process off; 

在用 valgrind 启动 nginx 以后，再用你的测试请求不断访问 nginx，直到 valgrind 产生错误报告。 

> 我用的是openresty-1.4.3.6  + ngx_lua-0.9.7 版本 
>
```

