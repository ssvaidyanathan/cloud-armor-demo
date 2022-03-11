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
RED SERVER IS REACHABLE
*****************************
EOF
mkdir /usr/share/nginx/html/red
cp /usr/share/nginx/html/index.html /usr/share/nginx/html/red/
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
nginx -t && service nginx reload
apt-get -y install mysql-client-core-5.7
apt-get -y install apache2
service apache2 stop
service nginx status >> nginx.status
service apache2 status >> apache.status
cd /var/www/html
apt-get -y install git
git clone https://github.com/ethicalhack3r/DVWA.git
cp /var/www/html/DVWA/config/config.inc.php.dist /var/www/html/DVWA/config/config.inc.php
apt-get -y install libapache2-mod-php7.3 l php7.3-fpm php7.0 php-mysql php7.3-mbstring
apt-get -y install install php7.0-gd
chmod 777 /var/www/html/DVWA/hackable/uploads/
chmod 777 /var/www/html/DVWA/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt
chmod 777 /var/www/html/DVWA/config
