#!/bin/bash

clear
#CheckIfRoot
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

fail2ban-client status ssh-iptables

fail2ban-client set ssh-iptables unbanip $1
fail2ban-client set sshd unbanip $1
