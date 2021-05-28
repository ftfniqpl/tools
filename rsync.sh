#!/bin/bash

clear
#CheckIfRoot
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

#CheckOS
[ -z "$(which apt)" ] && PKG=centos
[ -z "$(which yum)" ] && PKG=ubuntu

if [ $PKG == centos ]; then
    yum -y install rsync
    cat <<EOF >> /etc/rsyncd.conf
motd file = /etc/rsyncd.motd #设置服务器信息提示文件名称，在该文件中编写提示信息
transfer logging = yes #开启Rsync数据传输日志功能
log file =/var/log/rsyncd.log #设置日志文件名称，可以通过log format参数设置日志格式
pid file =/var/run/rsyncd.pid #设置Rsync进程号保存文件名称
lock file =/var/run/rsync.lock #设置锁文件名称
port = 873 #设置服务器监听的端口号，默认为873
address = 192.168.0.254 #设置服务器所监听网卡接口的IP地址，这里服务器IP地址为192.168.0.254
uid = nobody #设置进行数据传输时所使用的账户名称或ID号，默认使用nobody
gid = nobody #设置进行数据传输时所使用的组名称或GID号，默认使用nobody
use chroot = no #设置user chroot为yes后，rsync会首先进行chroot设置，将根映射到path参数路径下，对客户端而言，系统的根就是path参数所指定的路径。但这样做需要root权限，并且在同步符号连接资料时仅会同步名称，而内容将不会同步。
read only = yes #是否允许客户端上传数据，这里设置为只读。
max connections = 10 #设置并发连接数，0代表无限制。超出并发数后，如果依然有客户端连接请求，则将会收到稍后重试的提示消息模块，Rsync通过模块定义同步的目录，模块以[name]的形式定义，这与Samba定义共享目录是一样的效果。在Rsync中也可以定义多个模块
[common]
comment = Web content #comment定义注释说明字串
path = /common #同步目录的真实路径通过path指定
ignore errors #忽略一些IO错误
#exclude = test/ #exclude可以指定例外的目录，即将common目录下的某个目录设置为不同步数据
auth users = tom,jerry #设置允许连接服务器的账户，账户可以是系统中不存在的用户
secrets file = /etc/rsyncd.secrets #设置密码验证文件名称，注意该文件的权限要求为只读，建议权限为600，仅在设置auth users参数后有效
hosts allow=192.168.0.0/255.255.255.0 #设置允许哪些主机可以同步数据，可以是单个IP，也可以是网段，多个IP与网段之间使用空格分隔
hosts deny=* #设置拒绝所有（除hosts allow定义的主机外）
list= false #客户端请求显示模块列表时，本模块名称是否显示，默认为true
EOF
    echo "tom:pass" > /etc/rsyncd.secrets
    chmod 600 /etc/rsyncd.secrets
    echo “welcome to access” >/etc/rsyncd.motd

    #rsync-vzrtopg --progress tom@192.168.0.254::common /tes
    systemctl start rsync
    systemctl enable rsync

else
    apt-get -y install rsync
    cat <<EOF >> /etc/rsyncd.conf
[backup]
# destination directory
path = /
# hosts you allow to access, allow all host
hosts allow = *
# deny all host
#hosts deny = *
list = true
# user permission
uid = root
#group permission
gid = root
#can write to this directory
read only = false
EOF
    systemctl start rsync
    systemctl enable rsync
fi




