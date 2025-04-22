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