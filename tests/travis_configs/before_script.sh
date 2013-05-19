#!/bin/bash
set -e

# do we really need the latest versions of everything?
# pip install selenium pytz markdown textile docutils py-bcrypt PyYAML PIL pylibmc
sudo apt-get install python-tz python-markdown python-textile python-bcrypt \
	python-yaml python-pylibmc python-memcache
# there is a PIL package, but Django doesn't detect it. Docutils too
sudo apt-get build-dep python-imaging
pip install selenium PIL docutils

if [ $DB = postgres ]
then
	# sudo apt-get install python-psycopg2 - doesn't install extensions
	pip install psycopg2
	TEMPLATE=template1
	if [ $GIS = gis ]
	then
		sudo apt-get install postgis postgresql-9.1-postgis libproj0 libgdal1-1.7.0 libgeos-c1
		wget https://docs.djangoproject.com/en/1.5/_downloads/create_template_postgis-debian.sh
		sudo sudo -u postgres sh create_template_postgis-debian.sh >/dev/null
		TEMPLATE=template_postgis
	fi
	psql -c "create database django TEMPLATE $TEMPLATE ;" -U postgres
	psql -c "create database django2 TEMPLATE $TEMPLATE ;" -U postgres
elif [ $DB = mysql ]
then
	sudo apt-get install python-mysqldb
	# pip install MySQL-python
	if [ $GIS = gis ]
	then
		sudo apt-get install libgeos-c1	libgdal1-1.7.0
	fi
	mysql -e 'create database django;'
	mysql -e 'create database django2;'
fi

echo $PATH

wget -O tmp_chromedriver $CONFIG_SERVER/chromedriver
chmod +x tmp_chromedriver
sudo mv tmp_chromedriver /usr/local/bin/ChromeDriver
sh -e /etc/init.d/xvfb start
