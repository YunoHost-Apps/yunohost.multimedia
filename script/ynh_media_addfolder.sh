#!/bin/bash

# Script d'ajout de dossier d'application dans le dossier Share multimédia.
# Arguments du script
# --source="" Chemin absolu du dossier à placer dans le dossier multimedia.
# --dest="" Nom et emplacement du dossier dans multimedia. Le chemin est relatif à partir de $DOSSIER_MEDIA.
# --inv Inverse l'emplacement du lien symbolique. Le dossier source est déplacé dans la destination. Un lien symbolique le remplace. Le lien symbolique renvoi donc dans le dossier Multimedia, au lieu d'en sortir.
# Usage:
# ./ajout_dossier_media.sh --source="/CHEMIN/DU/DOSSIER" --dest="share/dossier_app" [--inv]

if [ $# -gt 3 ]; then
    echo "Too many arguments"
	exit 1
elif [ $# -lt 2 ]; then
    echo "Missing operand"
	exit 1
fi

# --source
source=$(echo "$*" | grep -o -e "--source=.*" | cut -d "=" -f2)	# Recherche l'argument --source et le coupe après le premier =.
source=$(echo ${source%% --*})	# Retire " --" de la fin de la chaine, pour ne garder que l'argument.
# --dest
dest=$(echo "$*" | grep -o -e "--dest=.*" | cut -d "=" -f2)
dest=$(echo ${dest%% --*})
# --inv
inv=$(echo "$*" | grep -c -e "--inv")	# inv vaut 1 si l'argument est présent, sinon il vaut 0.

GROUPE_MEDIA=multimedia
DOSSIER_MEDIA=/home/yunohost.multimedia

if [ $inv -eq 0 ]
then	# Si la commande n'est pas inversée.
	dossier=$source
	lien=$DOSSIER_MEDIA/$dest
else	# Sinon, on inverse source et destination
	sudo mv -f "$source" "$DOSSIER_MEDIA/$dest"	# Déplace le dossier source dans le dossier multimedia de destination. Afin de pointer sur ce dernier.
	dossier=$DOSSIER_MEDIA/$dest
	lien=$source
fi

# Ajout d'un lien symbolique vers le dossier à partager
sudo ln -sfn "$dossier" "$lien"

## Application des droits étendus sur le dossier ajouté
# Droit d'écriture pour le groupe et le groupe multimedia en acl et droit de lecture pour other:
sudo setfacl -RnL -m g:$GROUPE_MEDIA:rwX,g::rwX,o:r-X "$dossier"
# Application de la même règle que précédemment, mais par défaut pour les nouveaux fichiers.
sudo setfacl -RnL -m d:g:$GROUPE_MEDIA:rwX,g::rwX,o:r-X "$dossier"
# Réglage du masque par défaut. Qui garantie (en principe...) un droit maximal à rwx. Donc pas de restriction de droits par l'acl.
sudo setfacl -RL -m m::rwx "$dossier"
