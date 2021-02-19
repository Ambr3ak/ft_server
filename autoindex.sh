#!/bin/bash

if [ "$1" == "true" ]; then
    sudo rm -rf /etc/nginx/sites-enabled/nginx.conf
    sudo mv nginx_auto.conf /etc/nginx/sites-enabled/
fi
if [ "$1" == "false" ]; then
    sudo rm -rf /etc/nginx/sites-enabled/nginx_auto.conf
    sudo mv nginx.conf /etc/nginx/sites-enabled/
fi
service nginx restart