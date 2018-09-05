#!/bin/bash

source /usr/local/bin/common.sh
source /usr/local/bin/mysql.sh

for conf in $(printenv| grep -i SOGO_ | cut -d= -f1);do
    update_conf "${conf:5}" "${!conf}"
done

wait_for_db
init_db

log_info "Launching SOGo"
/usr/sbin/sogod -WONoDetach YES -WOPort 20000 -WOLogFile - -WOPidFile /tmp/sogo.pid