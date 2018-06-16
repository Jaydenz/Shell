# LNMP傻瓜脚本
## 简介
全自动配置好LNMP啦，安装过程到了最后记得按照向导输入MariaDB数据库密码，整个安装大概要30分钟吧，看你电脑配置咯。
## 食用方法
1.去Nginx、MariaDB、PHP官网下载编译版本的软件包放置在改脚本同一目录下，分别改名为mariadb.tar.gz、nginx.tar.gz、php.tar.gz，或者用这里自带的

2.以root权限执行

3.出去逛一圈~，买瓶水

4.回来按照向导提示初始化数据库即可

5.打开http://127.0.0.1/即可访问http页面，打开http://127.0.0.1/index.php即可访问php页面

## 程序文件及目录
### Nginx
安装目录：/usr/local/nginx

主配置文件：/etc/nginx/nginx.conf

Systemd脚本名：nginx.service

网站目录：/usr/local/nginx/html

### PHP
安装目录：/usr/local/php

PHP-FPM：/usr/local/php/sbin/php-fpm

主配置文件：/etc/php.ini

Systemd脚本名：php-fpm.service

### MariaDB
安装目录：/usr/local/mariadb

主配置文件：/etc/my.cnf

Systemd脚本名：mysql.service

## 测试环境
Ubuntu18.04

Ubuntu16.04

CentOS 7-1708

## 更新地址
https://github.com/Jaydenz/Shell

