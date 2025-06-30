#!/bin/bash
# 定义最大重试次数
MAX_RETRIES=3

# 当前重试次数
RETRY_COUNT=0

apt update

apt install unzip curl -y

sleep 1

cd /home

FILE_NAME1="mosdns-linux-amd64.zip"

# 定义下载URL
DOWNLOAD_URL1="https://github.com/IrineSistiana/mosdns/releases/download/v5.3.1/$FILE_NAME1"


# 检查并删除已有的文件
if [ -f "$FILE_NAME1" ]; then
    echo "发现已有文件，删除它..."
    rm -f "$FILE_NAME1"
fi

download_and_install() {
    wget $DOWNLOAD_URL1
    if [ $? -eq 0 ]; then
        echo "下载成功。"
        return 0
    else
        echo "下载失败。"
        return 1
    fi
}

# 主循环，直到下载成功或达到最大重试次数
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    download_and_install
    if [ $? -eq 0 ]; then
        break
    else
        RETRY_COUNT=$((RETRY_COUNT+1))
        echo "重试第 $RETRY_COUNT 次..."
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "删除失败的文件并重新下载..."
            rm -f $FILE_NAME1
        fi
    fi
done

if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "下载失败，达到最大重试次数。"
    exit 1
fi


# 修改 resolved.conf 文件
echo "DNSStubListener=no" | sudo tee -a /etc/systemd/resolved.conf

sleep 1
# 重新加载或重新启动 systemd-resolved 服务
sudo systemctl reload-or-restart systemd-resolved

sleep 1

# 创建运行目录
echo "正在创建 /etc/mosdns 目录..."
mkdir /etc/mosdns
echo "创建 /etc/mosdns 目录成功!"

# 切换到home目录
echo "正在切换到 /home 目录..."
cd /home
echo "切换到 /home 目录成功!"

# 解压至指定目录
echo "正在解压 mosdns-linux-amd64.zip 到 /etc/mosdns..."
unzip mosdns-linux-amd64.zip -d /etc/mosdns
echo "解压 mosdns-linux-amd64.zip 到 /etc/mosdns 成功!"

sleep 1

# 进入运行文件夹
echo "正在切换到 /etc/mosdns 目录..."
cd /etc/mosdns
echo "切换到 /etc/mosdns 目录成功!"

# 赋予可执行权限
echo "正在设置 mosdns 的可执行权限..."
chmod +x mosdns
echo "设置 mosdns 的可执行权限成功!"

# 复制到存放自定义或第三方安装的可执行程序的文件夹
echo "正在将 mosdns 复制到 /usr/local/bin..."
cp mosdns /usr/local/bin
echo "将 mosdns 复制到 /usr/local/bin 成功!"

# 返回根目录
echo "正在切换到根目录 /"
cd /
echo "切换到根目录 / 成功!"

# 进入启动目录
echo "正在切换到 /etc/systemd/system/ 目录..."
cd /etc/systemd/system/
echo "切换到 /etc/systemd/system/ 目录成功!"

# 创建启动服务
echo "正在创建 mosdns.service 文件..."
touch mosdns.service
echo "创建 mosdns.service 文件成功!"

# 编辑启动文件内容
echo "正在编辑 mosdns.service 文件..."
cat << 'EOF' > mosdns.service
[Unit]
Description=mosdns daemon, DNS server.
After=network-online.target

[Service]
Type=simple
Restart=always
ExecStart=/usr/local/bin/mosdns start -c /etc/mosdns/config.yaml -d /etc/mosdns

[Install]
WantedBy=multi-user.target
EOF
echo "编辑 mosdns.service 文件成功!"

# 创建规则目录及文件
echo "正在创建 /etc/mosdns/rule 目录和文件..."
mkdir /etc/mosdns/rule
touch /etc/mosdns/rule/{whitelist,blocklist,greylist,ddnslist,hosts,redirect,adlist,localptr}.txt
echo "创建 /etc/mosdns/rule 目录和文件成功!"

# 切换到 /etc/mosdns/rule 目录
echo "正在切换到 /etc/mosdns/rule 目录..."
cd /etc/mosdns/rule

# 更新 blocklist.txt
echo "正在更新 blocklist.txt 文件..."
echo "keyword:.localdomain" > blocklist.txt
echo "domain:in-addr.arpa" >> blocklist.txt
echo "domain:ip6.arpa" >> blocklist.txt

# 更新 localptr.txt
echo "正在更新 localptr.txt 文件..."
echo "# block all PTR requests" > localptr.txt
echo "domain:in-addr.arpa" >> localptr.txt
echo "domain:ip6.arpa" >> localptr.txt

# 更新 whitelist.txt
echo "正在更新 whitelist.txt 文件..."
echo "domain:push-apple.com.akadns.net" > whitelist.txt
echo "domain:push.apple.com" >> whitelist.txt
echo "domain:iphone-ld.apple.com" >> whitelist.txt
echo "domain:lcdn-locator.apple.com" >> whitelist.txt
echo "domain:lcdn-registration.apple.com" >> whitelist.txt
echo "domain:cn-ssl.ls.apple.com" >> whitelist.txt
echo "domain:time.apple.com" >> whitelist.txt
echo "domain:store.ui.com.cn" >> whitelist.txt
echo "domain:amd.com" >> whitelist.txt
echo "domain:msftncsi.com" >> whitelist.txt
echo "domain:msftconnecttest.com" >> whitelist.txt
echo "domain:office.com" >> whitelist.txt
echo "domain:office365.com" >> whitelist.txt

echo "所有操作已完成!"



# 清除 /etc/mosdns/config.yaml 的内容
rm -f /etc/mosdns/config.yaml

curl -L https://github.com/KHTdhl/AIO/releases/download/v1.0/mosdns-config.yaml -o /etc/mosdns/config.yaml

sleep 1


echo "切换目录"
cd /etc/mosdns

touch {geosite_cn,geoip_cn,geosite_geolocation_noncn,gfw}.txt

curl -L https://github.com/KHTdhl/AIO/releases/download/v1.0/mos_rule_update.sh -o /etc/mosdns/mos_rule_update.sh


# 设置脚本为可执行
chmod +x mos_rule_update.sh

echo "脚本创建并写入完成，文件名为 mos_rule_update.sh，并已设置为可执行。"

sleep 1

echo "赋予可执行权限"

chmod +x mos_rule_update.sh

./mos_rule_update.sh

sleep 2

# 启用并立即启动 mosdns 服务
systemctl enable mosdns --now


# 设置时区为 Asia/Shanghai
timedatectl set-timezone Asia/Shanghai

# 定义要添加的 NTP 服务器配置
ntp_config="NTP=ntp.aliyun.com"

# 将配置追加到 systemd-timesyncd 配置文件末尾
echo "$ntp_config" | sudo tee -a /etc/systemd/timesyncd.conf > /dev/null

# 重新加载 systemd-timesyncd 服务配置
sudo systemctl daemon-reload

# 重启 systemd-timesyncd 服务使更改生效
sudo systemctl restart systemd-timesyncd

# 输出完成信息
echo "已将 NTP 服务器配置为 ntp.aliyun.com，并设置时区为 Asia/Shanghai。"

cd /home

FILE_NAME2="loki_3.1.0_amd64.deb"

# 定义下载URL
DOWNLOAD_URL2="https://github.com/grafana/loki/releases/download/v3.1.0/$FILE_NAME2"


# 检查并删除已有的文件
if [ -f "$FILE_NAME2" ]; then
    echo "发现已有文件，删除它..."
    rm -f "$FILE_NAME2"
fi

download_and_install() {
    wget $DOWNLOAD_URL2
    if [ $? -eq 0 ]; then
        echo "下载成功。"
        return 0
    else
        echo "下载失败。"
        return 1
    fi
}

# 主循环，直到下载成功或达到最大重试次数
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    download_and_install
    if [ $? -eq 0 ]; then
        break
    else
        RETRY_COUNT=$((RETRY_COUNT+1))
        echo "重试第 $RETRY_COUNT 次..."
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "删除失败的文件并重新下载..."
            rm -f $FILE_NAME2
        fi
    fi
done

if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "下载失败，达到最大重试次数。"
    exit 1
fi


dpkg -i loki_3.1.0_amd64.deb    

# 安装必需的软件包
sudo apt-get install -y adduser libfontconfig1 musl  > /dev/null 2>&1

# 检查 Grafana 安装是否成功
if [ $? -eq 0 ]; then
    echo "安装必需的软件包已安装完成。"
else
    echo "安装必需的软件包安装失败。"
fi

# 下载并安装 Grafana Enterprise
# 定义文件名
FILE_NAME3="grafana-enterprise_11.0.0_amd64.deb"

# 定义下载URL
DOWNLOAD_URL3="https://dl.grafana.com/enterprise/release/$FILE_NAME3"


# 检查并删除已有的文件
if [ -f "$FILE_NAME3" ]; then
    echo "发现已有文件，删除它..."
    rm -f "$FILE_NAME3"
fi

download_and_install() {
    wget $DOWNLOAD_URL3
    if [ $? -eq 0 ]; then
        echo "下载成功。"
        return 0
    else
        echo "下载失败。"
        return 1
    fi
}

# 主循环，直到下载成功或达到最大重试次数
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    download_and_install
    if [ $? -eq 0 ]; then
        break
    else
        RETRY_COUNT=$((RETRY_COUNT+1))
        echo "重试第 $RETRY_COUNT 次..."
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "删除失败的文件并重新下载..."
            rm -f $FILE_NAME3
        fi
    fi
done

if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "下载失败，达到最大重试次数。"
    exit 1
fi



sudo dpkg -i grafana-enterprise_11.0.0_amd64.deb  > /dev/null 2>&1

# 检查 Grafana 安装是否成功
if [ $? -eq 0 ]; then
    echo "Grafana 已安装完成。"
else
    echo "Grafana 安装失败。"
fi

# 重新加载 systemd 并启用/启动 Grafana 服务器
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

sleep 3



sudo apt-get install -y prometheus> /dev/null 2>&1

# 检查安装是否成功
if [ $? -eq 0 ]; then
    echo "Prometheus 已安装完成。"
else
    echo "Prometheus 安装失败。"
fi

# 添加 mosdns 任务配置
cat << EOF | sudo tee -a /etc/prometheus/prometheus.yml
  - job_name: mosdns
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:8338']
EOF

# 重启 Prometheus
sudo systemctl restart prometheus

curl --proto '=https' --tlsv1.2 -sSfL https://sh.vector.dev | bash -s -- -y > /dev/null 2>&1

# 检查 Grafana 安装是否成功
if [ $? -eq 0 ]; then
    echo "vector已安装完成。"
else
    echo "vector安装失败。"
fi


rm -f /root/.vector/config/vector.yaml

curl -L https://github.com/KHTdhl/AIO/releases/download/v1.0/vector.yaml -o /root/.vector/config/vector.yaml

cd /etc/systemd/system/

touch vector.service

cat << 'EOF' > vector.service
[Unit]
Description=Vector Service
After=network.target

[Service]
Type=simple
User=root
ExecStartPre=/bin/sleep 10
ExecStartPre=/bin/mkdir -p /tmp/vector
ExecStart=/root/.vector/bin/vector --config /root/.vector/config/vector.yaml
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload

sudo systemctl enable vector

echo "Vector 配置文件已更新"

(crontab -l 2>/dev/null; echo "0 0 * * 0 sudo truncate -s 0 /etc/mosdns/mosdns.log && /etc/mosdns/mos_rule_update.sh") | crontab -

echo "定时更新规则与清理日志添加完成"

local_ip=$(hostname -I | awk '{print $1}')

# 打印 IP 地址
echo "机器将在5秒后重启，重启后打开：$local_ip:3000,进入ui管理界面，后续参考文字教程"

sleep 6

reboot