#!/bin/bash
set -e

# Wait for MariaDB
until bash -c "echo > /dev/tcp/db/3306" 2>/dev/null; do
  echo "Waiting for MariaDB..."
  sleep 1
done

# Wait for Redis
until bash -c "echo > /dev/tcp/redis/6379" 2>/dev/null; do
  echo "Waiting for Redis..."
  sleep 1
done

# Continue
exec "$@"