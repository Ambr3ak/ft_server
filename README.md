# ft_server 42 project

"This topic aims to introduce you to system administration by making you aware of the importance of using scripts to automate your tasks. To do so, we will show you the "Docker" technology in order to have you install a complete web server, which will be able to run several services, such as Wordpress, Phpmyadmin, as well as a database".

### How to run the server ? 

```
docker build -t ft_server . 
docker run --name=ft_server -p 80:80 -p 443:443 -it --rm ft_server
```

### What is Docker ?

Docker is an open-source software for building applications in software containers. 

### What is a container ?

The main idea is to run isolated Linux environments in containers sharing the same kernel.
A container can run on any OS since it is completely isolated from the rest. 
Each Container is created from an existing (Docker Hub) or new Docker image.
An image can contain anything you want. 

### How to navigate in the container ?

The same shell commands are used to navigate through the different ones from the container.

:warning: To enter in the container :

``
docker exec -it monimage bash
``

## Dockerfile

A Dockerfile is a file that will allow you to run your image and include all the files you want.

Line 1 
```
FROM debian:buster
```

``FROM`` allows you to specify an existing image to be used as a basis and its version. In our case, Debian Buster.
After building and running our container, it will be based on the image of the Debian Buster OS.
Line 3 - 15 
```
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
```

``RUN`` enables orders to be executed in the container. In this way we install all the necessary packages to run our server.

ligne 17 - 21 
```
COPY srcs/nginx.conf .
COPY srcs/wp-config.php .
COPY srcs/autoindex.sh .
COPY srcs/nginx_auto.conf .
COPY srcs/entrypoint-container.sh .
```
              
To use external files in our container we add them at the root with the comand ``COPY``.

Line 23 ``EXPOSE 80 443``

``EXPOSE`` allows you to specify the listening port of the container.

Line 24 ``ENTRYPOINT ["bash", "entrypoint-container.sh"]``

``ENTRYPOINT`` specifies the order to be executed as soon as it runs the container. 

More specifies about Dockerfile : https://docs.docker.com/engine/reference/builder/

## Install LEMP

The LEMP software stack is a group of software that can be used to serve dynamic web pages and web applications. This is an acronym that describes a **L**inux operating system, with an **E**Nginx web server. The backend data is stored in the **M**ySQL database and the dynamic processing is handled by **P**HP.

La commande ``apt-get`` permet d'obtenir facilement les paquets nécessaires à notre installation.
On effectue toujours un ``apt-get update`` avant afin de récupérer les mises à jour des paquets.

### Nginx 

We install the Nginx package ``apt-get -y install nginx``.
Then start the service ``service nginx start``.

### MySql

MySql is a database, Phpmyadmin is a graphical representation of our My Sql database, it is therefore essential to install it.
``apt-get install -y mariadb-server``.
``service mysql start``.

The Phpmyadmin and Wordpress services need a database to work. We must provide it with a dbb name, a user and a password.
```
echo "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" | mysql -u root
echo "GRANT ALL ON wordpress.* TO 'wordpress_user'@'localhost' IDENTIFIED BY 'password';" | mysql -u root
echo "FLUSH PRIVILEGES;" | mysql -u root
```
A dedicated user name is used instead of the root in order to avoid having to re-set the password all the time and it's safer this way.

### PHP

As Nginx does not contain native PHP, it is necessary to install the PHP process manager called PHP FPM.
We run ``apt-get install -y php7.3 \
     php-cli \
     php-cgi \
     php-mbstring \
     php-fpm \
     php-mysql \ 
     php-json \``.
Then ``service php7.3-fpm start``.

### The config

It is necessary to reconfigure the default ngninx.conf file with our new configuration.
We don't forget to add index.php in our configuration which is not there by default. Necessary for our indexing.
```
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
rm -rf /etc/nginx/sites-enabled/default
cp nginx.conf /etc/nginx/sites-enabled/
```
## Phpmyadmin and Wordpress

We create the folder where the server will fetch its files. Here called ``/var/www/localhost``

By installing the wget package ``apt-get -y wget`` we will get from the official website the .tar.gz files required to activate our services.
Do not forget to unzip them ``tar -xvf file.tar.gz``.

### PHP

The file we are interested in is called phpMyAdmin-4.9.5-all-languages.tar.gz.
Once the previous steps have been completed, we mv it in the localhost folder.
```
mv phpMyAdmin-4.9.5-all-languages phpmyadmin
mv phpmyadmin /var/www/localhost/phpmyadmin
```

### Wordpress

The file we are interested in is calle latest-fr_FR.tar.gz.
Once the previous steps have been completed, we mv it in the localhost folder.
```
mkdir /var/www/localhost/wordpress
mv wordpress/* /var/www/localhost/wordpress
```
In order to be able to connect we must indicate a user and a password linked to our database.
We will create a new file wp-config.php with our information.

```
rm /var/www/localhost/wordpress/wp-config-sample.php
cp wp-config.php /var/www/localhost/wordpress
```

- define( 'DB_NAME', 'wordpress' ); :arrow_right: Data base name.

- define( 'DB_USER', 'wordpress_user' ); :arrow_right: User name.

- define( 'DB_PASSWORD', 'password' ); :arrow_right: Data base password.

- define( 'DB_HOST', 'localhost' ); :arrow_right: Host name of the db.

## SSL

SSL Certificates are small data files that digitally bind a cryptographic key to an organization’s details. When installed on a web server, it activates the padlock and the https protocol and allows secure connections from a web server to a browser. Typically, SSL is used to secure credit card transactions, data transfer and logins, and more recently is becoming the norm when securing browsing of social media sites.

We run ``apt-get -y install openssl``.

We create a folder to contain our certificats

``mkdir /etc/nginx/ssl``

Then run
```
openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out /etc/nginx/ssl/localhost.pem -keyout /etc/nginx/ssl/localhost.key -subj "/C=FR/ST=Paris/L=Paris/O=42 School/OU=ambre/CN=localhost"
```

For more specifies about the command : https://www.openssl.org/docs/man1.0.2/man1/openssl-req.html

## Logs and errors

``tail -f /var/log/nginx/access.log /var/log/nginx/error.log``

## Sources

- https://openclassrooms.com/fr/courses/2035766-optimisez-votre-deploiement-en-creant-des-conteneurs-avec-docker/6211517-creez-votre-premier-dockerfile

- https://www.youtube.com/watch?v=X3Pr5VATOyA

- https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mariadb-php-lemp-stack-on-debian-10

- https://howto.wared.fr/installation-wordpress-ubuntu-nginx/

- https://github.com/Emmabrdt/ft_server
