#!/bin/bash

TARGET=$1

if [ -z "$TARGET" ]; then
  echo "Usage: ./scale.sh <number>"
  echo "Example: ./scale.sh 5 - to scale to 5 app containers"
  exit 1
fi

# Validate that TARGET is a positive integer
if ! [[ "$TARGET" =~ ^[1-9][0-9]*$ ]]; then
  echo "Error: Target must be a positive integer"
  exit 1
fi

echo "Scaling app service to $TARGET replicas..."

# App service name is "app"
APP_SERVICE_NAME="app"

# Scale the app service using the recommended method
docker-compose up -d --no-recreate --scale "$APP_SERVICE_NAME"="$TARGET"

echo "App service scaled to $TARGET replicas."

# Wait a few seconds to ensure containers are up (adjust if needed)
sleep 5

echo "Reloading NGINX configuration..."
docker exec -it $(docker-compose ps -q nginx) nginx -s reload

echo "Scaling operation complete and NGINX reloaded."
