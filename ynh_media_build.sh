#!/bin/bash

## Création du groupe multimedia
sudo groupadd -f multimedia

## Création des dossiers génériques
sudo mkdir -p /home/yunohost.multimedia
sudo mkdir -p /home/yunohost.multimedia/share
sudo mkdir -p /home/yunohost.multimedia/share/Music
sudo mkdir -p /home/yunohost.multimedia/share/Picture
sudo mkdir -p /home/yunohost.multimedia/share/Video
sudo mkdir -p /home/yunohost.multimedia/share/Video/sous-dossier1	# Dossier à définir
sudo mkdir -p /home/yunohost.multimedia/share/Video/sous-dossier2	# Dossier à définir

# Propriétaires des dossiers génériques.
sudo chown -R root:multimedia /home/yunohost.multimedia
	# !!! Attention aux liens symboliques, notamment le torrent!? Il est en debian-transmission www-data

## Création des dossiers utilisateurs
while read user	#USER en majuscule est une variable système, à éviter.
do
		sudo mkdir -p /home/yunohost.multimedia/$user
		sudo mkdir -p /home/yunohost.multimedia/$user/Music
		sudo mkdir -p /home/yunohost.multimedia/$user/Picture
		sudo mkdir -p /home/yunohost.multimedia/$user/Video
		sudo mkdir -p /home/yunohost.multimedia/$user/Video/sous-dossier1	# Dossier à définir
		sudo mkdir -p /home/yunohost.multimedia/$user/Video/sous-dossier2	# Dossier à définir
		# Création du lien symbolique dans le home de l'utilisateur.
		sudo ln -sf /home/yunohost.multimedia/$user /home/$user/Multimedia
		# Propriétaires des dossiers utilisateurs.
		sudo chown -R $user:multimedia /home/yunohost.multimedia/$user
done <<< "$(sudo yunohost user list | grep username | cut -d ":" -f 2 | cut -c 2-)"	# Liste les utilisateurs et supprime l'espace après username:
# Le triple chevron <<< permet de prendre la sortie de commande en entrée de boucle.

## Application du setgid et du umask sur l'ensemble du dossier.
# Droits génériques sur les dossiers et fichiers: root:multimedia rwXrwsr-X
# Lecture/écriture éxecution (sur les dossiers) pour le propriétaire.
# Lecture/écriture setgid pour le groupe. Le setgid fixera le groupe pour tout nouveau fichier ou dossier créé.
# Lecture éxecution (sur les dossiers) pour les autres.
sudo chmod -R u=rwx,g=rws,o=rX  /home/yunohost.multimedia
# Soit un umask correspondant: 003
umask 003 -R /home/yunohost.multimedia

## Mise en place du hook pour l'ajout des dossiers des futurs utilisateurs
sudo yunohost hook add post_user_create
