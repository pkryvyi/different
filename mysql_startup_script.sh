#!/bin/bash
sudo yum update -y
sudo yum install -y wget
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
sudo rpm -ivh mysql-community-release-el7-5.noarch.rpm
sudo yum install -y mysql-server
#delete root password
sudo service mysql stop && mysqld_safe --skip-grant-tables --skip-networking &
sudo service mysql start
BUCKET_NAME=$(curl http://metadata.google.internal/... -H "Metadata-Flavor: Google")
M_SCHEMA=$(curl http://metadata.google.internal/... -H "Metadata-Flavor: Google")
S_SCHEMA=$(curl http://metadata.google.internal/... -H "Metadata-Flavor: Google")
DB_USERNAME=$(curl http://metadata.google.internal/... -H "Metadata-Flavor: Google")
DB_PASSWORD=$(curl http://metadata.google.internal/... -H "Metadata-Flavor: Google")
DB_SCHEMA=$(curl http://metadata.google.internal/... -H "Metadata-Flavor: Google")


gsutil cp gs://${BUCKET_NAME}/${M_SCHEMA} /opt/${M_SCHEMA}
gsutil cp gs://${BUCKET_NAME}/${S_SCHEMA} /opt/${S_SCHEMA}
#DB_NAME="powerdns"
ROOT_PASSWORD="root"
ROOT="root"

mysql -u root -e "CREATE USER '${DB_USERNAME}' IDENTIFIED BY '${DB_PASSWORD}'; GRANT ALL PRIVILEGES ON * . * TO '${DB_USERNAME}'; FLUSH PRIVILEGES;"
    mysql -u ${DB_USERNAME} -p${DB_PASSWORD} -e "CREATE DATABASE db_pdns_master;"
    mysql -u ${DB_USERNAME} -p${DB_PASSWORD} -e "update mysql.user set password=PASSWORD("${ROOT_PASSWORD}") where User='root';"
    mysql -u ${DB_USERNAME} -p${DB_PASSWORD} ${DB_SCHEMA} < /opt/${M_SCHEMA}
#    mysql -u root -e "CREATE USER '${DB_USERNAME}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}'; GRANT ALL PRIVILEGES ON * . * TO '${DB_USERNAME}'@'localhost'; FLUSH PRIVILEGES;"
    mysql -u ${DB_USERNAME} -p${DB_PASSWORD} -e "CREATE DATABASE db_pdns_slave;"
 #   mysql -u ${DB_USERNAME} -p${DB_PASSWORD} -e "update mysql.user set password=PASSWORD("${ROOT_PASSWORD}") where User='root';"
    mysql -u ${DB_USERNAME} -p${DB_PASSWORD} ${DB_SCHEMA} < /opt/${S_SCHEMA}
