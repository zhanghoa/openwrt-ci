#!/bin/bash
# 切换到 OpenWrt 源码目录（由工作流预先 cd 进入）

set -e   # 遇到错误立即退出，便于定位问题

# 生成完整的防火墙配置文件（包含默认区域 + 自定义 WAN 访问规则）
mkdir -p files/etc/config
cat > files/etc/config/firewall << "EOF"
config defaults
    option synflood_protect '1'
    option input 'ACCEPT'
    option output 'ACCEPT'
    option forward 'REJECT'

config zone
    option name 'lan'
    option input 'ACCEPT'
    option output 'ACCEPT'
    option forward 'ACCEPT'
    option network 'lan'

config zone
    option name 'wan'
    option input 'REJECT'
    option output 'ACCEPT'
    option forward 'REJECT'
    option masq '1'
    option mtu_fix '1'
    option network 'wan wan6'

config rule
    option name 'Allow-WAN-SSH'
    option src 'wan'
    option proto 'tcp'
    option dest_port '22'
    option target 'ACCEPT'

config rule
    option name 'Allow-WAN-HTTP'
    option src 'wan'
    option proto 'tcp'
    option dest_port '80'
    option target 'ACCEPT'

config rule
    option name 'Allow-WAN-HTTPS'
    option src 'wan'
    option proto 'tcp'
    option dest_port '443'
    option target 'ACCEPT'

config rule
    option name 'Allow-WAN-Ping'
    option src 'wan'
    option proto 'icmp'
    option icmp_type 'echo-request'
    option target 'ACCEPT'
EOF

# 更新 feeds（确保其他包依赖正常）
./scripts/feeds update -a
./scripts/feeds install -a
