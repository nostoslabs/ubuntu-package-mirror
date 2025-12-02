#!/usr/bin/env bash
set -euo pipefail

# Defaults can be overridden with env vars at runtime.
UBUNTU_RELEASES="${UBUNTU_RELEASES:-jammy}"
UBUNTU_MIRROR="${UBUNTU_MIRROR:-http://archive.ubuntu.com/ubuntu}"
SECURITY_MIRROR="${SECURITY_MIRROR:-http://security.ubuntu.com/ubuntu}"
UBUNTU_COMPONENTS="${UBUNTU_COMPONENTS:-main restricted universe multiverse}"
UBUNTU_ARCHES="${UBUNTU_ARCHES:-amd64}"
MIRROR_THREADS="${MIRROR_THREADS:-10}"
MIRROR_BASE_PATH="${MIRROR_BASE_PATH:-/var/spool/apt-mirror}"
MIRROR_PROXY="${MIRROR_PROXY:-}" # e.g. http://proxy:3128
ARCH_EXPR="${UBUNTU_ARCHES// /,}"
umask 022

mirror_config_path="/etc/apt/mirror.list"

write_mirror_config() {
  mkdir -p "${MIRROR_BASE_PATH}/var"

  {
    echo "set base_path ${MIRROR_BASE_PATH}"
    echo "set nthreads ${MIRROR_THREADS}"
    echo "set _tilde 0"
    if [[ -n "${MIRROR_PROXY}" ]]; then
      echo "set use_proxy ${MIRROR_PROXY}"
    fi

    for release in ${UBUNTU_RELEASES}; do
      echo "deb [arch=${ARCH_EXPR}] ${UBUNTU_MIRROR} ${release} ${UBUNTU_COMPONENTS}"
      echo "deb [arch=${ARCH_EXPR}] ${UBUNTU_MIRROR} ${release}-updates ${UBUNTU_COMPONENTS}"
      echo "deb [arch=${ARCH_EXPR}] ${UBUNTU_MIRROR} ${release}-backports ${UBUNTU_COMPONENTS}"
      echo "deb [arch=${ARCH_EXPR}] ${SECURITY_MIRROR} ${release}-security ${UBUNTU_COMPONENTS}"
    done

    echo "clean ${UBUNTU_MIRROR}"
    echo "clean ${SECURITY_MIRROR}"
  } > "${mirror_config_path}"
}

run_sync() {
  write_mirror_config
  echo "Starting apt-mirror sync for releases: ${UBUNTU_RELEASES}"
  apt-mirror "${mirror_config_path}"
  echo "Sync completed."
}

start_server() {
  write_mirror_config
  exec nginx -g "daemon off;"
}

cmd="${1:-serve}"
case "${cmd}" in
  sync)
    run_sync
    ;;
  serve)
    start_server
    ;;
  *)
    echo "Usage: entrypoint [serve|sync]"
    exit 1
    ;;
esac
