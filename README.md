# Fail2ban #
这是一个利用iptables和开源程序fail2ban来进行服务器简单防爆破的脚本。默认自带SSH防御规则。

# 功能 #
- 自助修改SSH端口
- 自定义最高封禁IP的时间（以小时为单位）
- 自定义SSH尝试连接次数
- 一键完成SSH防止暴力破解

# 安装 #
    wget https://raw.githubusercontent.com/ftfniqpl/tools/master/fail2ban.sh && bash fail2ban.sh 2>&1 | tee fail2ban.log
