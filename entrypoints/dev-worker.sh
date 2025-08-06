#!/bin/bash
set -e

echo "[dev-worker] Starting..."

# Ensure gems are available
bundle check || bundle install

# Start Sidekiq
exec bundle exec sidekiq
