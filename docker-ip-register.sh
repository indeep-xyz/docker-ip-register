#!/bin/bash

MY_VERSION=1.1
MY_NAME=docker-ip-register
SUFFIX=mydocker
CONF_PATH=/etc/unbound/unbound.conf.d/mydocker.conf

# - - - - - - - - - - - - - - - - - - -
# command option

while getopts csrh OPT
do
  case $OPT in
    c) echo "$CONF_PATH"; exit 0;;
    s) echo "$SUFFIX"; exit 0;;
    r) rm "$CONF_PATH";;
    h) cat <<EOT
$MY_NAME [option] [search_term]

This script assist to setup network of Docker containers.
It registers 'local-data' records to the Unbound configuration file.

[search_term]
  If exists, echo record filtered by the term from the configuration file.
  If not exists, update the configuration file.

[option]
  -c  Echo path of the configuration file.
  -r  Reset the configuration file.
  -s  Echo suffix string of the registering domain name.
EOT
       exit 0;;
  esac
done

shift `expr $OPTIND - 1`

# - - - - - - - - - - - - - - - - - - -
# functions

# = =
# Update Unbound configuration file.
# The registration data are automatically gotten
# from the running docker containers.
update() {
  for name in `docker ps | awk 'NR > 1 { print $NF }'`
  do
    ip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $name`
    hostname="$(echo $name | sed 's![/@:]!-!g').$SUFFIX"

    sed -i "/^ *local-data: *\"$hostname\./d" $CONF_PATH
    echo "local-data: \"$hostname. A $ip\"" >> $CONF_PATH
  done

  service unbound reload
}

# = =
# Echo IP-address of the running docker bridge.
echo_bridge_ip() {
  if type ip > /dev/null 2>&1; then
    ip -f inet addr show dev docker0 \
        | sed -nr 's|^ *inet ([0-9.]+).*|\1|p'
  else
    ifconfig docker0 \
        | sed -nr 's|^ *inet addr:([0-9.]+).*|\1|p'
  fi
}

# = =
# Echo header of configuration setting for Unbound.
echo_initial_config() {
  local IP=`echo_bridge_ip`
  cat <<EOT
server:
interface: $IP
access-control: 172.17.0.0/16 allow
do-ip6: no
local-zone: "${SUFFIX}." static
EOT
}

# = =
# Echo Unbound records filtered by hostname.
#
# args
# $1 ... hostname
echo_records_by_hostname() {
  hostname="`echo "$1" | sed 's/\./\\\\./g'`"

  while read conf;
  do
    echo $conf | sed -n "/^local-data:.*\"[^ ]*$hostname[^ ]* /p"
  done < "$CONF_PATH"
}

# = =
# Echo Unbound records filtered by IP-address.
#
# args
# $1 ... IP-address
echo_records_by_ip() {
  ip="`echo "$1" | sed 's/\./\\\\./g'`"

  while read conf;
  do
    echo $conf | sed -n "/^local-data:.* [^ ]*$ip[^ ]*\"/p"
  done < "$CONF_PATH"
}

# - - - - - - - - - - - - - - - - - - -
# guard

if ! type unbound > /dev/null 2>&1; then
  echo 'Can not find Unbound command'
  exit 1
fi

if [ ! -d `dirname "$CONF_PATH"` ]; then
  echo 'Does not exist a configuration directory for Unbound'
  exit 1
fi

# - - - - - - - - - - - - - - - - - - -
# initialize

# if not exists, initialize Unbound Configuration file
if [ ! -f "$CONF_PATH" ]; then
  echo_initial_config > "$CONF_PATH"
fi

# - - - - - - - - - - - - - - - - - - -
# main

# check argument
if [ -z "$1" ]; then
  # if nothing, update configuration file
  update

# check argument => /[0-9.]/
elif [ -z "`echo "$1" | sed 's/[0-9\.]//g'`" ]; then
  echo_records_by_ip "$1"
else
  echo_records_by_hostname "$1"
fi
