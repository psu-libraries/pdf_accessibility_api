#!/bin/bash
set -e

echo "[dev-mock-remediation-tool] Starting..."

# Ensure gems are available
bundle check || bundle install

# Run tool
exec bundle exec bin/mock_remediation_tool
