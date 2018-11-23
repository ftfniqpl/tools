#!/bin/bash

clear
#CheckIfRoot
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }


#ReadSSHPort
[ -z "`grep ^Port /etc/ssh/sshd_config`" ] && ssh_port=22 || ssh_port=`grep ^Port /etc/ssh/sshd_config | awk '{print $2}'`

#CheckOS
[ -z "$(which apt)" ] && PKG=yum
[ -z "$(which yum)" ] && PKG=apt

echo $PKG

#Read Imformation From The User
echo "Welcome to Fail2ban!"
echo "--------------------"
echo ""

while :; do echo
    read -p "Do you want to change your SSH Port? [y/n], default n: " IfChangeSSHPort
    [ -z ""${IfChangeSSHPort} ] && IfChangeSSHPort='n'
    if [ ${IfChangeSSHPort} == 'y' ]; then
        if [ -e "/etc/ssh/sshd_config" ];then
            [ -z "`grep ^Port /etc/ssh/sshd_config`" ] && ssh_port=22 || ssh_port=`grep ^Port /etc/ssh/sshd_config | awk '{print $2}'`
            while :; do echo
                read -p "Please input SSH port(Default: $ssh_port): " SSH_PORT
                [ -z "$SSH_PORT" ] && SSH_PORT=$ssh_port
                if [ $SSH_PORT -eq 22 >/dev/null 2>&1 -o $SSH_PORT -gt 1024 >/dev/null 2>&1 -a $SSH_PORT -lt 65535 >/dev/null 2>&1 ];then
                    break
                else
                    echo "${CWARNING}input error! Input range: 22,1025~65534${CEND}"
                fi
            done
            if [ -z "`grep ^Port /etc/ssh/sshd_config`" -a "$SSH_PORT" != '22' ];then
                sed -i "s@^#Port.*@&\nPort $SSH_PORT@" /etc/ssh/sshd_config
            elif [ -n "`grep ^Port /etc/ssh/sshd_config`" ];then
                sed -i "s@^Port.*@Port $SSH_PORT@" /etc/ssh/sshd_config
            fi
            ssh_port=$SSH_PORT
        fi
        break
    elif [ ${IfChangeSSHPort} == 'n' ]; then
        break
    fi
done
echo ""
read -p "Input the maximun times for trying [2-10], default 3: " maxretry
[ -z "${maxretry}" ] && maxretry=3

echo ""
read -p "Input the lasting time for blocking a IP [hours], default 24: " bantime
[ -z "${bantime}" ] && bantime=24
((bantime=$bantime*60*60))
echo $bantime
#Install
if [ $PKG == yum ]; then
    yum -y install epel-release
    yum -y install fail2ban
else
    apt-get -y update
    apt-get -y install fail2ban
fi

#Configure
rm -rf /etc/fail2ban/jail.local
touch /etc/fail2ban/jail.local
if [ $PKG == yum ]; then
cat <<EOF >> /etc/fail2ban/jail.local
[DEFAULT]
ignoreip = 127.0.0.1
bantime = 86400
maxretry = $maxretry
findtime = 300
[ssh-iptables]
enabled = true
filter = sshd
action = iptables[name=SSH, port=$ssh_port, protocol=tcp]
logpath = /var/log/secure
maxretry = $maxretry
findtime = 300
bantime = $bantime
EOF
else
cat <<EOF >> /etc/fail2ban/jail.local
[DEFAULT]
ignoreip = 127.0.0.1
bantime = 86400
maxretry = $maxretry
findtime = 1800
[ssh-iptables]
enabled = true
filter = sshd
action = iptables[name=SSH, port=$ssh_port, protocol=tcp]
logpath = /var/log/auth.log
maxretry = $maxretry
findtime = 300
bantime = $bantime
EOF
fi

#Start
if [ $PKG == yum ]; then
    systemctl restart fail2ban
    systemctl enable fail2ban
else
    service fail2ban restart
    update-rc.d nginx enable
fi

echo "config firewalld"

if [ $PKG == yum ]; then
    systemctl enable firewalld.service
    systemctl start firewalld.service

    firewall-cmd --permanent --add-port=$ssh_port/tcp --zone=public
    firewall-cmd --reload
else
    ufw enable
    ufw default deny
    ufw allow $ssh_port/tcp
fi

#Finish
echo "Finish Installing ! Reboot the sshd now !"

if [ $PKG == yum ]; then
    systemctl restart sshd
else
    service ssh restart
fi

echo "Fail2ban is now runing on this server now!"


