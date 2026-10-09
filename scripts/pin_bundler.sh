#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 <base-image> [bundler-version]

Example:
  $0 harbor.libraries.psu.edu/library/ruby-3.4.11-node-22-yarn-4.18.1

If bundler-version is omitted, the script reads it from Gemfile.lock (BUNDLED WITH).
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

BASE_IMAGE=${1:-}
BUNDLER_VERSION=${2:-}

if [ -z "$BASE_IMAGE" ]; then
  echo "Error: base image required" >&2
  usage
  exit 1
fi

if [ -z "$BUNDLER_VERSION" ]; then
  if [ ! -f Gemfile.lock ]; then
    echo "Gemfile.lock not found and no bundler version provided" >&2
    exit 1
  fi
  BUNDLER_VERSION=$(grep -A1 "^BUNDLED WITH" Gemfile.lock | tail -n1 | tr -d '[:space:]')
fi

echo "Using base image: $BASE_IMAGE"
echo "Using Bundler: $BUNDLER_VERSION"

# Ensure working tree is clean
if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree has uncommitted changes. Please commit or stash them before running this script." >&2
  git status --porcelain
  exit 1
fi

echo "Launching container to install Bundler and update lockfile..."
docker run --rm -v "$PWD":/app -w /app --user root "$BASE_IMAGE" bash -lc "set -euo pipefail
  gem install bundler -v ${BUNDLER_VERSION}
  bundle _${BUNDLER_VERSION}_ update --bundler
  bundle _${BUNDLER_VERSION}_ install
"

echo "Checking for changes to Gemfile.lock..."
if git diff --name-only -- Gemfile.lock | grep -q Gemfile.lock; then
  git add Gemfile.lock Gemfile || true
  git commit -m "Pin Bundler to ${BUNDLER_VERSION} for ${BASE_IMAGE}" || true
  echo "Committed Gemfile.lock"
else
  echo "No changes to Gemfile.lock"
fi

echo "Done. If you changed Gemfile.lock, push the commit and update Dockerfiles to install Bundler ${BUNDLER_VERSION}."
