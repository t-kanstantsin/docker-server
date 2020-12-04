#!/usr/bin/env bash

set -o errexit  # exit when a command fails.
set -o pipefail # catch error in pipe operator
set -o nounset  # exit when tries to use undeclared variables.
# set -o xtrace # debug tool

CURRENT_DIR=${CURRENT_DIR:-$(dirname "$0")}

IMG_NAMESPACE="tkanstantsin/userver"

IMG_VERSION=4.8.0

BASE_OS="alpine"
BASE_OS_VERSION="3.11"

PHP_VERSION="7.3.21"

NGINX_VERSION="1.19.1"
NGINX_DEVEL_KIT_MODULE_VERSION="0.3.1"
NGINX_LUA_MODULE_VERSION="0.10.15"
NGINX_LUAJIT_VERSION="2.1"
NGINX_LUA_REDIS_VERSION="0.28"

IMG="all"

# Dockerfile names
DF_NGINX=Dockerfile-nginx-alpine
DF_PHP_FPM=Dockerfile-php-fpm-alpine
DF_SERVER=Dockerfile-server-alpine
DF_SERVER_DEV=Dockerfile-server-alpine-dev

# image names
NGINX_TAG="${IMG_NAMESPACE}-nginx:${IMG_VERSION}"
PHP_FPM_TAG="${IMG_NAMESPACE}-php-fpm:${IMG_VERSION}"
PHP_SERVER_TAG="${IMG_NAMESPACE}-server:${IMG_VERSION}"
PHP_SERVER_DEV_TAG="${PHP_SERVER_TAG}-dev"

# TODO: add `-help` command.

# Input args
TEST="0"
NO_CACHE=""

# Parse input args
while [[ ! $# -eq 0 ]]; do
  case "$1" in
  --test)
    TEST="1"
    ;;

  --no-cache)
    NO_CACHE="--no-cache"
    ;;

  --dockerfile | -f)
    IMG="$2"
    shift
    ;;

  esac
  shift
done

echo "Build ${IMG_NAMESPACE} for ${IMG_VERSION}"
echo "${BASE_OS}:${BASE_OS_VERSION}; php:${PHP_VERSION}; nginx:${NGINX_VERSION}"

function evalCommand() {
  local IMAGE=$1
  local COMMAND=$2

  echo "Build image: '${IMAGE}'"
  echo "${COMMAND}"
  if [[ "${TEST}" == "0" ]]; then
    eval "${COMMAND}"
  fi
  echo ""
}

function createCommand() {
  local BASE_IMG=$1
  local TAG=$2
  local DOCKERFILE=$3

  echo "docker build \\
    --build-arg BASE_IMG=${BASE_IMG} \\
    ${NO_CACHE} \\
    -t \"${TAG}\" \\
    -f \"${DOCKERFILE}\" \\
    \"${CURRENT_DIR}\""
}

# Build images
if [[ "${IMG}" == "nginx" ]] || [[ "${IMG}" == "all" ]]; then
  COMMAND="docker build \\
    ${NO_CACHE} \\
    --build-arg BASE_IMG=\"${BASE_OS}:${BASE_OS_VERSION}\" \\
    --build-arg NGINX_VERSION=\"${NGINX_VERSION}\" \\
    --build-arg NGINX_DEVEL_KIT_MODULE_VERSION=\"${NGINX_DEVEL_KIT_MODULE_VERSION}\" \\
    --build-arg NGINX_LUA_MODULE_VERSION=\"${NGINX_LUA_MODULE_VERSION}\" \\
    --build-arg NGINX_LUAJIT_VERSION=\"${NGINX_LUAJIT_VERSION}\" \\
    --build-arg NGINX_LUA_REDIS_VERSION=\"${NGINX_LUA_REDIS_VERSION}\" \\
    -t \"${NGINX_TAG}\" \\
    -f \"${CURRENT_DIR}/${DF_NGINX}\" \\
    \"${CURRENT_DIR}\""

  evalCommand "${NGINX_TAG}" "${COMMAND}"
fi
if [[ "${IMG}" == "fpm" ]] || [[ "${IMG}" == "all" ]]; then
  FPM_BASE_IMG="php:${PHP_VERSION}-fpm-${BASE_OS}${BASE_OS_VERSION}"
  COMMAND=$(createCommand "${FPM_BASE_IMG}" "${PHP_FPM_TAG}" "${DF_PHP_FPM}")
  evalCommand "${PHP_FPM_TAG}" "${COMMAND}"
fi
if [[ "${IMG}" == "full" ]] || [[ "${IMG}" == "all" ]]; then
  COMMAND=$(createCommand "${PHP_FPM_TAG}" "${PHP_SERVER_TAG}" "${DF_SERVER}")
  evalCommand "${PHP_SERVER_TAG}" "${COMMAND}"
fi
if [[ "${IMG}" == "full-dev" ]] || [[ "${IMG}" == "all" ]]; then
  COMMAND=$(createCommand "${PHP_SERVER_TAG}" "${PHP_SERVER_DEV_TAG}" "${DF_SERVER_DEV}")
  evalCommand "${PHP_SERVER_DEV_TAG}" "${COMMAND}"
fi

echo "Build tags:"
echo "${NGINX_TAG}"
echo "${PHP_FPM_TAG}"
echo "${PHP_SERVER_TAG}"
echo "${PHP_SERVER_DEV_TAG}"
echo ""

if [[ "${TEST}" == "1" ]]; then
  echo "TEST run finished successfully"
fi
