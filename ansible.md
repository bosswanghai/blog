# Ansible使用
### 文档
[ansible入门](https://www.gitbook.com/book/ansible-book/ansible-first-book/details)

[ansible详解](https://ansible-book.gitbooks.io/ansible-first-book/content/ansibleyong_jiao_ben_guan_li_zhu_ji.html)

### 原理

1） 将本地的文件复制到远端所有服务器； 2） 需要在远程服务器中执行一个个命令；

### 使用方法

##### copy模块
使用copy模块，可以将本地文件一键复制到远程服务器； -a后跟上参数，参数中指定本地文件和远端路径；

```
ansible myservers -m copy -a "src=/opt/app/bin/transfer.tar dest=~/"
```

**warning**

ansible通过ssh登录到远程服务器后，并不执行.bash_profile来设置用户自定义的环境变量；如果我们需要管理的目标服务器的路径不同，就不能直接写绝对路径，也不能写变量替换的路径；

比如：针对服务器A的目标复制路径为 /opt/app/user1/bin ,服务器B的目标复制路径为/opt/app/user2/bin; 这两个路径在各自的服务器中的路径变量都设置为$bin; 但在copy模块中，我们不能直接使用dest = $bin/； 路径设置一般放在.bashrc /.bash_profile文件，但ansible模块登录后并不加载这两个文件；

解决方法： 针对这种情况，可以将dest路径设置为~/，都复制到用户目录，后续再通过远程脚本处理；

##### 远程命令
远程执行命令的模块有command、shell、scripts、以及raw模块；

`command 模块`

command模块为ansible默认模块，不指定-m参数时，使用的就是command模块；

comand模块比较简单，常见的命令都可以使用，但其命令的执行不是通过shell执行的，所以，像这些 "<", ">", "|", and "&"操作都不可以，当然，也就不支持管道；

```
显示远程路径：

ansible myservers  -a 'pwd'
10.6.143.38 | success | rc=0 >>
/home/rduser
10.6.143.53 | success | rc=0 >>
/home/rduser
10.6.143.37 | success | rc=0 >>
/home/rduser

```

缺点：不支持管道，就没法批量执行命令；


`shell 模块`

如果需要使用自定义的环境变量，就需要在最开始，执行加载自定义脚本的语句；

* 语句较少

```
ansible myservers  -a ". .bash_profile;ps -fe |grep sa_q" -m shell

```

* 语句较多

```
如果在远程待执行的语句比较多，可写成一个脚本，通过copy模块传到远端，然后再执行；但这样就又涉及到两次ansible调用；对于这种需求，ansible已经为我们考虑到了，script模块就是干这事的；

```


`scripts 模块`

使用scripts模块可以在本地写一个脚本，在远程服务器上执行：

```
ansible myservers  -m script -a "/opt/app/target.sh"

```

`执行playbooks`

远程批量命令执行的另外一种方式是用playbooks；


##### playbooks

Playbooks are Ansible’s configuration, deployment, and orchestration language. DSL

playbooks采用yml文件格式配置

* 配置yml文件
> yml一种类似于xml的标签语言，有良好的可读性，和语言的良好交互，使用语言的数据类型，易于实现。  

`格式`

```
模块明: 参数  <==>  -m 模块名  -a "参数名"
```

配置方法
webservers.yml

  name: install nginx
  apt: name=nginx

* ansible任务执行过程

1. 相同任务并发执行
2. 下一个任务执行前会等到所有上一次的任务执行结束后再开始
3. ansible会按照配置任务的顺序来执行

##### python 中使用playbooks
[jinja2模板使用方法](http://xiaorui.cc/2014/11/06/%E5%85%B3%E4%BA%8Eansible%E7%9A%84playbook%E9%85%8D%E7%BD%AE%E5%8F%8Ajinja2%E6%B8%B2%E6%9F%93template%E6%A8%A1%E6%9D%BF/)

```
一般所需的目录层有：(视情况可变化)
  vars     变量层
  tasks    任务层
  handlers 触发条件
  files    文件
  template 模板
  tags 让用户选择运行或者略过playbook中的部分代码

```

task list中的各任务按次序逐个在hosts中指定的所有主机上执行即在所有主机上完成第一个任务后再开始第二个。在运行自下而下某playbook时如果中途发生错误所有已执行任务都将回滚因此在更正playbook后重新执行一次即可。 

```
hosts：为主机的IP，或者主机组名，或者关键字all
remote_user: 以哪个用户身份执行。
vars： 变量
tasks: playbook的核心，定义顺序执行的动作action。每个action调用一个ansbile module。
    action 语法： module： module_parameter=module_value
    常用的module有yum、copy、template等，module在ansible的作用，相当于bash脚本中yum，copy这样的命令。下     	一节会介绍。
handers： 是playbook的event，默认不会执行，在action里触发才会执行。多次触发只执行一次。

```

完整例子，只有一个play

```
- hosts: web
  vars:
    http_port: 80
    max_clients: 200
  remote_user: root
  tasks:
  - name: ensure apache is at the latest version
    yum: pkg=httpd state=latest
  - name: Write the configuration file
    template: src=templates/httpd.conf.j2 dest=/etc/httpd/conf/httpd.conf
    notify:
    - restart apache
  - name: Write the default index.html file
    template: src=templates/index.html.j2 dest=/var/www/html/index.html
  - name: ensure apache is running
    service: name=httpd state=started
  handlers:
     - name: restart apache   #service和name 必须对齐，但是name前的-不需要和handlers对齐
       service: name=httpd state=restarted

```
```
include 拆分tasks，可以给include传递参数

tasks:
  - include: tasks/foo.yml [wp_user=timmy]

tasks/foo.yml中使用变量
{{ wp_user }}

```

```
传递给include 结构化变量
tasks:

  - include: wordpress.yml
    vars:
        wp_user: timmy
        some_list_variable:
          - alpha
          - beta
          - gamma
```

`组织 playbook 最好的方式：使用role`

```
site.yml
webservers.yml
fooservers.yml
roles/
   common/
     files/
     templates/
     tasks/
     handlers/
     vars/
     defaults/
     meta/
   webservers/
     files/
     templates/
     tasks/
     handlers/
     vars/
     defaults/
     meta/

play book的书写如下
 ---
- hosts: webservers
  roles:
    - common  正常role
    - { role: foo_app_instance, dir: '/opt/a',  port: 5000 }  参数化role

如果 roles/x/tasks/main.yml 存在, 其中列出的 tasks 将被添加到 play 中
如果 roles/x/handlers/main.yml 存在, 其中列出的 handlers 将被添加到 play 中
如果 roles/x/vars/main.yml 存在, 其中列出的 variables 将被添加到 play 中
如果 roles/x/meta/main.yml 存在, 其中列出的 “角色依赖” 将被添加到 roles 列表中 (1.3 and later)
所有 copy tasks 可以引用 roles/x/files/ 中的文件，不需要指明文件的路径。
所有 script tasks 可以引用 roles/x/files/ 中的脚本，不需要指明文件的路径。
所有 template tasks 可以引用 roles/x/templates/ 中的文件，不需要指明文件的路径。
所有 include tasks 可以引用 roles/x/tasks/ 中的文件，不需要指明文件的路径。

```

如果你希望定义一些 tasks，让它们在 roles 之前以及之后执行，你可以这样做:

```

- hosts: webservers

  pre_tasks:
    - shell: echo 'hello'

  roles:
    - { role: some_role }

  tasks:
    - shell: echo 'still busy'

  post_tasks:
    - shell: echo 'goodbye'


```

##### tags

play和tasks都支持tags

```
tasks:

    - yum: name={{ item }} state=installed
      with_items:
         - httpd
         - memcached
      tags:
         - packages

    - template: src=templates/src.j2 dest=/etc/foo.conf
      tags:
         - configuration

如果想运行tags或者忽略tags，则可以这样使用
ansible-playbook example.yml --tags "configuration,packages"
ansible-playbook example.yml --skip-tags "notification"


```


##### vars


`普通变量定义`

```
- hosts: webservers
  vars:
    http_port: 80
    
使用的时候{{ http_port }}
```

`读取主机变量`

```
{{ PWD }}
```

`jinja2`

```
在模板中Jinja2可以用循环和条件语句,而在playbook中则不行

```

`复杂变量`


```
{{ ansible_eth0["ipv4"]["address"] }}

{{ ansible_eth0.ipv4.address }}

访问数组的第一个元素
{{ foo[0] }}

jinja2循环处理变量
{% for host in groups['app_servers'] %}
   {{ hostvars[host]['ansible_eth0']['ipv4']['address'] }}
{% endfor %}

```

`变量文件`

```
  vars_files:
    - /vars/external_vars.yml
```

`命令行传递变量`

```
ansible-playbook release.yml --extra-vars "version=1.23.45 other_variable=foo"

```


##### yml语法陷阱

YAML语法要求如果值以{{ foo }}开头的话我们需要将整行用双引号包起来.


```
这样是不行的:

- hosts: app_servers
  vars:
      app_path: {{ base_path }}/22
你应该这么做:

- hosts: app_servers
  vars:
       app_path: "{{ base_path }}/22"


```

##### facts获取远程系统信息

