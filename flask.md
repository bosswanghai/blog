# Flask

### flask是什么
Flask 是一个 Python 实现的 Web 开发微框架

### flask安装
pip install Flask

### flask入门

**目录结构**

- test.py
- static/test.css
- templates/hello.html

`test.py`文件

```
from flask import Flask,request,url_for,render_template

app = Flask(__name__)  # Flask(instance_name) 创建flask实例

@app.route('/hello/')
@app.route('/hello/<name>')   # 创建路径
def hello(name=None):
    return render_template('hello.html', name=name)  #使用jinja2模板

@app.route('/')
def hello_world():
    app.logger.error('An error occurred') # 往屏幕上打印日志
    auth_header = request.headers.get("x_auth_header")
    auth_key = "sunjian~!@#"
    assert auth_header == md5.new("{}".format(auth_key)).hexdigest()
    return ("succ", 404, {"x-rsp-header":"haha"}) # 返回内容，状态吗，响应头


@app.route('/user/<username>')
def hello_test(username):
    return 'User %s' % username

@app.route('/post/<int:postid>')  # int主要用于类型转换
def hello_post(postid):
    return 'postid %s' % postid

with app.test_request_context():
    print url_for('static',filename='test.css')  #会访问当前目录下的static/test.css文件

if __name__ == '__main__':
    app.debug=True      # 开启调试模式，只用于开发环境，修改代码动态生效
    app.run(host="0.0.0.0")   # 监听公网

```

`static/test.css`

```
this is test.css

```


`static/test.css`

```
<!doctype html>
<title>Hello from Flask</title>
{% if name %}
  <h1>Hello {{ name }}!</h1>
{% else %}
  <h1>Hello World!</h1>
{% endif %}
```

### 