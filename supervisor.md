# supervisord 介绍

# supervisord 命令

```
supervisord: 初始启动Supervisord，启动、管理配置中设置的进程;
supervisorctl stop(start, restart) xxx，停止（启动，重启）某一个进程(xxx);
supervisorctl reread: 只载入最新的配置文件, 并不重启任何进程;
supervisorctl reload: 载入最新的配置文件，停止原来的所有进程并按新的配置启动管理所有进程;
supervisorctl update: 根据最新的配置文件，启动新配置或有改动的进程，配置没有改动的进程不会受影响而重启;
```
