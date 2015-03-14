#!/bin/bash

if [[ -z $1 ]]
then
	echo -n "Type new host: "
	read host
else
	host=$1
fi

defaultPath="/var/www/html/"$host
path=${path:-$defaultPath}

defaultSAPath="/etc/apache2/sites-available"
SAPath=${SAPath:-$defaultSAPath}

safile=${SAPath}"/"${host}".conf"
echo -n "Creating Host Config ("$safile")... "
siteconf="
<VirtualHost *:80>\n
	\tServerName "$host"\n
	\tDocumentRoot "$path"\n
	\t<Directory "$path">\n
		\t\tOptions Indexes FollowSymLinks MultiViews\n
		\t\tAllowOverride All\n
		\t\tOrder allow,deny\n
		\t\tAllow from all\n
		\t\tRequire all granted\n
	\t</Directory>\n
	\tErrorLog "$path"/error.log\n
	\tCustomLog "$path"/access.log combined\n
</VirtualHost>"

echo -e ${siteconf} > ${safile}
echo "OK"

# TODO: check for unique
echo -n "Adding string to /etc/hosts... "
echo -e "127.0.0.1\t"$host >> "/etc/hosts"
echo "OK"

if [[ ! -d $path ]]
then
	echo -n "Creating directory "$path"... "
	mkdir -p $path
	chown www-data $path
	chmod 777 -R $path
	echo "OK"
fi

a2ensite ${host}
/etc/init.d/apache2 restart
exit 0;
