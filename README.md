# XPd (XPCoin Wallet) runs inside a Docker container

Dockerized XPCoin Wallet

Japanese README is [here](https://github.com/xpjp/xp-wallet-docker/blob/master/README.ja.md)

## Description

XPd is an XPCoin daemon program aka XPCoin Wallet.

This docker image contains XPd and some additional features:

- Download and deploy XP bootstrap files on first boot.
- Replace initial XPd nodes with what XP-JP team provide ones.

## How to use

### A. With docker-compose

(Are you ready to use docker-compose?)

Start:

1. Download docker-compose.yml file. You don't need clone this repository.
1. Run daemon with `docker-compose up -d` command.
1. Watch container log with `docker-compose logs wallet` as you need.

```shell
$ curl -L https://raw.githubusercontent.com/xpjp/xp-wallet-docker/master/docker-compose.yml -o docker-compose.yml     #  (1)
$ docker-compose up -d              #  (2)

$ docker-compose logs -f wallet     #  (3)
```

Stop:

1. Stop daemon with `docker-compose stop` command.

```shell
$ docker-compose stop       #  (1)
$ docker-compose rm         #  as you need
or
$ docker-compose down       #  same as above two commands
```

#### Recommend settings

Docker volume:

XPd's data files (include Wallet data) are placed in docker volume. If you remove volume, your wallet will go away.

So I suggest mounting host directory with edit docker-compose.yml file.

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

With this setting, even if you remove the volume with docker commands like `docker-compose down -v` or `docker volume prune`, the payload of the data directory will remain in the host.

Publish ports:

Just only open 28192/tcp port.

28191/tcp is also exposed in Dockerfile, but it is used as RPC. It is not needed to be connected from worldwide in many cases.

### B. Without docker-compose

You can run XPd container without `docker-compose.yml` file.

Start:

1. Run daemon with `docker run -d [options] xpjp/xpd` command.
1. Watch container log with `docker logs -f <container-id>` as you need.

```shell
$ docker run -d -v </path/to/dir>:/home/wallet/.XP -p 28192:28192 xpjp/xpd        #  (1)
$ docker ps     #  Looking for container id
$ docker logs -f <container-id>     #  (2)
```

Stop:

1. Stop daemon with `docker stop` command.

```shell
$ docker stop <container-id>    #  (1)
$ docker rm <container-id>      #  as you need.
```

## License

[MIT](https://github.com/xpjp/xp-wallet-docker/blob/master/LICENSE)

## Author

[moochannel](https://github.com/moochannel)
