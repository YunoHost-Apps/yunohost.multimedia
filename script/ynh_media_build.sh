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
sudo mkdir -p "$DOSSIER_MEDIA/share/eBook"

## Création des dossiers utilisateurs
while read user	#USER en majuscule est une variable système, à éviter.
do
		sudo mkdir -p "$DOSSIER_MEDIA/$user"
		sudo mkdir -p "$DOSSIER_MEDIA/$user/Music"
		sudo mkdir -p "$DOSSIER_MEDIA/$user/Picture"
		sudo mkdir -p "$DOSSIER_MEDIA/$user/Video"
		sudo mkdir -p "$DOSSIER_MEDIA/$user/eBook"
		sudo ln -sfn "$DOSSIER_MEDIA/share" "$DOSSIER_MEDIA/$user/Share"
		# Création du lien symbolique dans le home de l'utilisateur.
		sudo ln -sfn "$DOSSIER_MEDIA/$user" "/home/$user/Multimedia"
		# Propriétaires des dossiers utilisateurs.
		sudo chown -R $user "$DOSSIER_MEDIA/$user"
done <<< "$(sudo yunohost user list | grep username | cut -d ":" -f 2 | cut -c 2-)"	# Liste les utilisateurs et supprime l'espace après username:
# Le triple chevron <<< permet de prendre la sortie de commande en entrée de boucle.

## Application des droits étendus sur le dossier multimedia.
# Droit d'écriture pour le groupe et le groupe multimedia en acl et droit de lecture pour other:
sudo setfacl -RnL -m g:$GROUPE_MEDIA:rwX,g::rwX,o:r-X "$DOSSIER_MEDIA"
# Application de la même règle que précédemment, mais par défaut pour les nouveaux fichiers.
sudo setfacl -RnL -m d:g:$GROUPE_MEDIA:rwX,g::rwX,o:r-X "$DOSSIER_MEDIA"
# Réglage du masque par défaut. Qui garantie (en principe...) un droit maximal à rwx. Donc pas de restriction de droits par l'acl.
sudo setfacl -RL -m m::rwx "$DOSSIER_MEDIA"

## Mise en place du hook pour l'ajout des dossiers des futurs utilisateurs et leur suppression
# if [ -e post_user_create ]
# then
	sudo yunohost hook add ynh_media ./yunohost.multimedia-master/hooks/post_user_create
	sudo yunohost hook add ynh_media ./yunohost.multimedia-master/hooks/post_user_delete
# fi

## Copie du script dans le répertoire $DOSSIER_MEDIA pour un usage manuel. Recréation des dossiers ou remise en place des droits sur les fichiers.
sudo cp ./yunohost.multimedia-master/script/ynh_media_build.sh "$DOSSIER_MEDIA"
sudo chmod +x "$DOSSIER_MEDIA/ynh_media_build.sh"
