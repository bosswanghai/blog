## rest架构

### rest规范 OpenAPI

形态区分 标准rest和类rest(rpc形态)

类rest(rpc形态)
```
http://api.flickr.com/services/rest/?method=flickr.test.echo&name=value

```
特点：
服务请求地址包括了两部分：1. 服务的总入口地址http://api.flickr.com/services/rest/。2.服务方法以及参数。这和过去的RPC模式就是一样的，只是通过Http方式请求，返回的是可以指定格式数据内容。

标准rest形态
可以参考已有的互联网公司的rest风格


## rest api设计

如果是公网，需要access key和签名

编码方式UTF8

日志信息

错误码信息

接口设计风格
协议
版本号

请求：
- 方法
GET 查询
POST 创建或更新
DELETE 删除
- 参数

- body内容



响应:
响应状态码， 错误信息
错误码构造： http状态 + 服务编码 + 细致错误类型



