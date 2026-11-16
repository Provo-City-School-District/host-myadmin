# Host PHPMYADMIN

## Create Network

```bash
docker network create dbmanage-network
```

## Add Network to stack compose file

```yml
networks:
  dbmanage-network:
    external: true
```

## Add network to DB containers

```yml
services:
  mysql:
    networks:
      - normal-network
      - dbmanage-network
```

## Server list

The server dropdown is built automatically: every running container on `dbmanage-network` is listed. After adding a DB container to the network, run `update-container.sh` (or wait for the nightly cron run) for it to show up. A DB container that is stopped when the script runs drops off the list until the next run.

## Start phpMyAdmin

Clone this repository to `/docker/host-myadmin` (the update script expects that path).

### Absolute URI

Each host needs its own `PMA_ABSOLUTE_URI` in `.env`: the address that host is reached at. It must match the real DNS name, or phpMyAdmin builds links and redirects for the wrong host.

```bash
cp .env.example .env
```

Edit `.env` so the line holds this host's address, for example:

```
PMA_ABSOLUTE_URI=https://stage-myadmin.provo.edu/
```

A host that already has a `.env` (it will only contain `PMA_HOSTS`) just needs that line added.

### Start

```bash
bash update-container.sh
```

Check the container picked up the right address:

```bash
docker exec host-phpmyadmin printenv PMA_ABSOLUTE_URI
```

`.env` is not committed. The script adds the server list (`PMA_HOSTS`) to it and replaces only that line on later runs. Until `.env` has both values, `docker compose up -d` refuses to start; after that, plain `docker compose` commands work.

## Automatic Updates

To keep the `phpMyAdmin` container up to date, run `update-container.sh` from cron.

Open your crontab editor:

```bash
  crontab -e
```

Add the following line to run the update script daily at 00:30. Keep it clear of the time other stacks restart their DB containers: a DB that is down when the script runs drops off the server list.

```bash
30 0 * * * /bin/bash /docker/host-myadmin/update-container.sh >> "$HOME/update-phpmyadmin.log" 2>&1
```

The container is only restarted when the image, the compose config, or the server list changed. Failures are written to the log file.

## Large Imports

`UPLOAD_LIMIT` only sets the PHP limits. Apache has its own 1G request body cap, removed by `pma-limits.conf` (mounted by the compose file), so `UPLOAD_LIMIT` is the only value to change. Deploy the conf file alongside `docker-compose.yml`.

Any reverse proxy in front needs a body limit at least as large as `UPLOAD_LIMIT` (`LimitRequestBody` in Apache, `client_max_body_size` in nginx) and a long proxy timeout.

Prefer `.sql.gz` over `.zip`. phpMyAdmin loads zip contents fully into memory.
