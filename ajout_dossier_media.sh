#!/bin/bash

# Script d'ajout de dossier d'application dans le dossier Share multimédia.
# Arguments du script
# $1: Chemin absolu du dossier à placer dans le dossier Share.
# $2: Nom à afficher pour ce dossier dans le dossier Share
# Usage:
# ./ajout_dossier_media.sh "CHEMIN_DU_DOSSIER" "NOM_DOSSIER"

GROUPE_MEDIA=multimedia
DOSSIER_MEDIA=/home/yunohost.multimedia

# Ajout d'un lien symbolique vers le dossier à partager
sudo ln -sf "$1" "$DOSSIER_MEDIA/share/$2"

# Modification du groupe du dossier partagé.
sudo chgrp -R $GROUPE_MEDIA "$1"

## Application du setgid et du umask sur l'ensemble du dossier.
# Droits génériques sur les dossiers et fichiers: root:multimedia rwXrwsr-X
# Lecture/écriture éxecution (sur les dossiers) pour le propriétaire.
# Lecture/écriture setgid pour le groupe. Le setgid fixera le groupe pour tout nouveau fichier ou dossier créé.
# Lecture éxecution (sur les dossiers) pour les autres.
sudo chmod -R u=rwx,g=rwXs,o=rX "$1"
# Afin de garantir le droit d'écriture du groupe multimedia sur tout les fichiers créés. On place un ACL par défaut sur le groupe et sur other avec l'argument d.
sudo setfacl -R -m d:g:$GROUPE_MEDIA:rwX,o:r-X "$1"
