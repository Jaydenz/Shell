#!/bin/bash
echo '======================================='
echo 'Install Nginx && MariaDB && PHP'
echo 'Author:Jaydenz'
echo 'Github:https://github.com/Jaydenz/Linux'
echo 'Version 1.0'
echo '======================================='

#安装前准备及读取系统信息
if [[ $UID != 0 ]]; then #检查是否为root用户
	echo 'Error:请以root用户权限执行本脚本！'
	exit 1
fi
#判断系统是否为64位
bit=$(getconf LONG_BIT) 
if [ $bit != 64 ]; then
	echo 'Error:本脚本仅支持64位操作系统！'
	exit 2
fi
#判断系统发行版
get_system_release(){
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        release='CentOS'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        release='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        release='Ubuntu'
        PM='apt'		
	else
        echo 'Error:不支持的发行版!'
		exit 1
    fi
}
#判断是否支持systemd
is_systemd(){
	if [[ -d /lib/systemd/system ]]; then
		SYSTEMDIR="/lib/systemd/system"
	else 
		echo 'Error:看起来你的系统不是Systemd的...'
		exit 2
	fi
}

install_nginx(){
	echo '开始安装Nginx...'
	if [ ! -f nginx.tar.gz ]; then
		echo 'Error:文件不存在!请将nginx.tar.gz放在脚本同一目录下!'
		exit 3
	fi

	if [[  $release = 'CentOS'  ]]; then
		yum install -y pcre pcre-devel openssl openssl-devel gcc make gcc-c++
		if [[ ! $? = 0 ]]; then
			echo 'Error:安装依赖失败了哦！'
			exit 5
		fi
	else
		apt-get install -y openssl libssl-dev  libpcre3 libpcre3-dev   
		if [[ ! $? = 0 ]]; then
			echo 'Error:安装依赖失败了哦！'
			exit 5
		fi
	fi
	
	tar -xvf nginx.tar.gz -C /tmp/src && cd /tmp/src/nginx*
	groupadd nginx
    useradd -M -g nginx -s /sbin/nologin nginx
	
    ./configure --prefix=/usr/local/nginx --conf-path=/etc/nginx/nginx.conf --with-http_ssl_module --with-http_stub_status_module --user=nginx --group=nginx --with-pcre
	make && make install
	chown -R nginx:nginx /usr/local/nginx
	cd $DIR
	echo -e '[Unit]\nDescription=Nginx\nAfter=network.target\n[Service]\nType=forking\nPIDFile=/usr/local/nginx/logs/nginx.pid\nExecStart=/usr/local/nginx/sbin/nginx\nExecReload=/usr/local/nginx/sbin/nginx -s reload\nExecStop=/usr/local/nginx/sbin/nginx -s stop\nPrivateTmp=true\n[Install]\nWantedBy=multi-user.target' > $SYSTEMDIR/nginx.service
	echo "export PATH=$PATH:/usr/local/nginx/sbin/" >> /etc/profile
	source /etc/profile
	systemctl daemon-reload && systemctl enable nginx && systemctl start nginx
}

install_mariadb(){
	echo '开始安装MariaDB...'
	if [[ ! -f mariadb.tar.gz ]]; then
		echo '文件不存在!请将mariadb.tar.gz放在脚本同一目录下!'
		exit 4
	fi
	if [[  $release = 'CentOS'  ]]; then
		yum -y install libaio libaio-devel bison bison-devel zlib-devel openssl openssl-devel ncurses ncurses-devel libcurl-devel libarchive-devel boost boost-devel lsof wget gcc gcc-c++ make cmake perl kernel-headers kernel-devel pcre-devel ncurses-devel bzip2 m4 libevent
		if [[ ! $? = 0 ]]; then
			echo 'Error:安装依赖失败了哦！'
			exit 5
		fi	
	else
		apt-get install -y make cmake automake autoconf libtool gcc bison g++ libncurses5-dev libssl-dev libjemalloc-dev 
		if [[ ! $? = 0 ]]; then
			echo 'Error:安装依赖失败了哦！'
			exit 5
		fi	
	fi
	
	tar -xvf mariadb.tar.gz -C /tmp/src/ && cd /tmp/src/mariadb*
	useradd -M -s /sbin/nologin mysql 
	cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mariadb -DMYSQL_DATADIR=/usr/local/mariadb/data -DSYSCONFDIR=/etc -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_LIBWRAP=0 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DDEFAULT_CHARSETS=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITHOUT_TOKUDB=1

	make && make install
	chown -R mysql:mysql /usr/local/mariadb
	echo "export PATH=$PATH:/usr/local/mariadb/bin/" >> /etc/profile
	source /etc/profile
	echo -e '[mysqld]\ncharacter-set-server = utf8\ncollation-server = utf8_general_ci\ncharacter-set-client-handshake = false' > /etc/my.cnf
	/usr/local/mariadb/scripts/mysql_install_db --basedir=/usr/local/mariadb/ --datadir=/usr/local/mariadb/data/ --user=mysql
	echo -e '[Unit]\nDescription=MariaDB\nAfter=syslog.target network.target\n[Service]\nLimitNOFILE=10000\nType=simple\nUser=mysql\nGroup=mysql\nPIDFile=/usr/local/mariadb/mariadb.pid\nExecStart=/usr/local/mariadb/bin/mysqld_safe --basedir=/usr/local/mariadb\nExecStop=/bin/kill -9 $MAINPID\nPrivateTmp=false     #是否启用私有临时目录，因为编译时启用了-DMYSQL_UNIX_ADDR=/tmp/mysql.sock为公共临时目录，所以关闭\n[Install]\nWantedBy=multi-user.target' > $SYSTEMDIR/mysql.service
	systemctl daemon-reload && systemctl enable mysql && systemctl start mysql
	echo '=================================================='
	echo '            下面开始MariaDB配置向导....'
	echo '=================================================='
	mysql_secure_installation
	cd $DIR
}
install_php(){
	echo '开始安装PHP...'
	if [[ ! -f php.tar.gz ]]; then
		echo 'Error:文件不存在!请将php.tar.gz放在脚本同一目录下!'
		exit 4
	fi

	if [[  $release = 'CentOS'  ]]; then
		yum install -y libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel      
		if [[ ! $? = 0 ]]; then
			echo 'Error:安装依赖失败了哦！'
			exit 5
		fi	
	else
		apt-get install -y build-essential bison re2c pkg-config libxml2-dev libbz2-dev libssl-dev libcurl4-openssl-dev libjpeg-dev libfreetype6-dev libgmp-dev libreadline6-dev libxslt1-dev libzip-dev
		if [[ ! $? = 0 ]]; then
			echo 'Error:安装依赖失败了哦！'
			exit 5
		fi
	fi

	tar -xvf php.tar.gz -C /tmp/src && cd /tmp/src/php*
    ./configure --prefix=/usr/local/php --with-config-file-path=/etc --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx --enable-inline-optimization --disable-debug --disable-rpath --enable-shared --enable-soap --with-libxml-dir --with-xmlrpc --with-openssl --with-mhash --with-pcre-regex --with-sqlite3 --with-zlib --enable-bcmath --with-iconv --with-bz2 --enable-calendar --with-curl --with-cdb --enable-dom --enable-exif --enable-fileinfo --enable-filter --with-pcre-dir --enable-ftp --with-gd --with-openssl-dir --with-jpeg-dir --with-png-dir --with-zlib-dir --with-freetype-dir --enable-gd-jis-conv --with-gettext --with-gmp --with-mhash --enable-json --enable-mbstring --enable-mbregex --enable-mbregex-backtrack --with-libmbfl --with-onig --enable-pdo --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-zlib-dir --with-pdo-sqlite --with-readline --enable-session --enable-shmop --enable-simplexml --enable-sockets --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-wddx --with-libxml-dir --with-xsl --enable-zip --enable-mysqlnd-compression-support --with-pear --enable-opcache
	make && make install
	chown -R nginx:nginx /usr/local/php
	echo "export PATH=$PATH:/usr/local/php/bin" >> /etc/profile
	source /etc/profile
	cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
	cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf

	echo -e '[Unit]\nDescription=The PHP FastCGI Process Manager\nAfter=syslog.target network.target\n[Service]\nType=forking\nExecStart=/usr/local/php/sbin/php-fpm\nExecStop=/bin/kill -9 $MAINPID\n[Install]\nWantedBy=multi-user.target\n' > $SYSTEMDIR/php-fpm.service
	touch /etc/php.ini
	sed -i '65,71 s/#//' /etc/nginx/nginx.conf
	sed -i '69 s/\/scripts/$document_root/' /etc/nginx/nginx.conf
	echo -e '<?php\nphpinfo();\nphpinfo(INFO_MODULES);\n?>' > /usr/local/nginx/html/index.php  && chown nginx:nginx /usr/local/nginx/html/index.php
	systemctl daemon-reload && systemctl enable php-fpm && systemctl start php-fpm && systemctl restart nginx
	cd $DIR
}

declare release
declare PM
declare DIR=$PWD
declare SYSTEMDIR
mkdir /tmp/src

get_system_release
is_systemd

install_nginx
install_php
install_mariadb

rm -r /tmp/src
echo '安装完成!记得在当前终端运行一下 source /etc/profile 命令！'
