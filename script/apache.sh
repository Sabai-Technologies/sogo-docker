#!/bin/bash

source /usr/local/bin/common.sh

SERVER_NAME=${APACHE_SERVER_NAME:-localhost}

configure_apache() {
   log_info "Enabling Apache Server .."

   mkdir /var/log/apache2/
   echo "ServerName ${SERVER_NAME}"
   echo "ServerName ${SERVER_NAME}" > /etc/apache2/conf-available/servername.conf
   a2enmod proxy_http
   a2enconf servername
   service apache2 restart

   log_info "... done"
}
