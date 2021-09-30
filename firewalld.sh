#!/bin/bash

yum install -y firewalld

#作用：批量对多个IP地址开发多个端口号策略

#ips="192.168.2.1 192.168.1.0/24"
#ports"22 3306 8080-8090"
ports="4082-4085"

systemctl start firewalld
systemctl enable firewalld

#禁止ICMP
firewall-cmd --permanent --add-rich-rule='rule protocol value=icmp drop'
#添加VNC端口
firewall-cmd --permanent --add-port=5900-7000/tcp

for i in $ips
do
    for j in $ports
    do
        firewall-cmd --add-rich-rule="rule family="ipv4" source address="$i" port protocol="tcp" port="$j" accept" --permanent
    done
    echo $i done
    echo
done

firewall-cmd --reload
