## django使用

## introduction

## install
版本选择
Django 1.11.x 支持 Python 2.7, 3.4, 3.5 和 3.6

git上安装最新版本只支持python 3


## runniing

### 功能概览

urls.py 网址入口，关联到对应的views.py中的一个函数（或者generic类），访问网址就对应一个函数。

views.py 处理用户发出的请求，从urls.py中对应过来, 通过渲染templates中的网页可以将显示内容，比如登陆后的用户名，用户请求的数据，输出到网页。

models.py 与数据库操作相关，存入或读取数据时用到这个，当然用不到数据库的时候 你可以不使用

forms.py 表单，用户在浏览器上输入数据提交，对数据的验证工作以及输入框的生成等工作，当然你也可以不使用。

templates 文件夹 views.py 中的函数渲染templates中的Html模板，得到动态内容的网页，当然可以用缓存来提高速度。

admin.py 后台，可以用很少量的代码就拥有一个强大的后台。

settings.py Django 的设置，配置文件，比如 DEBUG 的开关，静态文件的位置等。

### 命令概览

创建一个新工程 django-admin.py startproject helloworld

```
tree helloworld
helloworld
├── db.sqlite3
├── helloworld
│   ├── __init__.py
│   ├── __init__.pyc
│   ├── settings.py
│   ├── settings.pyc
│   ├── urls.py
│   ├── urls.pyc
│   ├── view.py
│   ├── wsgi.py
│   └── wsgi.pyc
└── manage.py
```

启动服务
```
python manage.py runserver 0.0.0.0:8000
```

配置url和view

urls.py
```
from django.conf.urls import url

from . import view

urlpatterns = [
    url(r'^$', view.hello),
]

```

view.py
```
from django.http import HttpResponse
def hello(request):
    return HttpResponse("Hello world ! ")

```

### api详细介绍

url函数
```
Django url() 可以接收四个参数，分别是两个必选参数：regex、view 和两个可选参数：kwargs、name，接下来详细介绍这四个参数。
regex: 正则表达式，与之匹配的 URL 会执行对应的第二个参数 view。
view: 用于执行与正则表达式匹配的 URL 请求。
kwargs: 视图使用的字典类型的参数。
name: 用来反向获取 URL。
```
