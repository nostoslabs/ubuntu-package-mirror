# Ubuntu package mirror (Docker)

Dockerized apt-mirror + nginx that serves a local copy of Ubuntu repositories. Data is stored on a volume so you can persist it to a Synology share or Kubernetes PVC. You can either mirror everything you care about, or switch to a proxy-caching option noted below.

## Files

- `Dockerfile` – builds an image with apt-mirror and nginx.
- `entrypoint.sh` – generates the mirror config from env vars, runs syncs, or serves content.
- `nginx.conf` – exposes `/ubuntu` and `/ubuntu-security` over port 8080.
- `docker-compose.yml` – convenience for local/Synology deployment with a persistent volume.

## Quickstart (full mirror)

> Warning: a full mirror of multiple releases and architectures is large and will take time and bandwidth. Start with the one release/arch you need.

1) Build the image  
   `docker compose build`

2) Sync once (downloads into the volume)  
   `docker compose run --rm ubuntu-mirror sync`  
   - Defaults: `UBUNTU_RELEASES=jammy`, `UBUNTU_ARCHES=amd64`.  
   - Example for more: `UBUNTU_RELEASES="jammy noble" UBUNTU_ARCHES="amd64 arm64" docker compose run --rm ubuntu-mirror sync`

3) Serve the mirror  
   `docker compose up -d ubuntu-mirror`

4) Point clients at it (replace `mirror.local` with your host/IP): add to `/etc/apt/sources.list` or a new file in `/etc/apt/sources.list.d/local-mirror.list`:

```
deb http://mirror.local:8080/ubuntu jammy main restricted universe multiverse
deb http://mirror.local:8080/ubuntu jammy-updates main restricted universe multiverse
deb http://mirror.local:8080/ubuntu jammy-backports main restricted universe multiverse
deb http://mirror.local:8080/ubuntu-security jammy-security main restricted universe multiverse
```

All packages remain signed by Ubuntu; no extra keys are needed.

5) Re-sync on a schedule  
   Run `docker compose run --rm ubuntu-mirror sync` from cron or a Kubernetes `CronJob` to keep the mirror fresh.

## Environment knobs

- `UBUNTU_RELEASES` – space-separated releases, e.g. `jammy noble`.
- `UBUNTU_ARCHES` – architectures to mirror (apt-mirror uses the value in `[arch=...]`), e.g. `amd64 arm64`.
- `UBUNTU_COMPONENTS` – repo components, default `main restricted universe multiverse`.
- `UBUNTU_MIRROR` / `SECURITY_MIRROR` – override upstreams if you have a preferred source.
- `MIRROR_THREADS` – parallel downloads (default 10).
- `MIRROR_PROXY` – HTTP proxy if you need one.

## Storage

The compose file mounts `mirror-data:/var/spool/apt-mirror`; replace that with a host path or PVC in Kubernetes. Only this directory needs persistence.

## Optional: caching proxy instead of full mirror

If you just want a cache of packages that clients actually request (smaller footprint), you can run apt-cacher-ng:

```
docker run -d --name apt-cacher-ng \
  -p 3142:3142 \
  -v apt-cacher-ng:/var/cache/apt-cacher-ng \
  sameersbn/apt-cacher-ng:latest
```

Then on clients create `/etc/apt/apt.conf.d/01proxy` with:

```
Acquire::http::Proxy "http://mirror.local:3142";
Acquire::https::Proxy "false";
```

This caches downloads on first use instead of mirroring everything up front.
