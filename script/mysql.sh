#!/bin/bash

source /usr/local/bin/common.sh

check_require "MYSQL_SERVER" $MYSQL_SERVER
check_require "MYSQL_ROOT_PASSWORD" $MYSQL_ROOT_PASSWORD
check_require "MYSQL_USER" $MYSQL_USER
check_require "MYSQL_USER_PASSWORD" $MYSQL_USER_PASSWORD
MYSQL_PORT=${MYSQL_PORT:-3306}
MYSQL_DATABASE_NAME=${MYSQL_DATABASE_NAME:sogo}

wait_for_db() {
    log_info "Trying to connect to the DB server"
    DOCKERIZE_TIMEOUT=${DOCKERIZE_TIMEOUT:-"60s"}
    dockerize -timeout ${DOCKERIZE_TIMEOUT} -wait tcp://${MYSQL_SERVER}:${MYSQL_PORT:-3306}
    if [[ $? -ne 0 ]]; then
        log_error "Cannot connect to the DB server"
        exit 1
    fi
    log_info "Successfully connected to the DB server"
}

init_db(){
    log_info "Checking if database exists"
    if [[ -z "`mysql -h$MYSQL_SERVER -P${MYSQL_PORT:-3306} -uroot -p$MYSQL_ROOT_PASSWORD -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$MYSQL_USER'" 2>&1`" ]];then
        log_info "Creating database"
        mysql -h$MYSQL_SERVER -P$MYSQL_PORT -uroot -p$MYSQL_ROOT_PASSWORD -e "
            CREATE DATABASE $MYSQL_DATABASE_NAME CHARACTER SET='utf8';
            CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_USER_PASSWORD';
            GRANT ALL PRIVILEGES ON $MYSQL_DATABASE_NAME.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;
            FLUSH PRIVILEGES;"

    else
        log_info "Database already exist"
    fi

    update_conf "SOGoProfileURL"        \"mysql://$MYSQL_USER:$MYSQL_USER_PASSWORD@$MYSQL_SERVER:$MYSQL_PORT/$MYSQL_DATABASE_NAME/sogo_user_profile\"
    update_conf "OCSFolderInfoURL"      \"mysql://$MYSQL_USER:$MYSQL_USER_PASSWORD@$MYSQL_SERVER:$MYSQL_PORT/$MYSQL_DATABASE_NAME/sogo_folder_info\"
    update_conf "OCSSessionsFolderURL"  \"mysql://$MYSQL_USER:$MYSQL_USER_PASSWORD@$MYSQL_SERVER:$MYSQL_PORT/$MYSQL_DATABASE_NAME/sogo_sessions_folder\"
}