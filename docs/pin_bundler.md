# Pin Bundler and Ruby in Docker-based builds

This document describes the recommended steps to pin Bundler and Ruby when building Docker images that run `bundle install`. Use the `scripts/pin_bundler.sh` script provided to automate the common workflow.

## Why
- Bundler is installed as a Ruby gem and can vary across environments. If the `Gemfile.lock` `BUNDLED WITH` version differs from the Bundler running in the image, Bundler may auto-install a different version and restart, causing unexpected behavior during Docker builds.
- Pinning ensures reproducible builds across developer machines, CI, and your Docker images.

## Summary (high level)
1. Run a container based on the target base image (the image in your Dockerfile `FROM` line).
2. Install the Bundler version recorded in `Gemfile.lock` inside that container (as `root`).
3. Run `bundle _<version>_ update --bundler` to update the lockfile's `BUNDLED WITH` and then `bundle _<version>_ install` to build gems for that Ruby.
4. Commit `Gemfile.lock` (and `Gemfile` if you changed `ruby` version) to source control.
5. Pin the Bundler version in the `Dockerfile` by installing the same Bundler gem before running `bundle install`.
6. Add a CI check that confirms `Gemfile.lock` `BUNDLED WITH` matches the Dockerfile pin.

## Script (recommended)
Use the included script: `scripts/pin_bundler.sh`.

Usage:

```bash
# from repository root
scripts/pin_bundler.sh <base-image> [bundler-version]

# example:
scripts/pin_bundler.sh harbor.libraries.psu.edu/library/ruby-3.4.11-node-22-yarn-4.18.1
```

If `bundler-version` is omitted, the script extracts the version from `Gemfile.lock` (`BUNDLED WITH` section).

## CI snippet
Fail the build if the two pins diverge:

```bash
# example CI step
lock=$(awk '/BUNDLED WITH/{getline; print}' Gemfile.lock | tr -d '[:space:]')
dockerfile_pin=$(awk -F'=' '/BUNDLER_VERSION/ {print $2}' Dockerfile | tr -d '" \t') || true
if [ -n "$dockerfile_pin" ] && [ "$lock" != "$dockerfile_pin" ]; then
  echo "Bundler mismatch: Gemfile.lock=$lock vs Dockerfile=$dockerfile_pin" >&2
  exit 1
fi
```

## Notes
- Prefer pinning exact Ruby patch versions (e.g. `ruby '3.4.11'` in `Gemfile` and using a base image with that exact Ruby). This yields the most reproducible builds.
- If you intentionally accept patch upgrades, set `ruby '>= 3.4.9'` and use `ENV BUNDLE_IGNORE_RUBY_VERSION=1` in the Dockerfile, but this may hide incompatibilities.
- Keep `vendor/bundle/` ignored in `.gitignore` (we add it to `.gitignore` in this repo).

## Support
If you want, I can:
- Add a CI job that enforces the Bundler pin.
- Run the script across multiple repositories/images in your org (requires registry access and network). 
