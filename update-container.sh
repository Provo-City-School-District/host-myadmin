#!/bin/bash

# Pull the latest phpMyAdmin image
echo "Pulling the latest phpMyAdmin image..."
docker pull phpmyadmin:latest

# Rebuild and restart the container
echo "Rebuilding and restarting the phpMyAdmin container..."
cd /docker/host-myadmin
docker compose down
docker compose up -d

echo "Update complete!"