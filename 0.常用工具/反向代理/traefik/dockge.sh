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

# 输出正在修改文件的信息
echo "正在修改 compose.yaml 文件，添加 container_name: dockge"

# 检查是否已经定义了 container_name
if ! grep -q "container_name: dockge" "compose.yaml"; then
  # 如果没有定义，则添加 container_name 到 dockge 服务
  sed -i '/image:/i \ \ \ \ container_name: dockge' "compose.yaml"
  echo "已成功在 compose.yaml 中添加 container_name: dockge"
else
  echo "container_name 已经在文件中定义，跳过添加。"
fi

# 在 compose.yaml 文件末尾添加日志配置
echo "在 compose.yaml 文件末尾添加日志配置..."
echo -e "\n    logging:\n      driver: json-file\n      options:\n        max-size: 1m" >> "compose.yaml"

# 启动 Dockge
echo "正在使用 Docker Compose 启动 Dockge..."
sudo docker compose up -d

echo "Dockge 安装完成！"
