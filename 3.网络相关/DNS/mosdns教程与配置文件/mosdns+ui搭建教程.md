创建lxc容器模板
[下载地址](https://github.com/KHTdhl/rosrbgprouter/releases/download/v1.0.0/ubuntu-22.04-standard_22.04-1_amd64.1.tar.zst)

[电报群](https://t.me/+bzSRf6dtG3lhYWVl)
## 乌班图下载
```
/var/lib/vz/template/cache
#上传文件夹
```
## 容器创建
取消特权容器勾选
其他配置根据自己实际情况设定
## 容器优化
### 容器完善
创建完成后容器，不要开机，进入对应容器的选项
勾选一下选项
- 嵌套
- nfs
- smb
- fuse
### 容器配置文件
进入pve控制台，进入/etc/pve/lxc文件夹，修改对应的配置文件，添加以下内容
```
lxc.apparmor.profile: unconfined
lxc.cgroup.devices.allow: a
lxc.cap.drop: 
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```
### 开启第三方登录
```
nano /etc/ssh/sshd_config
service ssh restart
```
