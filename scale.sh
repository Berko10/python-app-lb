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

echo "Scaling app replicas to $TARGET"

# Define file paths
DOCKER_COMPOSE="docker-compose.yml"
DOCKER_COMPOSE_BAK="${DOCKER_COMPOSE}.bak"
NGINX_CONF="./nginx/nginx.conf"
NGINX_CONF_BAK="${NGINX_CONF}.bak"

# Make backups of the original files
cp $DOCKER_COMPOSE $DOCKER_COMPOSE_BAK
cp $NGINX_CONF $NGINX_CONF_BAK

echo "Created backups at $DOCKER_COMPOSE_BAK and $NGINX_CONF_BAK"

# Update docker-compose.yml
echo "Updating docker-compose.yml..."

# Create the base structure of the new docker-compose.yml
cat > $DOCKER_COMPOSE << EOF
version: '3'

services:
  nginx:
    image: nginx:latest
    container_name: nginx
    ports:
      - "80:80"
    depends_on:
EOF

# Add app dependencies to nginx service
for i in $(seq 1 $TARGET); do
  echo "      - app$i" >> $DOCKER_COMPOSE
done

# Continue with the rest of the nginx service config
cat >> $DOCKER_COMPOSE << EOF
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
    networks:
      - app_network

  app-builder:
    build: ./app
    image: my-flask-app
    entrypoint: [ "echo", "image built" ]
    networks:
      - app_network

EOF

# Add app services
for i in $(seq 1 $TARGET); do
  cat >> $DOCKER_COMPOSE << EOF
  app$i:
    image: my-flask-app
    container_name: app$i
    environment:
      - INSTANCE_ID=$i
    depends_on:
      - db
    volumes:
      - ./logs/app$i:/app/logs
    networks:
      - app_network

EOF
done

# Add database and remaining configuration
cat >> $DOCKER_COMPOSE << EOF
  db:
    image: mysql:latest
    container_name: db
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: app_db
    volumes:
      - ./mysql/db_data:/var/lib/mysql
      - ./logs/db_logs:/var/log/mysql
      - ./mysql/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - app_network

networks:
  app_network:
    driver: bridge

volumes:
  db_data:
EOF

echo "Docker Compose file updated with $TARGET app replicas"

# Now update NGINX configuration
echo "Updating NGINX configuration..."

# Extract NGINX configuration parts
# Assuming a standard format with 'upstream app_backend { ... }' section
UPSTREAM_START=$(grep -n "upstream app_backend {" $NGINX_CONF_BAK | cut -d: -f1)
UPSTREAM_END=$(tail -n +$UPSTREAM_START $NGINX_CONF_BAK | grep -n "}" | head -1 | cut -d: -f1)
UPSTREAM_END=$((UPSTREAM_START + UPSTREAM_END - 1))

# Get content before upstream block
head -n $((UPSTREAM_START - 1)) $NGINX_CONF_BAK > $NGINX_CONF

# Write new upstream block
echo "upstream app_backend {" >> $NGINX_CONF
for i in $(seq 1 $TARGET); do
    echo "    server app$i:5000;" >> $NGINX_CONF
done
echo "}" >> $NGINX_CONF

# Get content after upstream block
tail -n +$((UPSTREAM_END + 1)) $NGINX_CONF_BAK >> $NGINX_CONF

echo "NGINX configuration updated for $TARGET app replicas"

# Ask if user wants to apply changes immediately
read -p "Do you want to (re)start containers now? (y/n): " RESTART
if [[ "$RESTART" =~ ^[Yy]$ ]]; then
    echo "Stopping existing containers..."
    docker-compose -f $DOCKER_COMPOSE_BAK down

    echo "Building image once via app-builder..."
    docker-compose run --rm app-builder

    echo "Starting containers with new configuration..."
    docker-compose up -d

    echo "Containers started successfully"
else
    echo "Changes have been made to configuration files."
    echo "To apply these changes, run: docker-compose down && docker-compose up -d"
fi

echo "Scaling operation complete."
