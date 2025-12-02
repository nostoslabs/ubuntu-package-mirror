# AGENTS.md - Ubuntu Package Mirror Project

## Build Commands
- `docker compose build` - Build the Docker image
- `docker build .` - Alternative Docker build

## Test Commands
- `curl http://localhost:8080/healthz` - Test service health endpoint
- `docker compose run --rm ubuntu-mirror sync` - Test mirror sync functionality

## Lint Commands
- `shellcheck entrypoint.sh` - Lint shell scripts
- `docker run --rm -i hadolint/hadolint < Dockerfile` - Lint Dockerfile

## Code Style Guidelines

### Shell Scripts (entrypoint.sh)
- Use `set -euo pipefail` for strict error handling
- Environment variables with defaults: `${VAR:-default}`
- Functions use lowercase with underscores: `write_mirror_config()`
- Exit with proper codes and usage messages
- Use `umask 022` for file permissions

### Configuration Files
- YAML: 2-space indentation (docker-compose.yml)
- Nginx: Standard nginx configuration style
- Environment variables: UPPERCASE_WITH_UNDERSCORES

### Docker
- Multi-stage builds when possible (single stage here)
- Use `--no-install-recommends` to minimize image size
- Clean up apt cache after installs
- Expose only necessary ports

### Error Handling
- Fail fast with `set -e`
- Use `||` for fallback operations
- Log errors to stderr