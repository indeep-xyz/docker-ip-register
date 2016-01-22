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

this script assist to setup network of Docker containers.
register 'local-data' records in the Unbound configuration file. registration records are from the running Docker containers.

[search_term]
  if passed, echo record that searched from configuration file.
  if not passed, update configuration file.

[option]
  -c  echo path of configuration file and exit.
  -r  reset configuration file.
  -s  echo suffix string and exit.
EOT
       exit 0;;
  esac
done

shift `expr $OPTIND - 1`

# - - - - - - - - - - - - - - - - - - -
# function

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
# echo Unbound records by hostname string
#
# args
# $1 ... hostname
echo_by_hostname() {

  hostname="`echo "$1" | sed 's/\./\\\\./g'`"

  while read conf;
  do
    echo $conf | sed -n "/^local-data:.*\"[^ ]*$hostname[^ ]* /p"
  done < "$CONF_PATH"
}

# = =
# echo Unbound records by IP address string
#
# args
# $1 ... IP address
echo_by_ip() {

  ip="`echo "$1" | sed 's/\./\\\\./g'`"

  while read conf;
  do
    echo $conf | sed -n "/^local-data:.* [^ ]*$ip[^ ]*\"/p"
  done < "$CONF_PATH"
}

# = =
# echo IP-address of the running docker bridge
#
# args
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
# echo header of a configuration setting for Unbound
echo_unbound_config() {
  local IP=`echo_bridge_ip`
  cat <<EOT
server:
interface: $IP
access-control: 172.17.0.0/16 allow
do-ip6: no
local-zone: "${SUFFIX}." static
EOT
}

# - - - - - - - - - - - - - - - - - - -
# initialize

# if not exists, initialize Unbound Configuration file
if [ ! -f "$CONF_PATH" ]; then
  echo_unbound_config > "$CONF_PATH"
fi

# - - - - - - - - - - - - - - - - - - -
# main

# check argument
if [ -z "$1" ]; then

  # if none, update configuration file
  update

# check argument
elif [ -z "`echo "$1" | sed 's/[0-9\.]//g'`" ]; then

  # if [0-9.] only
  # - echo configuration data by IP address
  echo_by_ip "$1"
else

  # if not [0-9.] only
  # - echo configuration data by hostname
  echo_by_hostname "$1"
fi

