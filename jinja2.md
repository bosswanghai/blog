# Jinja2
## 文档
[实例文档](https://realpython.com/blog/python/primer-on-jinja-templating/)
[理论文档](http://docs.jinkan.org/docs/jinja2/templates.html#variables)

### 简介
python 模板语言

<title>{% block title %}{% endblock %}</title>
<ul>
{% for user in users %}
  <li><a href="{{ user.url }}">{{ user.username }}</a></li>
{% endfor %}
</ul>

**特性**
```
沙箱中执行
强大的 HTML 自动转义系统保护系统免受 XSS
模板继承
及时编译最优的 python 代码
可选提前编译模板的时间
易于调试。异常的行数直接指向模板中的对应行。
可配置的语法
```

##### 实例
```
from jinja2 import Template

# var
t = Template("hello {{ name }}")
print t.render(name="wang")

```

### 使用

{% 用于执行语句

{{ 输出语句结果到模板

{{}}中的运算


##### 变量

变量
{{ foo['bar'] }}

变量赋值
{% set key, value = call_something() %}

##### 注释
```
# for item in seq:
    <li>{{ item }}</li>     ## this comment is ignored
# endfor

{# note: disabled template because we no longer use this
    {% for user in users %}
        ...
    {% endfor %}
 #}

```

##### Super

##### Macros

##### Filters
分自定义过滤器和内置过滤器
