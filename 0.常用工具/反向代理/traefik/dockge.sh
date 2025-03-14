#!/bin/bash

set -e  # 发生错误时退出脚本

# 更新系统包列表
echo "正在更新软件包列表..."
sudo apt update -y

# 安装 curl（如果未安装）
echo "正在安装 curl..."
sudo apt install -y curl

# 下载并安装 Docker
echo "正在下载 Docker 安装脚本..."
curl -fsSL https://get.docker.com -o get-docker.sh
echo "正在安装 Docker..."
sudo sh get-docker.sh

# 创建目录
echo "正在创建必要的目录..."
sudo mkdir -p /opt/stacks /opt/dockge

# 进入 Dockge 目录
echo "切换到 /opt/dockge 目录..."
cd /opt/dockge

# 下载 Dockge 的 docker-compose 配置文件
echo "正在下载 Dockge 的 compose.yaml 配置文件..."
curl -fsSL https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml -o compose.yaml

# 启动 Dockge
echo "正在使用 Docker Compose 启动 Dockge..."
sudo docker compose up -d

echo "Dockge 安装完成！"
