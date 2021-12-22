#!/bin/bash

source /usr/local/bin/docker-entrypoint.sh

setup_mysql_user() {
    [[ -z "${1}" || -z "${2}" ]] && return

    mysql_note "Creating user ${1}"
    docker_process_sql --database=mysql <<<"CREATE USER '$1'@'%' IDENTIFIED BY '$2' ;"

    if [ -n "$MYSQL_DATABASE" ]; then
	mysql_note "Giving user ${1} access to schema ${MYSQL_DATABASE}"
	docker_process_sql --database=mysql <<<"GRANT ALL ON \`${MYSQL_DATABASE//_/\\_}\`.* TO '$1'@'%' ;"
    fi
}

docker_setup_additional_users() {
    setup_mysql_user "$MYSQL_USER2" "$MYSQL_PASSWORD2"
    setup_mysql_user "$MYSQL_USER3" "$MYSQL_PASSWORD3"
    setup_mysql_user "$MYSQL_USER4" "$MYSQL_PASSWORD4"
    setup_mysql_user "$MYSQL_USER5" "$MYSQL_PASSWORD5"
    setup_mysql_user "$MYSQL_USER6" "$MYSQL_PASSWORD6"
    setup_mysql_user "$MYSQL_USER7" "$MYSQL_PASSWORD7"
    setup_mysql_user "$MYSQL_USER8" "$MYSQL_PASSWORD8"
    setup_mysql_user "$MYSQL_USER9" "$MYSQL_PASSWORD9"
}

# This is from
# https://github.com/docker-library/mariadb/blob/master/docker-entrypoint.sh,
# with small modifications:
#
# - altered to only do initializations, basically just last 'exec
# "$@"' line removed.
#
# - added call to "docker_setup_additional_users", see above
# 
_alt_main() {
    # if command starts with an option, prepend mysqld
    if [ "${1:0:1}" = '-' ]; then
	set -- mysqld "$@"
    fi
    
    # skip setup if they aren't running mysqld or want an option that stops mysqld
    if [ "$1" = 'mysqld' ] && ! _mysql_want_help "$@"; then
	mysql_note "Entrypoint script for MySQL Server ${MARIADB_VERSION} started."
	
	mysql_check_config "$@"
	# Load various environment variables
	docker_setup_env "$@"
	docker_create_db_directories
	
	# If container is started as root user, restart as dedicated mysql user
	if [ "$(id -u)" = "0" ]; then
	    mysql_note "Switching to dedicated user 'mysql'"
	    exec gosu mysql "$BASH_SOURCE" "$@"
	fi
	
	# there's no database, so it needs to be initialized
	if [ -z "$DATABASE_ALREADY_EXISTS" ]; then
	    docker_verify_minimum_env
	    
	    # check dir permissions to reduce likelihood of half-initialized database
	    ls /docker-entrypoint-initdb.d/ > /dev/null
	    
	    docker_init_database_dir "$@"
	    
	    mysql_note "Starting temporary server"
	    docker_temp_server_start "$@"
	    mysql_note "Temporary server started."

	    docker_setup_db
	    docker_setup_additional_users
	    docker_process_init_files /docker-entrypoint-initdb.d/*

	    mysql_note "Stopping temporary server"
	    docker_temp_server_stop
	    mysql_note "Temporary server stopped"

	    echo
	    mysql_note "MySQL init process done. Ready for start up."
	    echo
	fi
    fi
}


_alt_main mysqld

# first-run.sh
