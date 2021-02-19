#!/bin/bash

mkdir /var/www/localhost

#mySQL
service mysql start
echo "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" | mysql -u root
echo "GRANT ALL ON wordpress.* TO 'wordpress_user'@'localhost' IDENTIFIED BY 'password';" | mysql -u root
echo "FLUSH PRIVILEGES;" | mysql -u root


#CERTIFICAT SSL

mkdir /etc/nginx/ssl
openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out /etc/nginx/ssl/localhost.pem -keyout /etc/nginx/ssl/localhost.key -subj "/C=FR/ST=Paris/L=Paris/O=42 School/OU=ambre/CN=localhost"

#NGINX
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
rm -rf /etc/nginx/sites-enabled/default
cp nginx.conf /etc/nginx/sites-enabled/

#PHPmyadmin
wget https://files.phpmyadmin.net/phpMyAdmin/4.9.5/phpMyAdmin-4.9.5-all-languages.tar.gz
tar -zxvf phpMyAdmin-4.9.5-all-languages.tar.gz
mv phpMyAdmin-4.9.5-all-languages phpmyadmin
mv phpmyadmin /var/www/localhost/phpmyadmin

#WORDPRESS
wget http://fr.wordpress.org/latest-fr_FR.tar.gz
tar -xzvf latest-fr_FR.tar.gz
mkdir /var/www/localhost/wordpress
mv wordpress/* /var/www/localhost/wordpress
rm /var/www/localhost/wordpress/wp-config-sample.php
cp wp-config.php /var/www/localhost/wordpress

#START
service php7.3-fpm start
service nginx start
service mysql restart
nginx -t


tail -f /var/log/nginx/access.log /var/log/nginx/error.log
