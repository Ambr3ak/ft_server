#!/bin/bash

apt-get install openssl

rm -rf /etc/nginx/sites-enabled/default
cp nginx.conf /etc/nginx/sites-enabled/

service nginx start
service nginx status
cd /etc/nginx/
mkdir ssl
cd ssl/
openssl req –new –newkey rsa:2048 –nodes –keyout localhost.key –out localhost.csr

tail -f /var/log/nginx/access.log /var/log/nginx/error.log
