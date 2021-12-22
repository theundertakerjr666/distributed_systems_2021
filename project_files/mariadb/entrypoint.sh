#!/bin/bash

ln -fs /dev/hostlog/log /dev/log

# First run, use script that just initializes databases, and without
# gaving the general log enabled. 
(
echo "Checking for first run"
if [[ ! -d "/var/lib/mysql/mysql" ]]; then
    echo "Running first run script"
    /first-run.sh
    echo "First run script completed" 
    
fi
) |& logger -t firstrun -p user.debug

# There are some gotchas when defining an entrypoint with the mariadb
# Docker image. See the image entrpoint code for more information:
#   https://github.com/docker-library/mariadb/blob/master/docker-entrypoint.sh

# NOTE: This can't be done in /var/lib/mysql, otherwise scripts from
# /docker-entrypoint-initdb.d is not run. Also, mysqld is run as user
# 'mysql', which of course needs write access to this file.
rm -f /var/log/vissl-general.log
touch /var/log/vissl-general.log
chmod a+rw /var/log/vissl-general.log
tail -f /var/log/vissl-general.log | logger -t querylog -p user.debug &

# NOTE: docker-entrypoint.sh contains mysql initializations, that
# don't get run now that our CMD is not "mysqld". We re-run the image
# entrypoint to be able to initialize:

exec /usr/local/bin/docker-entrypoint.sh mysqld --general-log --general-log-file=/var/log/vissl-general.log --log_warnings=0 2> >(logger -t mysqld-stderr -p user.info) > >(logger -t mysqld-stdout -p user.info)

# mariadb/entrypoint.sh
