# ft_server 42 project

Ce sujet à pour but de vous faire découvrir l’administration système en vous
sensibilisant a l’importance de l’utilisation de scripts pour automatiser vos taches. Pour ce
faire, nous allons vous faire découvrir la technologie "Docker" afin de vous faire installer
un server web complet, qui sera capable de faire tourner plusieurs services, tel qu’un
Wordpress, Phpmyadmin, ainsi qu’une base de donnée.

### Comment lancer le serveur ? 

```
docker build -t ft_server . 
docker run --name=ft_server -p 443:443 -it --rm ft_server
```

### Qu'est ce que Docker ?

Docker est un logiciel libre permettant de lancer des applications dans des conteneurs logiciels. 

### Qu'est ce qu'un conteneur ?

Le principe est de faire tourner des environnements Linux isolés dans des conteneurs partageants le meme noyau.
Un conteneur peut tourner sur n'importe quel OS puisqu'il est complément isolé du reste. 
Chaque conteneur est créé a partir d'une image Docker, existante (Docker Hub) ou vierge.
Une image peut contenir tout ce que l'on désire.

### Comment naviguer dans le conteneur ?

Pour naviguer dans les différentes partir du conteneur, on utilise les mêmes commandes shell.

:warning: Pour entrer dans le conteneur :

``
docker exec -it monimage bash
``

## Le Dockerfile

Le Dockerfile est un fichier qui va permettre de lancer son image et d'y inclure tous les fichiers que l'on souhaite.

Ligne 1 
```
FROM debian:buster
```

``FROM`` permet de spécifier une image existante sur laquelle on veut se baser ainsi que sa version. Dans notre cas, Debian Buster.
Apres avoir build et run notre conteneur, il sera basé sur l'image de l'OS Debian Buster.

Ligne 3 - 15 
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

``RUN`` permet d'executer des commandes dans le conteneur. Ainsi on installe tous les paquets nécessaires à faire tourner notre serveur.

ligne 17 - 21 
```
COPY srcs/nginx.conf .
COPY srcs/wp-config.php .
COPY srcs/autoindex.sh .
COPY srcs/nginx_auto.conf .
COPY srcs/entrypoint-container.sh .
```
              
Pour utiliser des fichiers extérieurs dans notre conteneur on les ajoute à la racine avec la commande ``COPY``.

Ligne 23 ``EXPOSE 80 443``

``EXPOSE`` permet de preciser le port d'écoute du conteneur.

Ligne 24 ``ENTRYPOINT ["bash", "entrypoint-container.sh"]``

``ENTRYPOINT`` ici précise la commande à lancer dès l’entrée dans le conteneur. 

Pour plus de précisions sur les commandes Dockerfile : https://docs.docker.com/engine/reference/builder/

## Installer LEMP

LEMP est un pack pratique à l’installation de serveur web. Son acronyme signifie **L**inux, **E**(nginx), **M**ariadb (base de donnée MySql) et **P**hp.

La commande ``apt-get`` permet d'obtenir facilement les paquets nécessaires à notre installation.
On effectue toujours un ``apt-get update`` avant afin de récupérer les mises à jour des paquets.

### Nginx 

On installe le paquet Nginx ``apt-get -y install nginx``.
Pour lancer le service ``service nginx start``.

### MySql

MySql est une base de données, Phpmyadmin est une représentation graphique de notre base de données My Sql, il est donc indispensable de l'installer.
On lance ``apt-get install -y mariadb-server``.
Puis ``service mysql start``.

Les services Phpmyadmin et Wordpress ont besoin d'une base de données pour fonctionner. On doit donc lui indiquer un nom de dbb, un user et un mot de passe.
```
echo "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" | mysql -u root
echo "GRANT ALL ON wordpress.* TO 'wordpress_user'@'localhost' IDENTIFIED BY 'password';" | mysql -u root
echo "FLUSH PRIVILEGES;" | mysql -u root
```
On utilise un nom de user dedié plutôt que le root afin d'éviter d'avoir à remettre le mot de passe tout le temps et c'est ainsi plus securisé.

### PHP

Nginx ne contenant pas PHP en natif, il est nécessaire d’installer le gestionnaire de processus PHP appelé PHP FPM.
On lance ``apt-get install -y php7.3 \
     php-cli \
     php-cgi \
     php-mbstring \
     php-fpm \
     php-mysql \ 
     php-json \``.
Puis ``service php7.3-fpm start``.

### La configuration

Il est obligatoire de reconfigurer le fichier par defaut en ngninx.conf avec notre nouvelle configuration. 
On n'oublie pas d'ajouter index.php dans notre configuration qui n'y est pas par défaut.
```
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
rm -rf /etc/nginx/sites-enabled/default
cp nginx.conf /etc/nginx/sites-enabled/
```
## Phpmyadmin et Wordpress

On crée le dossier dans lequel le serveur ira chercher ses fichiers. Ici appelé ``/var/www/localhost``

En installant de pack wget ``apt-get -y wget`` on récupérera depuis le site officiel les fichiers .tar.gz nécessaires à l'activation de nos services.
Ne pas oublier de les décompresser ``tar -xvf fichier.tar.gz``.

### PHP

Le fichier qui nous intéresse s'appelle phpMyAdmin-4.9.5-all-languages.tar.gz.
Une fois les precedentes etapes effectuées, on le mv dans le dossier localhost.
```
mv phpMyAdmin-4.9.5-all-languages phpmyadmin
mv phpmyadmin /var/www/localhost/phpmyadmin
```

### Wordpress

Le fichier qui nous intéresse s'appelle latest-fr_FR.tar.gz.
Une fois les precedentes etapes effectuées, on mv dans nouveau dossier wordpress dans localhost.
```
mkdir /var/www/localhost/wordpress
mv wordpress/* /var/www/localhost/wordpress
```
Pour pouvoir se connecter il faut indiqué un user ainsi qu'un mot de passe lié à notre bdd.
On va créer un nouveau fichier wp-config.php avec notre information.
```
rm /var/www/localhost/wordpress/wp-config-sample.php
cp wp-config.php /var/www/localhost/wordpress
```

- define( 'DB_NAME', 'wordpress' ); :arrow_right: Nom de la base de donnée

- define( 'DB_USER', 'wordpress_user' ); :arrow_right: Nom du user

- define( 'DB_PASSWORD', 'password' ); :arrow_right: Mot de passe de la bdd

- define( 'DB_HOST', 'localhost' ); :arrow_right: nom d'hôte du serveur de votre base de donnée

## SSL

Un certificat SSL est un fichier de données qui lie une clé cryptographique aux informations d'une organisation. Installé sur un serveur, le certificat active le cadenas et le protocole « https » (port 443 par défaut), afin d'assurer une connexion sécurisée entre le serveur web et le navigateur.

On lance ``apt-get -y install openssl``.

On crée un dossier qui va contenir nos certificats. 
``mkdir /etc/nginx/ssl``

Puis on lance 
```
openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out /etc/nginx/ssl/localhost.pem -keyout /etc/nginx/ssl/localhost.key -subj "/C=FR/ST=Paris/L=Paris/O=42 School/OU=ambre/CN=localhost"
```

- -x509 :arrow_right: Genère un certificat autosigné.
- -days 365 :arrow_right: Spécifie le nombre de jours que le certificat sera valable.

Pour plus de précisions sur les options de commande : https://www.openssl.org/docs/man1.0.2/man1/openssl-req.html

## La gestion des logs et des erreurs de logs

``tail -f /var/log/nginx/access.log /var/log/nginx/error.log``

## Mes sources

- https://openclassrooms.com/fr/courses/2035766-optimisez-votre-deploiement-en-creant-des-conteneurs-avec-docker/6211517-creez-votre-premier-dockerfile

- https://www.youtube.com/watch?v=X3Pr5VATOyA

- https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mariadb-php-lemp-stack-on-debian-10

- https://howto.wared.fr/installation-wordpress-ubuntu-nginx/

- https://github.com/Emmabrdt/ft_server
