#!/bin/bash

echo '#####################################'
echo '#Script Name:Auto Setting For Vultr #'
echo '#Build For Vultr CentOS 7           #'
echo '#Author:Jaydenz                     #'
echo '#Website:https://wwwjaydenz.cn/     #'
echo '#####################################'
if [[ $(id -u) != 0 ]]; then #检查是否为root用户
	echo '请以root用户权限执行本脚本！'
	exit 1
fi
#基础用户建立
yum -y install net-tools
read -p '输入用户名:' user
#获取服务器IP地址
ip=$(ifconfig | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sed -n '1p')
useradd $user
passwd $user
sed -i "92 i $user ALL=(ALL)       ALL" /etc/sudoers

if [ ! -e /home/$user/.ssh ]; then
    mkdir /home/$user/.ssh
fi
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAqrL1J5MN5A4aOfvd1Aa49p5dcodtIn4kZZxa7GHNkxt3mi9l3DiyrgwAoLssL3H2RMbeqERQkwrBOON4/YO0e1aibpe/e7y8O074QBJHpylFfEo6NdWQgP4Z0HgRiPgss5KowGiGffsGcGhtWU6YNUywg71jbaGbPKw97LxSTxnmm4cr20oG6OpFB3rcUi2zGQn1noV7cWFzDws3I3QN0rGdKkCCgTYJzyF0GTgSQ2QKmkIBYqCw/W3mumQYiQW8W/L4GrhXNNAkOUJRuaob3HV1tdyqfJWUH3x2PjdppW0CTyQhRKEckSKFVqgbK0NtRJ89NPVMG5fOQJd/PLPWMQ==' >> /home/$user/.ssh/authorized_keys
chown $user:$user /home/$user/.ssh/authorized_keys 
chmod 600 /home/$user/.ssh/authorized_keys

#处理sshd服务
cp /etc/ssh/sshd_config /home/$user/sshd_config.bak
sed -i "17 c Port 8375" /etc/ssh/sshd_config
sed -i "49 c PermitRootLogin no" /etc/ssh/sshd_config
sed -i "54 c RSAAuthentication yes" /etc/ssh/sshd_config
sed -i "55 c PubkeyAuthentication yes" /etc/ssh/sshd_config
sed -i "79 c PasswordAuthentication no" /etc/ssh/sshd_config
systemctl restart sshd
#修改iptables
iptables -I INPUT -d $ip -p tcp --dport 8375 -j ACCEPT
iptables -I INPUT -d $ip -p tcp --dport 1800 -j ACCEPT
iptables -I OUTPUT -s $ip -p tcp --sport 8375 -j ACCEPT
iptables -I OUTPUT -s $ip -p tcp --sport 1800 -j ACCEPT
iptables-save >> /dev/null
#安装SSR
echo '开始安装SSR'
wget --no-check-certificate https://freed.ga/github/shadowsocksR.sh; bash shadowsocksR.sh
#安装锐速
#wget -N --no-check-certificate https://freed.ga/kernel/ruisu.sh && bash ruisu.sh

#wget -N --no-check-certificate https://github.com/91yun/serverspeeder/raw/master/serverspeeder.sh && bash serverspeeder.sh