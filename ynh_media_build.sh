#!/bin/bash

# Script de création des dossiers multimédia pour Yunohost.

GROUPE_MEDIA=multimedia
DOSSIER_MEDIA=/home/yunohost.multimedia

## Création du groupe multimedia
sudo groupadd -f $GROUPE_MEDIA

## Création des dossiers génériques
sudo mkdir -p "$DOSSIER_MEDIA"
sudo mkdir -p "$DOSSIER_MEDIA/share"
sudo mkdir -p "$DOSSIER_MEDIA/share/Music"
sudo mkdir -p "$DOSSIER_MEDIA/share/Picture"
sudo mkdir -p "$DOSSIER_MEDIA/share/Video"
sudo mkdir -p "$DOSSIER_MEDIA/share/Video/Sous-dossier1"	# Dossier à définir
sudo mkdir -p "$DOSSIER_MEDIA/share/Video/Sous-dossier2"	# Dossier à définir

# Propriétaires des dossiers génériques
sudo chgrp -Rh $GROUPE_MEDIA "$DOSSIER_MEDIA"

## Création des dossiers utilisateurs
while read user	#USER en majuscule est une variable système, à éviter.
do
		sudo mkdir -p "$DOSSIER_MEDIA/$user"
		sudo mkdir -p "$DOSSIER_MEDIA/$user/Music"
		sudo mkdir -p "$DOSSIER_MEDIA/$user/Picture"
		sudo mkdir -p "$DOSSIER_MEDIA/$user/Video"
		sudo mkdir -p "$DOSSIER_MEDIA/$user/Video/Sous-dossier1"	# Dossier à définir
		sudo mkdir -p "$DOSSIER_MEDIA/$user/Video/Sous-dossier2"	# Dossier à définir
		sudo ln -sf "$DOSSIER_MEDIA/share" "$DOSSIER_MEDIA/$user/Share"
		# Création du lien symbolique dans le home de l'utilisateur.
		sudo ln -sf "$DOSSIER_MEDIA/$user" "/home/$user/Multimedia"
		# Propriétaires des dossiers utilisateurs.
		sudo chown -R $user:$GROUPE_MEDIA "$DOSSIER_MEDIA/$user"
done <<< "$(sudo yunohost user list | grep username | cut -d ":" -f 2 | cut -c 2-)"	# Liste les utilisateurs et supprime l'espace après username:
# Le triple chevron <<< permet de prendre la sortie de commande en entrée de boucle.

## Application du setgid et du umask sur l'ensemble du dossier.
# Droits génériques sur les dossiers et fichiers: root:multimedia rwXrwsr-X
# Lecture/écriture éxecution (sur les dossiers) pour le propriétaire.
# Lecture/écriture setgid pour le groupe. Le setgid fixera le groupe pour tout nouveau fichier ou dossier créé.
# Lecture éxecution (sur les dossiers) pour les autres.
sudo chmod -R u=rwx,g=rwXs,o=rX  "$DOSSIER_MEDIA"
# Afin de garantir le droit d'écriture du groupe multimedia sur tout les fichiers créés. On place un ACL par défaut sur le groupe et sur other avec l'argument d.
sudo setfacl -R -m d:g:$GROUPE_MEDIA:rwX,o:r-X "$DOSSIER_MEDIA"

## Mise en place du hook pour l'ajout des dossiers des futurs utilisateurs
sudo yunohost hook add ynh_media post_user_create
