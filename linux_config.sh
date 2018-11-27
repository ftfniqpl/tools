#!/bin/bash

clear
#CheckIfRoot
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

#CheckOS
[ -z $(which apt) ] && PKG=centos
[ -z $(which yum) ] && PKG=ubuntu

echo "os is: " $PKG

if [ $PKG == centos ]; then
    echo ""

    sed -i 's/zh_CN/en_US/g' /etc/locale.conf
    #sed -i -e 's/quiet/quiet net.ifnames=0 biosdevname=0/' /etc/default/grub
    #grub2-mkconfig -o /boot/grub2/grub.cfg

    bash -c 'cat << EOF >> /etc/security/limits.conf
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
EOF'

    yum install tree ssh vim wget curl net-tools git -y
    yum -y install ius-release-1.0-15.ius.centos7.noarch.rpm
    yum -y install python36u  python36u-devel python36u-pip
    yum -y install yum install python2-devel python2-pip

    pip install -U pip
    pip3 install -U pip
    pip install virtualenvwrapper
    pip3 install virtualenvwrapper
    yum install supervisor -y

    systemctl enable supervisor
    service supervisor restart

    echo "create user"

    read -p "input user account (default tony): " UserAccount
    [ -z ${UserAccount} ] && UserAccount=tony
    adduser $UserAccount
    passwd $UserAccount
    usermod -aG wheel $UserAccount

else
    sed -i 's/zh_CN/en_US/g' /etc/default/locale
    #sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 ipv6.disable=1"/' /etc/default/grub
    #grub-mkconfig -o /boot/grub/grub.cfg
    bash -c 'cat << EOF > /etc/default/rcS
UTC=yes
EOF'
    #restart timedatectl
    timedatectl set-local-rtc 1 --adjust-system-clock

    bash -c 'cat << EOF >> /etc/security/limits.conf
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
EOF'

    add-apt-repository ppa:jonathonf/python-3.6
    apt update
    apt install tree ssh vim wget curl net-tools git -y
    apt install python3.6 python3.6-dev python3.6-pip python-pip -y
    pip install -U pip
    pip3 install -U pip
    pip install virtualenvwrapper
    pip3 install virtualenvwrapper
    apt install supervisor -y

    systemctl enable supervisor
    service supervisor restart

    echo "create user"

    read -p "input user account (default tony): " UserAccount
    [ -z ${UserAccount} ] && UserAccount=tony
    adduser $UserAccount
    usermod -aG sudo $UserAccount

# disabled postfix.service
systemctl disable postfix.service
systemctl stop postfix.service

echo "switch user:" $UserAccount

su - $UserAccount

bash -c 'cat << EOF >> ~/.gitconfig
[core]
    editor = nano
[push]
    default = matching
EOF'

mkdir ~/.pip
bash -c 'cat << EOF >> ~/.pip/pip.conf
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
EOF'

bash -c 'cat << EOF >> ~/.bashrc

function git_branch {
    branch="\`git branch 2>/dev/null | grep "^\*" | sed -e "s/^\*\ //"\`"
    if [ "\${branch}" != "" ];then
    ¦   if [ "\${branch}" = "(no branch)" ];then
    ¦   ¦   branch="(\`git rev-parse --short HEAD\`...)"
    ¦   fi
    ¦   echo "(\$branch)"
    fi
}
export PS1='\''\u@:\w\[\033[01;32m\]\$(git_branch)\[\033[00m\]\\$ '\''

. `sudo find /usr -name virtualenvwrapper.sh`
EOF'

echo "base config end...."

read -p "Do you want add .vimrc [y/n], default n: " IfaddVIM
[ -z ${IfaddVIM} ] && IfaddVIM=n
if [ ${IfaddVIM} == 'y' ]; then
    BASEPATH=$(cd `dirname $0`; pwd)
    git clone https://github.com/ftfniqpl/dotfiles.git
    rm -rf ~/.vimrc ~/.vim
    ln -s $BASEPATH/dotfiles/.vimrc ~/.vimrc
    ln -s $BASEPATH/dotfiles/.vim ~/.vim
    sudo chown -R `whoami`. ~/.viminfo
fi
