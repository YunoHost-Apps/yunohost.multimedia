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
sudo ln -sfn "$1" "$DOSSIER_MEDIA/share/$2"

## Application des droits étendus sur le dossier ajouté
# Droit d'écriture pour le groupe et le groupe multimedia en acl et droit de lecture pour other:
sudo setfacl -RnL -m g:$GROUPE_MEDIA:rwX,g::rwX,o:r-X "$1"
# Application de la même règle que précédemment, mais par défaut pour les nouveaux fichiers.
sudo setfacl -RnL -m d:g:$GROUPE_MEDIA:rwX,g::rwX,o:r-X "$1"
# Réglage du masque par défaut. Qui garantie (en principe...) un droit maximal à rwx. Donc pas de restriction de droits par l'acl.
sudo setfacl -RL -m m::rwx "$1"
