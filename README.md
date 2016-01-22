docker-ip-register
====

This script assists to setup network of Docker containers.

It registers 'local-data' records to the Unbound configuration file. The registration records are gotten from the running Docker containers.

It has some options. Before you run, read it and rewrite parameters when you need. This script is very simple.

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

Add new records or replace records.

The format of hostname is _a name of Docker container_ + _suffix_. default suffix is _.mydocker_.

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

The installation is just to copy to _/usr/local/bin/_. If you want uninstall then remove it.

tips
----

### For docker container

~~~shell
docker run -d \
  --dns 172.17.0.1 \
  --name $CONTAINER_NAME $IMAGE_NAME
~~~

- _172.17.0.1_ is a default IP-address of _docker0_.

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
