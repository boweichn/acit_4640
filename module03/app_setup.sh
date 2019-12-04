#!/bin/bash -
useradd admin
echo "admin:P@ssw0rd"|chpasswd
usermod -g wheel admin
id -G -n admin

sed -r -i 's/^(%wheel\s+ALL=\(ALL\)s+)(ALL)$/\1NOPASSWD: ALL/' /etc/sudoers

mkdir /home/admin/.ssh/

curl 'https://acit4640.y.vu/docs/module02/resources/acit_admin_id_rsa.pub' >> /home/admin/.ssh/authorized_keys

chown -R admin:admin /home/admin/.ssh

yum -y install epel-release vim git tcpdump curl net-tools bzip2
yum -y update

setenforce 0
sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config

useradd -m -r todo-app && passwd -l todo-app

yum -y install nodejs npm
yum -y install mongodb-server

systemctl enable mongod && systemctl start mongod

sudo -u todo-app -- mkdir /home/todo-app/app

sudo -u todo-app -- git clone https://github.com/timoguic/ACIT4640-todo-app.git /home/todo-app/app
npm --prefix /home/todo-app/app install

sed -r -i 's/CHANGEME/acit4640/g' /home/todo-app/app/config/database.js

yum -y install jq
yum -y install nginx
yum -y install wget

wget http://192.168.250.200/support/nginx.conf -O /etc/nginx/nginx.conf
wget http://192.168.250.200/support/todoapp.service -O /lib/systemd/system/todoapp.service

systemctl enable nginx
systemctl start nginx
systemctl daemon-reload
systemctl enable todoapp
systemctl start todoapp

chmod -R 755 /home/todo-app
