# XPd (XPCoinウォレット) Dockerイメージ

XPd(XPCoinウォレット)をDocker化します。

英語版のREADMEは[こちら](https://github.com/xpjp/xp-wallet-docker/blob/master/README.md)

## Description

XPdはXPdウォレットという名で知られるXPCoinのデーモンプログラムです。

このDockerイメージではXPdをビルドしたものに加え、下記の機能を追加しています。

- 初回起動時にブートストラップを自動でダウンロードし、配置します。
- 初期設定のノード情報をXP-JPチームが提供しているノードに置き換えます。

## 使い方

### A. docker-composeを使う場合

docker-composeが使える状態であることが前提です。

起動:

1. docker-compose.ymlをダウンロードします。Gitリポジトリをcloneする必要はありません。
1. `docker-compose up -d`を実行してXPdを起動します。
1. 必要に応じて`docker-compose logs wallet`でログを表示します。

```shell
$ curl -L https://raw.githubusercontent.com/xpjp/xp-wallet-docker/master/docker-compose.yml -o docker-compose.yml     #  (1)
$ docker-compose up -d            #  (2)

$ docker-compose logs -f wallet   #  (3)
```

終了:

1. `docker-compose stop`を実行してコンテナを停止します。

```shell
$ docker-compose stop       #  (1)
$ docker-compose rm         #  必要に応じて
or
$ docker-compose down       #  上記2つのコマンドをまとめて実行します
```

#### おすすめの設定

Dockerボリュームについて:

XPdのデータファイル(ウォレットデータを含む)はDockerボリュームに配置されます。
Dockerボリュームを削除してしまうとウォレットデータも消えてしまいます。

下記のようにdocker-compose.ymlを編集し、ホストのディレクトリをコンテナに
直接マウントすることを勧めます。

```
volumes:
  wallet-data:
↓
volumes:
  wallet-data:
    driver_opts:
      type: none
      device: /path/to/data_dir
      o: bind
```

この設定では`docker-compose down -v`や`docker volume prune`といった
Dockerコマンドでボリュームを削除してしまっても、データそのものはホストの
データディレクトリに残ります。

公開するポートについて:

28192/tcp ポートだけを開けましょう。

Dockerfileでは 28191/tcp もEXPOSEに記載していますが、このポートはRPCで
使用するもので、世界中から接続できるようにする必要はほぼありません。

### B. docker-composeを使わない場合

`docker-compose.yml`ファイル無しでもXPdコンテナを起動することは可能です。

起動:

1. `docker run -d [options] xpjp/xpd`を実行してXPdを起動します。
1. 必要に応じて`docker logs -f <コンテナID>`でログを表示します。

```shell
$ docker run -d -v </path/to/dir>:/home/wallet/.XP -p 28192:28192 xpjp/xpd    #  (1)
$ docker ps                     #  コンテナIDを調べます
$ docker logs -f <コンテナID>   #  (2)
```

Stop:

1. `docker stop`を実行してコンテナを停止します。

```shell
$ docker stop <コンテナID>    #  (1)
$ docker rm <コンテナID>      #  as you need.
```

## License

[MIT](https://github.com/xpjp/xp-wallet-docker/blob/master/LICENSE)

## Author

[moochannel](https://github.com/moochannel)
