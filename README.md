# ft_server 42 project

Ce sujet à pour but de vous faire découvir découvrir l’administration système en vous
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

Principe est de faire tourner des env Linux isolés dans des conteneurs partageants le meme noyau.
Un conteneur peut tourner sur n'importe quel OS puisqu'il est complément isolé du reste. 
Chaque conteneur est créé a partir d'une image Docker, existante (Docker Hub) ou vierge.
Une image peut contenir tout ce que l'on désire.

### Comment naviguer dans le conteneur ?

Pour naviguer dans les differentes partir du conteneur, on utilise les mêmes commandes shell.

``
docker exec -it monimage bash
``

## Premiere etape : le Dockerfile

Le Dockerfile est un fichier qui va permettre de lancer son image et d'y inclure tous les fichiers que l'on souhaite.
Ligne 1 : ``FROM image:version -> FROM debian:buster``

FROM permet de spécifier une image existante sur laquelle on veut se baser. Dans notre cas, Debian Buster.
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

RUN permet d'executer des commandes dans le conteneur. Ainsi on installe tous les paquets nécessaires a faire tourner notre serveur.

ligne 17 - 21 
```
COPY srcs/nginx.conf .
COPY srcs/wp-config.php .
COPY srcs/autoindex.sh .
COPY srcs/nginx_auto.conf .
COPY srcs/entrypoint-container.sh .
```
              
Pour utiliser des fichiers exterieurs dans votre conteneur on les ajoute a la racine avec la commande COPY.
Les fichiers d'installations et de configuration de nos services seront donc a la racine du conteneur.

Ligne 23 ``EXPOSE 80 443``

EXPOSE permet de preciser le port d'ecoute du conteneur.

Ligne 24 ``ENTRYPOINT ["bash", "entrypoint-container.sh"]``

ENTRYPOINT ici précise la commande a lancer à l’entrée du conteneur. 

Pour plus d'utilisations des commandes Dockerfile : https://docs.docker.com/engine/reference/builder/






