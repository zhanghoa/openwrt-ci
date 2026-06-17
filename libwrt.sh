#!/bin/bash
# 切换到 OpenWrt 源码目录（由工作流预先 cd 进入）

set -e   # 遇到错误立即退出，便于定位问题

echo "🧱 开始写入自定义有线防火墙配置 (WAN侧放行 SSH/HTTP/HTTPS/Ping)..."

# 确保在 openwrt/ 源码树根目录下创建标准的 files 结构
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

echo "✅ 防火墙规则应用成功，跳过重复的 feeds 刷新，移交工作流下一步。"
