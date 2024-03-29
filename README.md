:warning: Multimedia directories helpers have been integrated into YunoHost core since its version 4.2.0.

:warning: Les *helpers* pour les dossiers multimédia ont été intégrés au coeur de YunoHost depuis sa version 4.2.0.

---

# Dossiers multimédia pour Yunohost

Ce package permet la centralisation des media de chaque utilisateurs ainsi que des médias partagés entre tout les utilisateurs.
Chaque utilisateur se verra attribuer un dossier Multimedia dans son home pour y placer ses fichiers.
Un dossier Share sera accessible par chaque utilisateur, permettant de disposer de médias accessibles à tous.

Les dossiers multimedia et share, virtuellement placés dans le home de chaque utilisateur sont en réalité regroupés dans le dossier **/home/yunohost.multimedia**

Cette arborescence permet à chaque application nécessitant un accès aux fichiers multimédias de les retrouver aisément, sans multiplier les emplacements de ces fichiers.

L'arborescence exacte de ce dossier est la suivante:

* /home/yunohost.multimedia/
 * user1/
    *  Music
    * Picture
    * Video
    * eBook
    * Share (lien symbolique sur le dossier /home/yunohost.multimedia/Share)
 * user2/
    * Music
    * Picture
    * Video
    * eBook
    * Share
 * Share/
    * Music
    * Picture
    * Video
    * eBook

## Usage du package par les applications multimédia

### Pour toutes les applications, mise en place des dossiers multimédias:
Toutes les applications nécessitant un accès aux dossiers multimédias, quel que soit les droits qu'elles exigeront sur ceux-ci, doivent au préalable s'assurer de l'existence des dossiers multimédias.
Pour cela, il suffit de télécharger le package et d'exécuter le script ```ynh_media_build.sh``` afin de construire et configurer les dossiers multimédias.

    wget -nv https://github.com/maniackcrudelis/yunohost.multimedia/archive/master.zip
    unzip master.zip
    sudo ./yunohost.multimedia-master/script/ynh_media_build.sh

### Application multimédia ayant besoin d'un droit de lecture:
Une application ayant uniquement besoin de pouvoir lire les médias n'a rien de particulier à faire. Les fichiers médias sont accessible en lecture à tous.

Toutefois, une application désirant lire les fichiers multimédias doit choisir entre lire le contenu des dossiers utilisateurs, pour une application multi-utilisateurs ou lire le contenu du dossier Share, pour une application sans utilisateur désigné.

*Ex: Minidlna est une application qui se contente d'un droit de lecture, elle n'écrit pas dans les dossiers médias.*

### Application multimédia ayant besoin d'un droit d'écriture sur l'ensemble des médias:
Une application ayant besoin d'un droit d'écriture sur les médias doit s'ajouter au groupe multimedia, car seul le groupe multimedia garde un droit d'écriture sur l'ensemble du dossier multimédia, indépendamment des propriétaires des fichiers.

    sudo groupadd -f multimedia
    sudo usermod -a -G multimedia APP_USER

*Ex: Owncloud est très utile pour permettre aux utilisateurs de gérer leur collection de médias. Il a donc besoin d'un droit d'écriture pour permettre à chaque utilisateur de supprimer ses médias ou en ajouter.*

### Application utilisant un dossier propre, à mettre à disposition des utilisateurs:
Une application peux avoir à utiliser son propre dossier de médias, pour diverses raisons, tout en gardant l'intérêt de permettre aux utilisateurs d'y accéder.
Dans ce cas de figure, l'application peut utiliser le script ```ynh_media_addfolder.sh``` pour ajouter son dossier de médias au dossier yunohost.multimedia. Le dossier deviendra ainsi accessible à l'ensemble des utilisateurs en lecture et en écriture.

    sudo ./yunohost.multimedia-master/script/ynh_media_addfolder.sh --source="/CHEMIN/DU/DOSSIER/À/PARTAGER" --dest="CHEMIN/ET/NOM_DU_DOSSIER_DANS_YUNOHOST.MULTIMEDIA"
L'usage normal du script ```ynh_media_addfolder.sh``` ne déplace pas le dossier de l'application, il créer un lien symbolique vers celui-ci.
Il est toutefois possible d'inverser ce comportement avec l'argument ```--inv```. Dans ce cas, le dossier est déplacé et renommé dans ```dest```, tandis qu'un lien symbolique vient prendre la place du dossier de l'application.

*Ex: Transmission enregistre les téléchargements dans son propre dossier, mais il est intéressant pour les utilisateurs de pouvoir accéder à ces téléchargements. Et aux applications multimédias d'accéder aux médias téléchargés.*

## Usage du dossier multimedia en ssh
Pour ajouter ou supprimer simplement des fichiers multimédia via une connexion ssh, il peux être nécessaire d'ajouter l'user ssh au groupe multimédia. Cela permettra d'obtenir simplement un droit d'écriture sur l'ensemble des fichiers du dossier yunohost.multimedia.

    sudo usermod -a -G multimedia SSH_USER
