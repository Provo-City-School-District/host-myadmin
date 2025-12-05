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

## Automatic Updates

To ensure the `phpMyAdmin` container stays up to date, follow these steps:
To run this script automatically, add a cron job:

Open your crontab editor:

```bash
  crontab -e
```

Add the following line to run the update script daily at midnight:

```bash
0 0 * * * /bin/bash /path/to/update-phpmyadmin.sh
```

Replace `/path/to/update-phpmyadmin.sh` with the actual path to the script.

The script is included in the repository.
