#!/bin/bash

USER_NAME=tony

sed -i "s/.*RSAAuthentication.*/RSAAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i "s/.*AuthorizedKeysFile.*/AuthorizedKeysFile\t\.ssh\/authorized_keys/g" /etc/ssh/sshd_config
sed -i "s/.*PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
echo "${USER_NAME}      ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
service sshd restart

useradd -p "" $USER_NAME
passwd -fu $USER_NAME
sudo -u $USER_NAME mkdir /home/$USER_NAME/.ssh
sudo -u $USER_NAME chmod 700 /home/$USER_NAME/.ssh
sudo -u $USER_NAME ssh-keygen -t rsa -b 2048 -N "" -f /home/$USER_NAME/.ssh/id_rsa
cat /home/$USER_NAME/.ssh/id_rsa.pub > /home/$USER_NAME/.ssh/authorized_keys
chmod 600 /home/$USER_NAME/.ssh/authorized_keys
chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh/authorized_keys
