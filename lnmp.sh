#!/bin/bash
echo '============================'
echo 'Install Nginx And MariaDB'
echo 'Author:Jaydenz'
echo 'Github:https://github.com/Jaydenz/Linux'
echo 'Version 0.3_beta'
echo '============================'

#安装前准备及读取系统信息
if [[ $UID != 0 ]]; then #检查是否为root用户
	echo '请以root用户权限执行本脚本！'
	exit 1
fi
#判断系统是否为64位
bit=$(getconf LONG_BIT) 
if [ $bit != 64 ]; then
	echo '本脚本仅支持64位操作系统！'
	exit 2
fi
#判断系统发行版
system(){
	if [];then
		lsb_release -a 
	elif [[ -f /etc/redhat-release ]];then
		
	elif [[ -f  ]]
		
}
system(){
	public=$(cat /proc/version | grep -oE '(Debian)|(Red Hat)|(Ubuntu)')
	if [[ $public == 'Ubuntu' ]]; then
        	echo '你的系统发行版是Ubuntu'
			return 33
	elif [[ $public == 'Debian' ]]; then
        	echo '你的系统发行版是Debian'
			return 33
	elif [[ $public == 'Red Hat' ]]; then
        	echo '你的系统发行版是Red Hat'
			return 44
	else
        	echo "你的系统发行版不受支持！"
        exit 3
	fi
}


install_nginx(){
	echo '开始安装Nginx...'
	if [ ! -f nginx.tar.gz ]; then
		echo '文件不存在!请将nginx.tar.gz放在脚本同一目录下!'
		exit 3
	fi
	system
	if [[  $? =  '44'  ]]; then
		yum install -y pcre pcre-devel openssl openssl-devel gcc make gcc-c++
	else
		apt-get install --allow openssl libssl-dev  libpcre3 libpcre3-dev fizlib1g-dev  
	fi
	tar -xvf nginx.tar.gz && cd nginx*
	groupadd nginx
    useradd -M -g nginx -s /sbin/nologin nginx
    ./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-http_stub_status_module --user=nginx --group=nginx --with-pcre
	cd /tmp/src
}
install_mysql(){
	echo '开始安装MariaDB...'
	if [[ ! -f mariadb.tar.gz ]]; then
		echo '文件不存在!请将mariadb.tar.gz放在脚本同一目录下!'
		exit 4
	fi
	
	system
	if [[  $? =  '44'  ]]; then
		yum -y install make gcc-c++ cmake bison-devel ncurses-devel libaio numactl
	else
		apt-get -y install gcc libpcre3 libpcrecpp0v5 libpcre3-dev libssl-dev
	fi
	
	tar -xvf mysql.tar.gz -C /usr/local/ && mv /usr/local/mysql* /usr/local/mysql
	useradd -M -s /sbin/nologin mysql 
	bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data &> tmp.log
	grep 'A temporary password' | awk '{print "安装临时密码:"$NF}'
}
install_php(){
	echo '下载PHP...'
	wget --no-check-certificate -O php.tar.gz $php
	if [ $? != 0 ]; then
		echo '下载失败，请检查网络链接或下载地址是否失效！'
		exit 3
	fi
	system
	if [[  $? =  '44'  ]]; then
		yum install -y libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel
    开始编译        
	else
		apt-get install -y  --force-yes 
	fi
	tar -xvf php.tar.gz && cd php*
    ./configure --prefix=/usr/local/php --with-config-file-path=/etc --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx --enable-inline-optimization --disable-debug --disable-rpath --enable-shared --enable-soap --with-libxml-dir --with-xmlrpc --with-openssl --with-mcrypt --with-mhash --with-pcre-regex --with-sqlite3 --with-zlib --enable-bcmath --with-iconv --with-bz2 --enable-calendar --with-curl --with-cdb --enable-dom --enable-exif --enable-fileinfo --enable-filter --with-pcre-dir --enable-ftp --with-gd --with-openssl-dir --with-jpeg-dir --with-png-dir --with-zlib-dir --with-freetype-dir --enable-gd-native-ttf --enable-gd-jis-conv --with-gettext --with-gmp --with-mhash --enable-json --enable-mbstring --enable-mbregex --enable-mbregex-backtrack --with-libmbfl --with-onig --enable-pdo --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-zlib-dir --with-pdo-sqlite --with-readline --enable-session --enable-shmop --enable-simplexml --enable-sockets --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-wddx --with-libxml-dir --with-xsl --enable-zip --enable-mysqlnd-compression-support --with-pear --enable-opcache
	
}
install_mysql
install_nginx
install_php
