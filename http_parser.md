# http_parser

## introduction

## example

```
    int nparsed;
    http_parser *parser;
    const char *buf;

    parser = malloc(sizeof(http_parser));
    http_parser_init(parser, HTTP_REQUEST);

    buf = requests.raw;
    nparsed = http_parser_execute(parser, &settings_dontcall, buf, strlen(buf));

```


## api

http_parser_init(parser, HTTP_REQUEST | HTTP_RESPONSE);

nparsed = http_parser_execute(parser, &settings_dontcall, buf, strlen(buf));

callbacks

```
notification typedef int (*http_cb) (http_parser*); Callbacks: on_message_begin, on_headers_complete, on_message_complete.
data typedef int (*http_data_cb) (http_parser*, const char *at, size_t length); Callbacks: (requests only) on_uri, (common) on_header_field, on_header_value, on_body;
```

## 注意事项

```
http_parser_execute(parser, &settings, buf, recved)
recved =0 标记改流结束

In case you parse HTTP message in chunks (i.e. read() request line from socket, parse, read half headers, parse, etc) your data callbacks may be called more than once. Http-parser guarantees that data pointer is only valid for the lifetime of callback. You can also read() into a heap allocated buffer to avoid copying memory around if this fits your application.

```
