#! /bin/bash
sudo -i
apt-get -y update
apt-get install -y nginx
rm /etc/nginx/sites-available/default
tee /etc/nginx/sites-available/default > /dev/null <<EOF 
server {
        listen 80 default_server;
        root /usr/share/nginx/html;
        index index.html index.htm;
        server_name localhost;
        location / {
                try_files \$uri \$uri/ =404;
        }
}
EOF
rm /usr/share/nginx/html/index.*
tee /usr/share/nginx/html/index.html > /dev/null <<EOF
*****************************
BLUE SERVER IS REACHABLE
*****************************
EOF
mkdir /usr/share/nginx/html/blue
cp /usr/share/nginx/html/index.html /usr/share/nginx/html/blue/
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
nginx -t && service nginx reload
