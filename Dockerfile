FROM debian:buster

RUN apt-get -y update && apt-get -y install mariadb-server \
     wget \
     php7.3 \
     php-cli \
     php-cgi \
     php-mbstring \
     php-fpm \
     php-mysql \ 
     php-json \
     sudo \
     nginx \
     libnss3-tools
RUN apt-get install openssl

COPY srcs/nginx.conf .
COPY srcs/wp-config.php .
COPY srcs/autoindex.sh .
COPY srcs/nginx_auto.conf .
COPY srcs/entrypoint-container.sh .


EXPOSE 80 443
ENTRYPOINT ["bash", "entrypoint-container.sh"]