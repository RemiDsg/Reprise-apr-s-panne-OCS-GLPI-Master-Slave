#!/bin/sh
# Auteur : Rémi DE SAINT GILLES
# Script reprise apres panne 
log=reprise.log

# Indique à OCS d'utiliser le serveur slave au lieu du serveur Master pour que les remontées d'inventaires puissent continuer 
# D'abord on backup l'ancien     fichier conf pour pouvoir revenir a la normal apres ! 
echo "Backup des fichiers conf d'ocs ..."
echo "Backup des fichiers conf d'ocs ..." >> $log
cp /etc/apache2/conf-enabled/z-ocsinventory-server.conf /etc/apache2/conf-enabled/z-ocsinventory-server.conf.back

if [ $? -ne 0 ] ; then 
	echo "Erreur lors du backup du fichier /etc/apache2/conf-enabled/z-ocsinventory-server.conf "
	echo "Erreur lors du backup du fichier /etc/apache2/conf-enabled/z-ocsinventory-server.conf" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Backup du fichier /etc/apache2/conf-enable/z-ocsinventory-server.conf réussi !"
echo "Backup du fichier /etc/apache2/conf-enable/z-ocsinventory-server.conf réussi !" >> $log

cp /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php /usr/share/ocsinventory-reports/ocsreports/dbconfig.php.back

if [ $? -ne 0 ] ; then 
	echo "Erreur lors du backup du fichier /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php "
	echo "Erreur lors du backup du fichier /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Backup du fichier /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php réussi !"
echo "Backup du fichier /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php réussi !" >> $log

cp /var/www/glpi/config/config_db.php /var/www/glpi/config/config_db.php.back

if [ $? -ne 0 ] ; then 
	echo "Erreur lors du backup du fichier /var/www/glpi/config/config_db.php "
	echo "Erreur lors du backup du fichier /var/www/glpi/config/config_db.php" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Backup du fichier /var/www/glpi/config/config_db.php réussi !"
echo "Backup du fichier /var/www/glpi/config/config_db.php réussi !" >> $log


# Modification de l'ip du serveur de base de données dans les fichiers conf
echo "Modification des fichiers ocnf d'ocs ..."
echo "Modification des fichiers ocnf d'ocs ..." >> $log
sed -i -e 's/ OCS_DB_HOST localhost/\ OCS_DB_HOST 192.168.202.144/g' /etc/apache2/conf-enabled/z-ocsinventory-server.conf 

if [ $? -ne 0 ] ; then 
	echo "Erreur lors de la Modification du fichier /etc/apache2/conf-enabled/z-ocsinventory-server.conf "
	echo "Erreur lors de la Modification du fichier /etc/apache2/conf-enabled/z-ocsinventory-server.conf, verifier les droits de Modification !" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Modification du fichier /etc/apache2/conf-enabled/z-ocsinventory-server.conf réussi !"
echo "Modification du fichier /etc/apache2/conf-enabled/z-ocsinventory-server.conf réussi !" >> $log

sed -i -e 's/"localhost"/\"192.168.202.144"/g' /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php 

if [ $? -ne 0 ] ; then 
	echo "Erreur lors de la Modification du fichier /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php "
	echo "Erreur lors de la Modification du fichier /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php, verifier les droits de Modification !" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Modification du fichier /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php réussi !"
echo "Modification du fichier /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php réussi !" >> $log

sed -i -e 's/\'localhost'/'192.168.202.144'/g' /var/www/glpi/config/config_db.php 

if [ $? -ne 0 ] ; then 
	echo "Erreur lors de la Modification du fichier /var/www/glpi/config/config_db.php "
	echo "Erreur lors de la Modification du fichier /var/www/glpi/config/config_db.php, verifier les droits de Modification !" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Modification du fichier /var/www/glpi/config/config_db.php réussi !"
echo "Modification du fichier /var/www/glpi/config/config_db.php réussi !" >> $log

# Redemarrage du service apache pour prendre en compte les Modifications 
echo "Redemarrage du service Apache2" 
echo "Redemarrage du service Apache2" >> $log
service apache2 restart 

if [ $? -ne 0 ] ; then 
	echo "Erreur lors du Redemarrage du service apache2"
	echo "Erreur lors du Redemarrage du service apache2, verifier les informations dans /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php, /var/www/glpi/config/config_db.php et /etc/apache2/conf-enable/z-ocsiventory-server.conf" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Redemarrage du service apache2 réussi !"
echo "Redemarrage du service apache2 réussi !" >> $log


# On arrete le slave
echo "Arret du slave ..."
echo "Arret du slave ..." >> $log

mysql --host 192.168.202.144 -u root --password=toor -e "STOP SLAVE;"

if [ $? -ne 0 ] ; then 
	echo "Erreur lors de l'arret du slave"
	echo "Erreur lors de l'arret du slave" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Arret du slave réussi !"
echo "Arret du slave réussi !" >> $log


# Redemarrage du service mysql 
echo "Reboot du service mysql ..."
service mysql restart # si le service est "stop" il démmare sinon il reboot 

if [ $? -ne 0 ] ; then 
	echo "Erreur lors du reboot du service mysql"
	echo "Erreur lors du reboot du service mysql, message d'erreur :" >> $log
	systemctl status mysql >> $log
	echo "La remontée se fait sur le slave en attendant reparation du master ! "
	echo "La remontée se fait sur le slave en attendant reparation du master ! " >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Le service mysql a démmarré avec succès !"
echo "Le service mysql a démmarré avec succès !" >> $log

# On bloque les écritures sur la Base de données 
echo "Arret de l'ecriture sur la base de données ..."
echo "Arret de l'ecriture sur la base de données ..." >> $log

mysql --host 192.168.202.144 -u root --password=toor -e "FLUSH TABLES WITH READ LOCK;"

if [ $? -ne 0 ] ; then 
	echo "Erreur lors de l'arret de l'ecriture sur la base de données"
	echo "Erreur lors de l'arret de l'ecriture sur la base de données" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Arret de l'ecriture sur la base de données terminé avec succès !"
echo "Arret de l'ecriture sur la base de données terminé avec succès !" >> $log


#Backup de la base ocs
echo "Backup de la base ocs en cours ..."	
echo "Backup de la base ocs en cours ..." >> $log
sshpass -p "toor" ssh 'root'@'192.168.202.144' mysqldump --databases ocs > /home/ocs.sql

if [ $? -ne 0 ] ; then 
	echo "Erreur lors du Backup de la base ocs"
	echo "Impossible de dump la base ocs" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "La Backup de la base ocs s'est terminée avec succès !"
echo "La Backup de la base ocs s'est terminée avec succès !" >> $log


#Backup de la base glpi
echo "Backup de la base glpi en cours ..."	
echo "Backup de la base glpi en cours ..." >> $log
sshpass -p "toor" ssh 'root'@'192.168.202.144' mysqldump --databases glpi > /home/glpi.sql

if [ $? -ne 0 ] ; then 
	echo "Erreur lors du Backup de la base glpi"
	echo "Impossible de dump la base glpi" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "La Backup de la base glpi s'est terminée avec succès !"
echo "La Backup de la base glpi s'est terminée avec succès !" >> $log

# Drop de la base du master (donc pas a jour)
echo "Suppression de la base ocs sur le serveur OCS en cours ..."
echo "Suppression de la base ocs sur le serveur OCS en cours ..." >> $log
mysql -u root --password=toor -e "drop database ocs;"

if [ $? -ne 0 ] ; then
	echo "Une erreur est survenue lors de la suppression de la base ocs sur le serveur OCS !"
	echo "Impossiblez de drop la base ocs sur le serveur OCS !" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "La suppression de la base ocs s'est terminée avec succès !"
echo "La suppression de la base ocs s'est terminée avec succès !" >> $log


# Drop de la base du master (donc pas a jour)
echo "Suppression de la base glpi sur le serveur OCS en cours ..."
echo "Suppression de la base glpi sur le serveur OCS en cours ..." >> $log
mysql -u root --password=toor -e "drop database glpi;"

if [ $? -ne 0 ] ; then
	echo "Une erreur est survenue lors de la suppression de la base glpi sur le serveur OCS !"
	echo "Impossiblez de drop la base glpi sur le serveur OCS !" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "La suppression de la base glpi s'est terminée avec succès !"
echo "La suppression de la base glpi s'est terminée avec succès !" >> $log

#Restauration de la base sur le master
echo "Restauration de la base ocs sur le Serveur OCS en cours ..."
echo "Restauration de la base ocs sur le Serveur OCS en cours ..." >> $log
mysql -u root --password=toor < /home/ocs.sql

if [ $? -ne 0 ] ; then
	echo "Une erreur est survenue lors de la restauration "
	echo "Impossible de faire la restauration du fichier ocs.sql " >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
      exit	
    fi

echo "La restauration de la base ocs s'est terminée avec succès ! "
echo "La restauration de la base ocs vers la version du slave s'est terminée avec succès le `date` !" >> $log


#Restauration de la base sur le master
echo "Restauration de la base glpi sur le Serveur OCS en cours ..."
echo "Restauration de la base glpi sur le Serveur OCS en cours ..." >> $log
mysql -u root --password=toor < /home/glpi.sql

if [ $? -ne 0 ] ; then
	echo "Une erreur est survenue lors de la restauration "
	echo "Impossible de faire la restauration du fichier glpi.sql " >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
      exit	
    fi

echo "La restauration de la base glpi s'est terminée avec succès ! "
echo "La restauration de la base glpi vers la version du slave s'est terminée avec succès le `date` !" >> $log


# Suppression du backup temporaire de la base
echo "Suppression du backup de la base ocs"
echo "Suppression du backup de la base ocs" >> $log
rm /home/ocs.sql

if [ $? -ne 0 ]; then 
	echo "Erreur lors de la suppression du backup de la base ocs"
	echo "Erreur lors de la suppression du backup de la base ocs" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Le fichier de backup de la base ocs a bien ete supprime !"
echo "Le fichier de backup de la base ocs a bien ete supprime !" >> $log


# Suppression du backup temporaire de la base
echo "Suppression du backup de la base glpi"
echo "Suppression du backup de la base glpi" >> $log
rm /home/glpi.sql

if [ $? -ne 0 ]; then 
	echo "Erreur lors de la suppression du backup de la base glpi"
	echo "Erreur lors de la suppression du backup de la base glpi" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Le fichier de backup de la base glpi a bien ete supprime !"
echo "Le fichier de backup de la base glpi a bien ete supprime !" >> $log


# On redemarre le slave
echo "Redemmarage du slave ..."
echo "Redemmarage du slave ..." >> $log

mysql --host 192.168.202.144 -u root --password=toor -e "START SLAVE;"

if [ $? -ne 0 ] ; then 
	echo "Erreur lors du redemmarrage du slave"
	echo "Erreur lors du redemmarrage du slave" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Reprise du slave réussi !"
echo "Reprise du slave réussi !" >> $log


# Suppression des fichiers backup 
echo "Suppression du backup de /etc/apache2/conf-enable/z-ocsiventory-server.conf"
echo "Suppression du backup de /etc/apache2/conf-enable/z-ocsiventory-server.conf" >> $log
rm /etc/apache2/conf-enabled/z-ocsinventory-server.conf

if [ $? -ne 0 ]; then 
	echo "Erreur lors de la suppression du backup de /etc/apache2/conf-enable/z-ocsiventory-server.conf"
	echo "Erreur lors de la suppression du backup de /etc/apache2/conf-enable/z-ocsiventory-server.conf" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Le fichier de backup de /etc/apache2/conf-enable/z-ocsiventory-server.conf a bien ete supprime !"
echo "Le fichier de backup de /etc/apache2/conf-enable/z-ocsiventory-server.conf a bien ete supprime !" >> $log


# Suppression des fichiers backups 
echo "Suppression du backup de /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php"
echo "Suppression du backup de /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php" >> $log
rm /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php

if [ $? -ne 0 ]; then 
	echo "Erreur lors de la suppression du backup de /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php"
	echo "Erreur lors de la suppression du backup de /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Le fichier de backup de /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php a bien ete supprime !"
echo "Le fichier de backup de /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php a bien ete supprime !" >> $log


# Suppression des fichiers backups 
echo "Suppression du backup de /var/www/glpi/config/config_db.php"
echo "Suppression du backup de /var/www/glpi/config/config_db.php" >> $log
rm /var/www/glpi/config/config_db.php

if [ $? -ne 0 ]; then 
	echo "Erreur lors de la suppression de /var/www/glpi/config/config_db.phps"
	echo "Erreur lors de la suppression de /var/www/glpi/config/config_db.php" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Le fichier de backup de /var/www/glpi/config/config_db.php a bien ete supprime !"
echo "Le fichier de backup de /var/www/glpi/config/config_db.php a bien ete supprime !" >> $log


# Suppression du backup temporaire de la base
echo "Remise a zero des fichiers conf !"
echo "Remise a zero des fichiers conf !" >> $log
mv /etc/apache2/conf-enabled/z-ocsinventory-server.conf.back /etc/apache2/conf-enabled/z-ocsinventory-server.conf

if [ $? -ne 0 ]; then 
	echo "Erreur lors de la remise a zero de /etc/apache2/conf-enabled/z-ocsinventory-server.conf"
	echo "Erreur lors de la remise a zero de /etc/apache2/conf-enabled/z-ocsinventory-server.conf" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Remise a zero de /etc/apache2/conf-enabled/z-ocsinventory-server.conf terminée !"
echo "Remise a zero de /etc/apache2/conf-enabled/z-ocsinventory-server.conf terminée !" >> $log


# Suppression du backup temporaire de la base
mv /usr/share/ocsinventory-reports/ocsreports/dbconfig.php.back /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php

if [ $? -ne 0 ]; then 
	echo "Erreur lors de la remise a zero de /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php "
	echo "Erreur lors de la remise a zero de /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Remise a zero de /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php terminée !"
echo "Remise a zero de /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php terminée !" >> $log


# Suppression du backup temporaire de la base
mv /var/www/glpi/config/config_db.php.back /var/www/glpi/config/config_db.php

if [ $? -ne 0 ]; then 
	echo "Erreur lors de la remise a zero de /var/www/glpi/config/config_db.php "
	echo "Erreur lors de la remise a zero de /var/www/glpi/config/config_db.php" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Remise a zero de /var/www/glpi/config/config_db.php terminée !"
echo "Remise a zero de /var/www/glpi/config/config_db.php terminée !" >> $log


# Redemarrage du service apache pour prendre en compte les Modifications 
echo "Redemarrage du service Apache2" 
echo "Redemarrage du service Apache2" >> $log
service apache2 restart 

if [ $? -ne 0 ] ; then 
	echo "Erreur lors du Redemarrage du service apache2"
	echo "Erreur lors du Redemarrage du service apache2, verifier les informations dans /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php et /etc/apache2/conf-enable/z-ocsiventory-server.conf" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Redemarrage du service apache2 réussi !"
echo "Redemarrage du service apache2 réussi !" >> $log


# On débloque les écritures sur la Base de données 
echo "Réactivation de l'ecriture sur la base de données ..."
echo "Réactivation de l'ecriture sur la base de données ..." >> $log
mysql --host 192.168.202.144 -u root --password=toor -e "UNLOCK TABLES;"

if [ $? -ne 0 ] ; then 
	echo "Erreur lors de la réactivation de l'ecriture sur la base de données"
	echo "Erreur lors de la réactivation de l'ecriture sur la base de données" >> $log
	echo "" >> $log
	echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
	echo "" >> $log
	exit
    fi 

echo "Réactivation de l'ecriture sur la base de données terminé avec succès !"
echo "Réactivation de l'ecriture sur la base de données terminé avec succès !" >> $log
echo "La replication est de nouveau active ! "
echo "La replication est de nouveau active ! " >> $log
echo "" >> $log
echo "--------------------------------------------------------------------------------------------------------------------------" >> $log
echo "" >> $log
