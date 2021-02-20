#!/bin/bash

if [ "$1" == "true" ]; then
    echo "Auto-Index ON"
    sudo rm -rf /etc/nginx/sites-enabled/nginx.conf
    sudo mv nginx_auto.conf /etc/nginx/sites-enabled/
fi
if [ "$1" == "false" ]; then
    echo "Auto-Index OFF"
    sudo rm -rf /etc/nginx/sites-enabled/nginx_auto.conf
    sudo mv nginx.conf /etc/nginx/sites-enabled/
fi
service nginx reload
service nginx restart