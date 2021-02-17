#!/bin/bash

rm -rf /etc/nginx/sites-enabled/default
cp nginx.conf /etc/nginx/sites-enabled/

service nginx start
service nginx status
tail -f /var/log/nginx/access.log /var/log/nginx/error.log
