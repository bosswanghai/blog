# inotify

## inotify 简介
是一个有效的检测和通知系统变化的工具

## 使用

- 创建监控对象列表
- 设置监控对象的变化通知

Create the inotify instance by inotify_init().

Add all the directories to be monitored to the inotify list using inotify_add_watch() function.

To determine the events occurred, do the read() on the inotify instance. This read will get blocked till the change event occurs. It is recommended to perform selective read on this inotify instance using select() call.

Read returns list of events occurred on the monitored directories. Based on the return value of read(), we will know exactly what kind of changes occurred.
In case of removing the watch on directories / files, call inotify_rm_watch().

例子

```
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <linux/inotify.h>

#define EVENT_SIZE (sizeof(struct inotify_event))
#define EVENT_BUF_LEN (1024 * (EVENT_SIZE + 16))

typedef struct inotify_event str_inotify_event;

int main(){
    int length, i = 0;
    int fd, wd;
    char buf[EVENT_BUF_LEN];
    str_inotify_event * event;

    if((fd = inotify_init()) < 0){
        perror("inotify_init faild");
        return -1;
    }

    wd = inotify_add_watch(fd, "/app/nginx_access.log", IN_CLOSE_WRITE|IN_MOVED_TO);

    if((length = read(fd, buf, EVENT_BUF_LEN)) < 0){
        perror("read error");
        return -1;
    }

    while(i < length){
        event = (str_inotify_event *)&buf[i];
        printf("event-name: %s.\n", event->name);
        if(event->len){
            if(event->wd == wd){
                printf("event-name: %s.\n", event->name);
            }
        }
        i += EVENT_SIZE + event->len;
    }

    inotify_rm_watch(fd, wd);
    close(fd);

    return 0;
}

```

