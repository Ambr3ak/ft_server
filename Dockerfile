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

COPY nginx.conf .
COPY wp-config.php .
COPY autoindex.sh .
COPY nginx_auto.conf .
COPY container_entrypoint.sh .


EXPOSE 80 443
ENTRYPOINT ["bash", "container_entrypoint.sh"]