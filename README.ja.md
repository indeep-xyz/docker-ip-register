docker-ip-register
====

Docker コンテナのネットワーク設定をサポートするツールです。

起動中の Docker コンテナから得た IP アドレスとコンテナ名を紐付けて、Unbound の 'local-data' の設定を追加します。

いくつか独自の設定があるので、必要があればスクリプト中のパラメータを書き換えてください。

REQUIREMENT
----

- Unbound サービスが起動している。
- Docker コンテナが 1 つ以上起動している。
- 実行ユーザーが root 権限をもつ。

### Unbound の設定ファイルの有効化について

docker-ip-register を利用するには、このツールが扱う設定ファイルを Unbound デーモンが読めるようにしておく必要があります。必要があれば Unbound の主設定ファイルに以下の記述を加えてください。

~~~
# /etc/unbound/unbound.conf
...
include: "/etc/unbound/unbound.conf.d/*.conf"
...
~~~

ちなみに、このツールが用いる標準の設定ファイルのパスは _/etc/unbound/unbound.conf.d/mydocker.conf_ です。

USE
----

### run

~~~shell
./docker-ip-register.sh
~~~

実行すると新しいレコードが追加されるか、既存のレコードが書き換えられます。

各レコードのホスト名は Docker のコンテナ名と接尾辞を繋げたものです。標準の接尾辞は _.mydocker_ です.

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

インストールは _/usr/local/bin_ 内にコピーして権限を与えるだけです。アンインストール時はそれを削除するだけです。

tips
----

### Docker コンテナの起動時

Docker ホストで Unbound サーバーを起動している状況での `docker run` のオプションは以下のような感じです。

~~~shell
docker run -d \
  --dns 172.17.0.1 \
  --name $CONTAINER_NAME $IMAGE_NAME
~~~

- _172.17.0.1_ は Docker が扱うブリッジ・ネットワーク _docker0_ の標準のアドレスです。

### 遅延実行

フォアグラウンドで実行しながらコンテナ内から自身の IP アドレスを参照したい場合は、以下のように遅延実行するといいです。

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
