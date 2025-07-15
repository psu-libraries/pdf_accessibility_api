# Wait for MariaDB
until bash -c "echo > /dev/tcp/db/3306" 2>/dev/null; do
  echo "Waiting for MariaDB..."
  sleep 1
done
sleep 2