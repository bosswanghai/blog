# Python

### requests

##### 发送请求

##### 传递参数
```
payload = {'key1': 'value1', 'key2': ['value2', 'value3']}

headers = {'user-agent': 'my-app/0.0.1'}

allow_redirects=False

timeout=0.1  --指的是收到第一个字节的时间

r = requests.post('http://httpbin.org/get', params=payload, data=payload)

```

##### 响应内容
```
r.text

r.content  -- 二进制，处理非文本请求

r.raw  -- 设置请求参数stream=True，

r.status_code

r.cookies  -- dict

r.raise_for_status()

r.headers



```

编码

显示 r.encoding

设置 r.encoding='iso---'



##### 发送请求

##### 发送请求

##### 发送请求

##### 发送请求

##### 发送请求

##### 发送请求

##### 发送请求

##### 发送请求

##### 发送请求

##### 发送请求