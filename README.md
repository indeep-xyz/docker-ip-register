docker-ip-register
====

this script assist to setup network of Docker containers.  
register 'local-data' records in the Unbound configuration file. registration records are from the running Docker containers.

this script is dependent with some environment. so read the script before run and if require then rewrite parameters. this script is very simple and easy.

## REQUIREMENT

- Unbound service is running
- Unbound configuration file is enabled
- Docker container is running greater than or equal to one

### enable to Unbound configuration file

require to load _/etc/unbound/unbound.conf.d/mydocker.conf_ by Unbound daemon.

normally, this item has been set.

```
# /etc/unbound/unbound.conf
...
include: "/etc/unbound/unbound.conf.d/*.conf"
...
```

## USE

### run

```
./docker-ip-register.sh
```

add records or replace same name records.

hostname format is _Docker container's name_ + _suffix_ . default suffix is _.mydocker_ .

#### help

```
# ./docker-ip-register.sh -h

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
```

### install

```
./install.sh

cd anywhere
docker-ip-register
```

`install.sh` is copy to _/usr/local/bin/_. if you want uninstall then remove it.

## tips

### use in docker container

#### unbound.conf.d/mydocker.conf

- Unbound service is running in Docker host.
- _172.17.42.1_ is default value of _docker0_ 's IP address.
- set to `--dns` option

```
docker run \
  --dns 172.17.42.1 \
  --name $CONTAINER_NAME $IMAGE_NAME
```

### use in foreground

when process of Docker container is running in the foreground, if want to use the newly Unbound settings by `docker-ip-register` then run as following in the shell script.

```
# late-running to `docker-ip-register` in background
(
  sleep 3
  docker-ip-register >/dev/null
) &

# docker run
docker run -i -t \
  --dns 172.17.42.1 \
  --name $CONTAINER_NAME $CONT_IMAGE
```

## AUTHOR

[indeep-xyz](http://indeep.xyz/)
