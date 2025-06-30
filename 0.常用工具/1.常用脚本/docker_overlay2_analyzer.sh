#!/bin/bash
#这是一个分析docker容器关联文件夹大小的脚本，分析内容从大到小排列
DOCKER_DIR="/var/lib/docker"
OVERLAY2_DIR="$DOCKER_DIR/overlay2"

echo "分析 Docker overlay2 空间使用情况..."
echo

# 先收集信息，格式：大小\t容器名称\t容器ID\toverlay2目录
data_file=$(mktemp)

for cid in $(docker ps -aq); do
  cname=$(docker inspect --format '{{.Name}}' "$cid" 2>/dev/null | sed 's/^\/\(.*\)/\1/')
  merged_dir=$(docker inspect --format '{{.GraphDriver.Data.MergedDir}}' "$cid" 2>/dev/null)

  if [[ -n "$merged_dir" && "$merged_dir" == *overlay2* ]]; then
    overlay_subdir=$(basename $(dirname "$merged_dir"))
    overlay_dir="$OVERLAY2_DIR/$overlay_subdir"

    if [ -d "$overlay_dir" ]; then
      size=$(du -s "$overlay_dir" 2>/dev/null | awk '{print $1}') # 单位是KB数值，方便排序
      echo -e "$size\t$cname\t$cid\t$overlay_subdir" >> "$data_file"
    else
      echo -e "0\t$cname\t$cid\t$overlay_subdir" >> "$data_file"
    fi
  else
    echo -e "0\t$cname\t$cid\t无overlay2目录" >> "$data_file"
  fi
done

# 输出表头
printf "%-10s %-20s %-15s %-50s %s\n" "大小(GB)" "容器名称" "容器ID" "overlay2目录" "状态"
echo "-----------------------------------------------------------------------------------------------------------------------"

# 按大小倒序排序并格式化输出
sort -nrk1 "$data_file" | while IFS=$'\t' read -r size cname cid overlay; do
  size_gb=$(awk "BEGIN {printf \"%.2f\", $size/1024/1024}") # 转换成GB
  status="正常"
  if [[ "$overlay" == "无overlay2目录" ]]; then
    status="无overlay2目录信息"
  elif [[ "$size" -eq 0 ]]; then
    status="目录不存在或空"
  fi
  printf "%-10s %-20s %-15s %-50s %s\n" "$size_gb" "$cname" "$cid" "$overlay" "$status"
done

rm "$data_file"

echo
echo "分析完成。"
