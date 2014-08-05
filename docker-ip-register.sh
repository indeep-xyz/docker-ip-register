#!/bin/bash

VERSION=1.0
SUFFIX=mydocker
CONF_PATH=/etc/unbound/unbound.conf.d/mydocker.conf

# - - - - - - - - - - - - - - - - - - -
# initialize

# if not exists, initialize Unbound Configration file
if [ ! -f "$CONF_PATH" ]; then
  cat <<EOT > "$CONF_PATH"
server:
interface: 172.17.42.1
access-control: 172.17.0.0/16 allow
do-ip6: no
local-zone: "${SUFFIX}." static

EOT
fi

# - - - - - - - - - - - - - - - - - - -
# main

for name in `docker ps | awk 'NR > 1 { print $NF }'`
do
  ip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $name`
  hostname="$(echo $name | sed 's![/@:]!-!g').$SUFFIX"

  sed -i "/^ *local-data: *\"$hostname\./d" $CONF_PATH
  echo "local-data: \"$hostname. A $ip\"" >> $CONF_PATH
done

service unbound reload
