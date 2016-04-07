#!/bin/bash -e
set -e

OWNER=$(stat -c '%u' /var/www/html)
GROUP=$(stat -c '%g' /var/www/html)
USERNAME=www-data
[ -e "/etc/debian_version" ] || USERNAME=apache
if [ "$OWNER" != "0" ]; then
  usermod -o -u $OWNER $USERNAME
  usermod -s /bin/bash $USERNAME
  groupmod -o -g $GROUP $USERNAME
  usermod -d /var/www/html $USERNAME
  chown -R --silent $USERNAME:$USERNAME /var/www/html
fi
echo The apache user and group has been set to the following:
id $USERNAME

usermod -d /var/www www-data

# Tweak nginx to match the workers to cpu's
procs=$(cat /proc/cpuinfo |grep processor | wc -l)
sed -i -e "s/worker_processes auto/worker_processes $procs/" /etc/nginx/nginx.conf

# Nginx custom servername, alias and documentroot
sed -i "s/MYSERVERNAME/$SERVERNAME $SERVERALIAS/g" /etc/nginx/sites-enabled/default
sed -i "s/MYDOCUMENTROOT/$DOCUMENTROOT/g" /etc/nginx/sites-enabled/default

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf
