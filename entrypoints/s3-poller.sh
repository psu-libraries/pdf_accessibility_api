#!/bin/bash
set -e

echo "[s3-poller] Starting..."

# Ensure gems are available
bundle check || bundle install

# Start Sidekiq
exec bundle exec rake s3:check_final_files_loop