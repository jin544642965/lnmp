#!/bin/bash
#Aduio:jorden

echo "This script is for centos7"

function check {
        if [ $? -ne 0 ];then
                echo -e "\033[31m\n the last command exec failed,please check it \033[0m \n"
                sleep 1
                exit -1
        fi
}

function initialize_system {
        echo -e "\033[32m 1.关闭selinux \033[0m"
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0

        echo -e "\033[32m 2.开启时间同步 \033[0m"
        cat /var/spool/cron/root|grep -w "/usr/sbin/ntpdate pool.ntp.org > /dev/null 2>&1"
        [ $? -ne 0 ] && echo "0 0 * * * /usr/sbin/ntpdate pool.ntp.org > /dev/null 2>&1" >>/var/spool/cron/root
        echo -e "\033[32m crontab has been added successfully \033[0m"

        echo -e "\033[32m 3.修改最大连接数unlimt=102400 \033[0m"
        ulimit -n 102400
        cat /etc/security/limits.conf |grep -w "* soft nofile 102400"
        [ $? -ne 0 ] && echo "* soft nofile 102400" >>/etc/security/limits.conf
        cat /etc/security/limits.conf |grep -w "* hard nofile 102400"
        [ $? -ne 0 ] && echo "* hard nofile 102400" >>/etc/security/limits.conf
        echo -e "\033[32m file handel has been successfully changed \033[0m"

        echo -e "\033[32m 4.增加114.114.114.114的dns \033[0m"
        cat /etc/resolv.conf|grep -w "nameserver=114.114.114.114"
        [ $? -ne 0 ] && echo "nameserver=114.114.114.114" >>/etc/resolv.conf
        echo -e "\033[32m dns successful \033[0m"

                echo -e "\033[32m 5.设置ts=4 \033[0m"
                cat /etc/vimrc|grep -w "set ts=4"
                [ $? -ne 0 ] && echo "set ts=4" >>/etc/vimrc

        echo "install software dos2unix,telnet,lrzsz,wget,git,unzip,zip, crontabs openssl-devel gcc gcc-c++"
        yum install dos2unix vim telnet lrzsz wget git unzip zip openssl-devel gcc gcc-c++  -y



}

function install_nginx {
        echo "\033[36m\n 安装nginx \033[0 \n"
        rpm -qa|grep nginx-release-centos-7-0.el7.ngx.noarch
        if [ $? -ne 0 ];then
                rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
                check;
        fi
        yum install -y nginx
        check;
        sed -i 's/user  nginx nginx/user  www www/g' /etc/nginx/nginx.conf
        sed -i 's/worker_connections  1024/worker_connections  51024/g' /etc/nginx/nginx.conf
        sed -i 's/worker_processes  1/worker_processes  auto/g' /etc/nginx/nginx.conf
        cat /etc/nginx/nginx.conf |grep -w "fastcgi_buffers 8 128k"
        [ $? -ne 0 ] && sed -i '25ifastcgi_buffers 8 128k;' /etc/nginx/nginx.conf
        cat /etc/nginx/nginx.conf |grep -w "client_max_body_size 8M;"
        [ $? -ne 0 ] && sed -i '26iclient_max_body_size 8M;' /etc/nginx/nginx.conf
        mv /etc/nginx/conf.d/default.conf{,.bak}
        useradd www
        service nginx restart
        echo -e "\033[36m nginx install finished for the latest!配置文件位于/etc/nginx/ \033[0m "
        echo -e "\033[36m\n ---请自行配置nginx--- \033[0m \n"
}

function install_php71 {
        echo -e "\033[36m\n安装php7.1和php7.1的全部扩展\033[0m \n"
        rpm -qa|grep epel-release-7
        if [ $? -ne 0 ];then
                rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
                check;
        fi
        rpm -qa|grep webtatic-release
        if [ $? -ne 0 ];then
                rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
                check;
        fi
        yum install -y php71w* --skip-broken
        check;
        echo -e "\033[36m\n 修改session权限 \033[0m \n"
        useradd www
        chown -R www.www /var/lib/php/
        sed -i 's/user = apache/user = www/g' /etc/php-fpm.d/www.conf
        sed -i 's/group = apache/group = www/g' /etc/php-fpm.d/www.conf
        sed -i 's/pm.max_children = 50/pm.max_children = 1500/g' /etc/php-fpm.d/www.conf
        sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' /etc/php.ini
        echo -e "\033[36m user=www,group=www  \033[0m"
        echo -e "\033[36m php7.1 install finished！配置文件位于/etc/php.ini,/etc/php-fpm.conf \033[0m "
        echo -e "\033[36m\n ---请自行配置php--- \033[0m \n"
        service php-fpm restart
}

function install_php72 {
        echo -e "\033[36m\n安装php7.2和php7.2的全部扩展\033[0m \n"
        rpm -qa|grep epel-release-7
        if [ $? -ne 0 ];then
                rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
                check;
        fi
        rpm -qa|grep webtatic-release
        if [ $? -ne 0 ];then
                rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
                check;
        fi
        yum install -y php72w* --skip-broken
        check;
        echo -e "\033[36m\n 修改session权限 \033[0m \n"
        useradd www
        chown -R www.www /var/lib/php/
        sed -i 's/user = apache/user = www/g' /etc/php-fpm.d/www.conf
        sed -i 's/group = apache/group = www/g' /etc/php-fpm.d/www.conf
        sed -i 's/pm.max_children = 50/pm.max_children = 1500/g' /etc/php-fpm.d/www.conf
        sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' /etc/php.ini
        echo -e "\033[36m user=www,group=www  \033[0m"
        echo -e "\033[36m php7.1 install finished！配置文件位于/etc/php.ini,/etc/php-fpm.conf \033[0m "
        echo -e "\033[36m\n ---请自行配置php--- \033[0m \n"
        service php-fpm restart
}


function install_mysql57 {
        echo " 安装mysql5.7"
        rpm -qa|grep mysql-community-release-el7-5.noarch
        if [ $? -ne 0 ];then
                rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
                check;
        fi
        yum install -y mysql-community-server
        check;
        service mysqld start
        check;

        # 配置mysql
        mkdir -p /data/mysqllog
        mkdir -p /data/mysqldata
        chown -R mysql.mysql /data/mysqldata
        chown -R mysql.mysql /data/mysqllog

        echo "优化参数：最大连接数，设置编码utf8"
        cat /etc/my.cnf |grep -w "max_connections = 1000"
        [ $? -ne 0 ] &&  sed -i '/\[mysqld\]/a\max_connections = 1000' /etc/my.cnf
        
        cat /etc/my.cnf |grep -w "character_set_server=utf8"
        [ $? -ne 0 ] && sed -i '/\[mysqld\]/a\character_set_server=utf8' /etc/my.cnf

        echo -e "\033[36m mysql install finished！配置文件位于/etc/my.cnf,密码为空\033[0m"
        echo -e "\033[36m ---请自行配置mysql，如字符集utf8--- \033[0m"
}

function install_mysql56 {
        echo " 安装mysql5.6"
        rpm -qa|grep mysql-community-release-el7-5.noarch
        if [ $? -ne 0 ];then
                rpm -Uvh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
                check;
        fi
        yum install -y mysql-community-server
        check;

        # 创建mysql数据，日志目录
        mkdir -p /data/mysqllog
        mkdir -p /data/mysqldata
        chown -R mysql.mysql /data/mysqldata
        chown -R mysql.mysql /data/mysqllog

        echo "创建mysql初始用户root 密码b9LdP#dfZEW>=o"
        mysql -e "grant all privileges on *.* to root@'localhost' identified by 'b9LdPvwyZEW>=o'";

        service mysqld start
        check;

        echo "优化参数：最大连接数，设置编码utf8"
        cat /etc/my.cnf |grep -w "max_connections = 1000"
        [ $? -ne 0 ] &&  sed -i '/\[mysqld\]/a\max_connections = 1000' /etc/my.cnf

        cat /etc/my.cnf |grep -w "character_set_server=utf8"
        [ $? -ne 0 ] && sed -i '/\[mysqld\]/a\character_set_server=utf8' /etc/my.cnf

        echo -e "\033[36m mysql install finished！配置文件位于/etc/my.cnf,密码为空\033[0m"
        echo -e "\033[36m ---请自行配置mysql，如字符集utf8--- \033[0m"
}


function modify_ssh {
        echo " 修改ssh默认端口为8622"
        sed -i 's/#Port 22/Port 8622/g' /etc/ssh/sshd_config
        echo -e "\033[36m 关闭iptables/firewalld\033[0m"
        service firewalld stop
                checkconfig firewalld off
        service sshd restart
                service iptables restart
}

function add_ssh_key {
        echo "add user of www ssh-key"
        useradd www
        mkdir -p /home/www/.ssh
        echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqtBbOblU3zGch5MxJWFEJWneX3n6nSzZ1ii4c1JilgsbtfqaAVTh4IL6rVYZlJaKSAtQBy2fQ6HRhhGjghbVvfIRbVnj1NiOMz9u0aEdq4NaSyehNA
zFT2w2BZ7t6jYNavOkOm4ieO3lKO+hH5PIZNAcBvdCWn1FdSAB2NhfhazXVIHQGUSpuYuKR17bwsJjxlwI8dtLm+6Ebt7OzxMalCBPre1342bxN1aJt9MZqQOkFopuIBcbhOj0v2E+8B1rYFx4QYazl3U8HEq6tWJxpEOLCTq
MeD0YkjOik8kKjGxR+B57nhepidsIz1rUlnsc/2lCXv1mSKKAfUtl8wtmbaL" >/home/www/.ssh/authorized_keys
        chown -R www.www /home/www/
        chmod 600 /home/www/.ssh/authorized_keys
        echo -e "\033[36m ---www用户的公钥添加到服务器成功，可以用证书登陆---\033[0m"
}

function install_mongodb4 {
        echo "
[mongodb-org-4.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc">/etc/yum.repos.d/mongodb-org-4.0.repo
        yum install -y mongodb-org
        sed -i 's/^#security:/security:/g' /etc/mongod.conf

        cat /etc/mongod.conf |grep "authorization: enabled"
        [ $? -ne 0 ] && sed -i '/^security:/a\\t authorization: enabled' /etc/mongod.conf
        systemctl start mongod

}

function install_redis50() {
        echo “获取服务器eth0网口IP”
        host=`/usr/sbin/ip addr |grep inet |grep -v inet6 |grep eth0|awk '{print $2}' |awk -F "/" '{print $1}'`

        echo "redis相关系统优化"
        cat /etc/sysctl.conf |grep "^net.core.somaxconn="
        [ $? -ne 0 ] && echo "net.core.somaxconn=5000" >> /etc/sysctl.conf

        cat /etc/sysctl.conf |grep "^vm.overcommit_memory="
        [ $? -ne 0 ] && echo "vm.overcommit_memory=1" >> /etc/sysctl.conf
        sysctl -p

        echo never > /sys/kernel/mm/transparent_hugepage/enabled
        cat /etc/rc.local |grep -w "echo never > /sys/kernel/mm/transparent_hugepage/enabled"
        [ $? -ne 0 ] && echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >>/etc/rc.local


        echo ""1.安装redis依赖
        yum install -y gcc tcl

        echo "2.下载redis安装包"
        cd /usr/local/src/

        if [ ! -f ./redis-5.0.0.tar.gz ];then
                wget http://download.redis.io/releases/redis-5.0.0.tar.gz
                mkdir /usr/local/redis
                tar -zxvf redis-5.0.0.tar.gz -C /usr/local/
                mv /usr/local/redis-5.0.0 /usr/local/redis
                cd /usr/local/redis
                make
                make install

                echo "创建redis配置文件"
                mkdir /etc/redis/
                cp /usr/local/redis/redis.conf /etc/redis/

                echo "修改bind ip，"
                sed -i "s/^bind 127.0.0.1/bind $host/g" /etc/redis/redis.conf
                sed -i "s/^daemonize no/daemonize yes/g" /etc/redis/redis.conf
                sed -i "s/^protected-mode yes/protected-mode no/g" /etc/redis/redis.conf

                cat /etc/redis/redis.conf |grep -w "^requirepass weqFcx12fds"
                [ $? -ne 0 ] && echo "requirepass weqFcx12fds" >> /etc/redis/redis.conf

                echo "启动redis"
                /usr/local/redis/src/redis-server /etc/redis/redis.conf

        else
                echo "安装包已存在,只修改配置"
                echo "修改bind ip，"
                sed -i "s/^bind 127.0.0.1/bind $host/g" /etc/redis/redis.conf
                sed -i "s/^daemonize no/daemonize yes/g" /etc/redis/redis.conf
                sed -i "s/^protected-mode yes/protected-mode no/g" /etc/redis/redis.conf

                cat /etc/redis/redis.conf |grep -w "^requirepass weqFcx12fds"
                [ $? -ne 0 ] && echo "requirepass weqFcx12fds" >> /etc/redis/redis.conf
        fi

}

function install_openvpn(){
        echo "1.安装openvpn依赖"
        yum install openssl* gcc -y

        echo "2.安装lzo库"
        cd /usr/local/src
        if [ ! -f ./lzo-2.09.tar.gz ];then
                wget http://www.oberhumer.com/opensource/lzo/download/lzo-2.09.tar.gz
                tar xf lzo-2.09.tar.gz
                cd zo-2.09
                ./configure -prefix=/usr/local/lzo
                make && make install
        fi

        echo "3.下载openvpn"
        cd /usr/local/src
        if [ ! -f ./openvpn-2.2.2.tar.gz ];then
                wget http://oss.aliyuncs.com/aliyunecs/openvpn-2.2.2.tar.gz
                tar xf openvpn-2.2.2.tar.gz
                cd openvpn-2.2.2
                ./configure --prefix=/usr/local/openvpn --with-lzo-headers=/usr/local/lzo/include --with-lzo-lib=/usr/local/lzo/lib --with-ssl-headers=/usr/include/ope
nssl --with-ssl-lib=/usr/lib64/openssl
                make  && make install

                echo "配置openvpn,初始化证书"
                mkdir /etc/openvpn
                cp /usr/local/openvpn/easy-rsa /etc/openvpn
                cd /etc/openvpn/easy-rsa/2.0

                echo "生成服务器证书，dh，ca证书"
                source ./vars
                ./clean-all
                ./build-dh 

                echo -e "\033[32m 开始生成ca证书 \033[0m"
        ./build-ca

        echo -e "\033[32m 开始生成server证书 \033[0m"
        ./build-key-server server

                echo "拷贝证书文件到/etc/openvpn"
                cd keys
                cp ca.* server.* dh1024.pem /etc/openvpn

                echo "获取内网地址段"
        host=`/usr/sbin/ip addr |grep inet |grep -v inet6 |grep eth0|awk '{print $2}' |awk -F "/" '{print $1}'`
        intranet=`echo $host|awk -F [.] '{print $1 "." $2 ".0.0"}'`

        echo "生成服务端配置文件server.conf"
        echo -e "port 1194 \nproto udp \ndev tuni \nca /etc/openvpn/ca.crt \ncert /etc/openvpn/server.crt \nkey /etc/openvpn/server.key \ndh /etc/openvpn/dh1024.pem \n
server 10.10.0.0 255.255.255.0 \nifconfig-pool-persist ipp.txt \npush 'route $intranet 255.255.0.0' \npush 'dhcp-option DNS 8.8.8.8' \npush 'dhcp-option DNS 114.114.11
4.114' \npush 'dhcp-option DNS 74.207.242.5' \nclient-to-client \nduplicate-cn \nkeepalive 10 120 \ncomp-lzo \nuser nobody \ngroup nobody \npersist-key \npersist-tun \
nstatus /var/log/openvpn-status.log \nlog /var/log/openvpn.log \nlog-append /var/log/openvpn.log \n#crl-verify /etc/openvpn/easy-rsa/2.0/keys/crl.pem \n" >/etc/openvpn
/server.conf



        # 创建openvpn客户端证书 
        create_openvpn_client_key


                echo "开启ip转发"
                cat /etc/sysctl.conf|grep -w "net.ipv4.ip_forward = 1"
                [ $? -ne 0 ] && echo "net.ipv4.ip_forward = 1" >>/etc/sysctl.conf
                sysctl -p

                echo "iptables开启vpn流量转发"
        echo "禁止firewall"
        systemctl stop firewalld.service
        systemctl disable firewalld.service
                yum install iptables-services -y
                sed -i 's/^-A INPUT -j REJECT --reject-with icmp-host-prohibited/#-A INPUT -j REJECT --reject-with icmp-host-prohibited/g' /etc/sysconfig/iptables
                sed -i 's/^-A FORWARD -j REJECT --reject-with icmp-host-prohibited/#-A FORWARD -j REJECT --reject-with icmp-host-prohibited/g' /etc/sysconfig/iptables
                cat /etc/sysconfig/iptables |grep -w "A POSTROUTING -s 10.10.0.0/24 -o eth0 -j MASQUERADE"
        if [ $? -ne 0 ];then
                        iptables -t nat -A POSTROUTING -s 10.10.0.0/24 -o eth0 -j MASQUERADE
                        service iptables save
                chkconfig iptables on
                service iptables restart
                fi

                echo -e "\033[32m 启动openvpn \033[0m"
                /usr/local/openvpn/sbin/openvpn --daemon --config /etc/openvpn/server.conf
                cat /etc/rc.local |grep -w "/usr/local/openvpn/sbin/openvpn --daemon --config /etc/openvpn/server.conf"
                [ $? -ne 0 ] && echo "/usr/local/openvpn/sbin/openvpn --daemon --config /etc/openvpn/server.conf" >>/etc/rc.local


                echo -e "\033[31m\n 防火墙开启udp:1194端口 \033[0m \n"

        else
                echo "安装文件已存在"

        fi

}

function create_openvpn_client_key(){
        #获取公网IP
        public_ip=`curl http://members.3322.org/dyndns/getip`

        echo -e "\033[32m 开始创建openvpn客户端证书 \033[0m"

        read -p "请输入你的key名: " keyname
        cd /etc/openvpn/easy-rsa/2.0
        source ./vars
        ./build-key $keyname

        echo "生成windows客户端client.ovpn文件"
    cd /etc/openvpn/easy-rsa/2.0/keys
    echo -e "client \ndev tun \nproto udp \nremote $public_ip 1194 \nresolv-retry infinite \nnobind \npersist-key \npersist-tun \nca ca.crt \ncert ${keyname}.crt \nkey
 ${keyname}.key \nremote-cert-tls server \ncomp-lzo \nverb 3" > client.ovpn

        echo -e "\033[32m 打包证书 \033[0m"
    tar -zcvf ${keyname}.tar.gz ca.* ${keyname}.crt ${keyname}.key client.ovpn

        echo -e "\033[32m 下载证书 \033[0m" 
        sz ${keyname}.tar.gz
}

echo -e "\033[31m\n----选择你想安装的软件----\033[0m \n"
echo -e "\033[32m \"0. initialize_system(优化系统)\" input \"0\" \033[0m \n"
echo -e "\033[32m \"1. Nginx for latest\" input \"1\" \033[0m \n"
echo -e "\033[32m \"2. php7.1\" input \"2\" \033[0m \n"
echo -e "\033[32m \"3. mysql5.7\" input \"3\" \033[0m \n"
echo -e "\033[32m \"4. modify ssh port to 8622\" input \"4\" \033[0m \n"
echo -e "\033[32m \"5. add ssh-key\" input \"5\" \033[0m \n"
echo -e "\033[32m \"6. install mongodb4\" input \"6\" \033[0m \n"
echo -e "\033[32m \"7. install mysql5.6\" input \"7\" \033[0m \n"
echo -e "\033[32m \"8. install php7.2\" input \"8\" \033[0m \n"
echo -e "\033[32m \"9. install redis5.0\" input \"9\" \033[0m \n"
echo -e "\033[32m \"10. install openvpn2.2\" input \"10\" \033[0m \n"
echo -e "\033[32m \"11. create openvpn客户端证书\" input \"11\" \033[0m \n"
read -p "please choice which software do you want to install ?" input

case "$input" in
        0)      initialize_system;
                ;;
        1)      install_nginx;
                ;;
        2)  	install_php71;
                ;;
        3)      install_mysql57;
                ;;
        4)      modify_ssh;
                ;;
        5)      add_ssh_key;
                ;;
        6)      install_mongodb4;
                ;;
        7)      install_mysql56;
                ;;
        8)      install_php72;
                ;;
        9)      install_redis50;
                ;;
        10)     install_openvpn;
                ;;
        11) 	create_openvpn_client_key;
                ;;
        *)
                echo -e "\033[31m Input Error! \033[0m" && exit -1;;
esac