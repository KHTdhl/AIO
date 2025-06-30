#!/bin/bash

# 设置需要下载的文件 URL
proxy_list_url="https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt"
gfw_list_url="https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt"
direct_list_url="https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt"
cn_ip_cidr_url="https://raw.githubusercontent.com/Hackl0us/GeoIP2-CN/release/CN-ip-cidr.txt"

# 设置本地文件路径
geosite_cn_file="/etc/mosdns/geosite_cn.txt"
geoip_cn_file="/etc/mosdns/geoip_cn.txt"
geosite_geolocation_noncn_file="/etc/mosdns/geosite_geolocation_noncn.txt"
gfw_file="/etc/mosdns/gfw.txt"

# 下载并替换文件的函数
download_and_replace() {
    local url=$1
    local file=$2

    # 下载文件
    curl -s "$url" -o "$file.tmp"

    # 检查下载是否成功
    if [ $? -eq 0 ]; then
        # 用下载的文件替换原文件
        mv "$file.tmp" "$file"
        echo "文件 $file 更新成功。"
    else
        echo "下载 $file 失败。"
    fi
}

# 下载并替换文件
download_and_replace "$proxy_list_url" "$geosite_geolocation_noncn_file"
download_and_replace "$gfw_list_url" "$gfw_file"
download_and_replace "$direct_list_url" "$geosite_cn_file"
download_and_replace "$cn_ip_cidr_url" "$geoip_cn_file"

echo "所有文件更新完成。"