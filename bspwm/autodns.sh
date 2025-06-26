#!/bin/bash

# 定义要检查的 IP 地址
CHECK_IP="100.100.100.100"
# 定义 resolv.conf 文件路径
RESOLV_CONF="/etc/resolv.conf"

while true; do
  # 使用 grep -q 来安静地检查 IP 是否存在
  # 如果 IP 不存在 (grep 返回非 0 值)，则执行 if 块
  if ! grep -q "$CHECK_IP" "$RESOLV_CONF"; then
    echo "$(date): $CHECK_IP 未在 $RESOLV_CONF 中找到。正在重启 Tailscale 并接受 DNS..."
    # 使用 sudo 执行 tailscale 命令
    sudo tailscale down
    sudo tailscale up --accept-dns=true
    echo "$(date): Tailscale 已重启。"
  else
    # 如果 IP 存在，则不执行任何操作 (或者可以取消注释下面的行进行记录)
    # echo "$(date): $CHECK_IP 已找到。无需操作。"
    : # bash 中的 'no-op' (无操作) 命令
  fi

  # 等待 30 秒
  sleep 120
done
