#!/bin/bash

mkdir /etc/nginx/ssl
openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out /etc/nginx/ssl/localhost.pem -keyout /etc/nginx/ssl/localhost.key -subj "/C=FR/ST=Paris/L=Paris/O=42 School/OU=ambre/CN=localhost"

rm -rf /etc/nginx/sites-enabled/default
cp nginx.conf /etc/nginx/sites-enabled/

service nginx start
service nginx status
nginx -t

tail -f /var/log/nginx/access.log /var/log/nginx/error.log
