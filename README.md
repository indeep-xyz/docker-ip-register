docker-ip-register
====

This script assists to setup network of Docker containers.

It registers 'local-data' records to the Unbound configuration file. The source of registration records is gotten IP-addresses and container names from the running containers.

It has some options. Before you run, read it and rewrite parameters if you need. This script is simple.

REQUIREMENT
----

- Unbound service is running.
- Some Docker containers are running.
- A running user has the authenfication as root.

### Enable to load the configuration file for Unbound

Unbound daemon must be able to load the file. You may need to set a line the following to the main file.

~~~
# /etc/unbound/unbound.conf
...
include: "/etc/unbound/unbound.conf.d/*.conf"
...
~~~

The default file path managed by docker-ip-register is "/etc/unbound/unbound.conf.d/mydocker.conf".

USE
----

### run

~~~shell
./docker-ip-register.sh
~~~

Add new records or rewrite records when you run.

The format of hostname is a name of Docker container + suffix. The default suffix in this tool is "_.mydocker_".

#### help

~~~
# ./docker-ip-register.sh -h

$MY_NAME [option] [search_term]

This script assists to setup network of Docker containers.
It registers 'local-data' records to the Unbound configuration file.

[search_term]
  If exists, echo records filtered by the term from the configuration file.
  If not exists, update the configuration file.

[option]
  -c  Set path of the configuration file.
  -C  Echo path of the configuration file.
  -r  Reset the configuration file.
  -s  Set suffix of the registering hostname.
  -S  Echo suffix of the registering hostname.
  -v  Echo my version.
~~~

### install

~~~shell
cp docker-ip-register.sh /usr/local/bin/docker-ip-register
chown root:root /usr/local/bin/docker-ip-register
~~~

The installation is just to copy into _/usr/local/bin_ directory. If you want uninstall then remove it.

tips
----

### Run docker container

The command options at `docker run` is the following when Unbound server runs in Docker host.

~~~shell
docker run -d \
  --dns 172.17.0.1 \
  --name $CONTAINER_NAME $IMAGE_NAME
~~~

- _172.17.0.1_ is a default IP-address of Docker's bridge network (_docker0_).

### Lazy execution

You should excute lazily this script in case of that you make a container run in foreground.

~~~shell
# docker-ip-register executes in background
(
  sleep 3
  docker-ip-register >/dev/null
) &

# docker run
docker run -i -t \
  --dns 172.17.0.1 \
  --name $CONTAINER_NAME $CONT_IMAGE
~~~

AUTHOR
----

[indeep-xyz](http://indeep.xyz/)
