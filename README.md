# awtrix-server-docker-builder

这是一个在docker部署awtrix服务器的脚本

没错就是那个sh脚本

使用前请确认已安装docker与wget

可以添加三个参数
1. web后台端口（默认为7000）
2. esp8266通信端口（默认为7001）
3. 容器名（默认为随机容器名）

！注意，参数只能按顺序添加

```bash
sh ./goawtrix.sh
```
或
```bash
sh ./goawtrix.sh 7010 7011 containername
```
