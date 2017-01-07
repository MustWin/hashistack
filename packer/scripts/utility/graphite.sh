#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT graphite.sh: $1"
}

logger "Executing"

logger "Installing graphite components"
apt-get -y install \
  graphite-web graphite-carbon \
  postgresql libpq-dev python-psycopg2 \
  apache2 libapache2-mod-wsgi

logger "Configuring graphite web application"
sed -i -- "s/#SECRET_KEY = 'UNSAFE_DEFAULT'/SECRET_KEY = 'a_salty_string'/g" /etc/graphite/local_settings.py
sed -i -- "s/#TIME_ZONE = 'America\/Los_Angeles'/TIME_ZONE = 'America\/Los_Angeles'/g" /etc/graphite/local_settings.py
sed -i -- "s/#USE_REMOTE_USER_AUTHENTICATION = True/USE_REMOTE_USER_AUTHENTICATION = True/g" /etc/graphite/local_settings.py

logger "Configuring graphite web application for Postgres"
USERNAME=graphite
PASSWORD=password

logger "Configuring Django database user and database for Postgres"
sudo -u postgres psql -c "CREATE USER ${USERNAME} WITH PASSWORD '${PASSWORD}'"
sudo -u postgres psql -c "CREATE DATABASE graphite WITH OWNER ${USERNAME}"

logger "Configuring graphite web application for Postgres"
sed -i -- "s/'NAME': '\/var\/lib\/graphite\/graphite.db'/'NAME': 'graphite'/g" /etc/graphite/local_settings.py
sed -i -- "s/'ENGINE': 'django.db.backends.sqlite3'/'ENGINE': 'django.db.backends.postgresql_psycopg2'/g" /etc/graphite/local_settings.py
sed -i -- "s/'USER': ''/'USER': '${USERNAME}'/g" /etc/graphite/local_settings.py
sed -i -- "s/'PASSWORD': ''/'PASSWORD': '${PASSWORD}'/g" /etc/graphite/local_settings.py
sed -i -- "s/'HOST': ''/'HOST': '127.0.0.1'/g" /etc/graphite/local_settings.py

logger "Sync the database"
graphite-manage syncdb --noinput

logger "Configuring carbon"
sed -i -- "s/CARBON_CACHE_ENABLED=false/CARBON_CACHE_ENABLED=true/g" /etc/default/graphite-carbon
sed -i -- "s/ENABLE_LOGROTATION = False/ENABLE_LOGROTATION = True/g" /etc/carbon/carbon.conf

logger "Configuring storage schemas"
cat <<EOF >>/etc/carbon/storage-schemas.conf

[test]
pattern = ^test\.
retentions = 10s:10m,1m:1h,10m:1d
EOF

service carbon-cache start

logger "Configuring Apache"
a2dissite 000-default
cp /usr/share/graphite-web/apache2-graphite.conf /etc/apache2/sites-available
a2ensite apache2-graphite
service apache2 reload

logger "Completed"
