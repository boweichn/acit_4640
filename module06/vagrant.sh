setenforce 0
sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config
sudo useradd -m -r todo-app && passwd -l todo-app

sudo cp /home/admin/todoapp.service /lib/systemd/system/todoapp.service
sudo cp /home/admin/nginx.conf /etc/nginx/nginx.conf
sudo systemctl enable mongod && systemctl start mongod
sudo -u todo-app -- mkdir /home/todo-app/app

sudo git clone https://github.com/timoguic/ACIT4640-todo-app.git /home/todo-app/app
npm --prefix /home/todo-app/app install
sudo chown -R todo-app:todo-app /home/todo-app/app

sudo systemctl enable todoapp
sudo systemctl start todoapp
sudo systemctl restart nginx

sed -r -i 's/CHANGEME/acit4640/g' /home/todo-app/app/config/database.js
chmod -R 755 /home/todo-app