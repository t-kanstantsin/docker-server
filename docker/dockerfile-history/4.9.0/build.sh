#!/usr/bin/env bash

set -o errexit  # exit when a command fails.
set -o pipefail # catch error in pipe operator
set -o nounset  # exit when tries to use undeclared variables.
# set -o xtrace # debug tool

CURRENT_DIR=${CURRENT_DIR:-$(dirname "$0")}

TEST="0"
IMG_NAMESPACE="tkanstantsin/userver-"
#IMG_NAMESPACE="matthewpatell/universal-docker-"
IMG_VERSION=4.9.0
PHP_VERSION="7.4.12"

NGINX_VERSION="1.19.5"
# https://github.com/vision5/ngx_devel_kit
NGINX_DEVEL_KIT_MODULE_VERSION="0.3.1"
# https://github.com/openresty/lua-nginx-module
NGINX_LUA_MODULE_VERSION="0.10.15" # max "0.10.18"
NGINX_LUAJIT_VERSION="2.1"
# https://github.com/openresty/lua-resty-redis
NGINX_LUA_REDIS_VERSION="0.29"

BASE_OS_VERSION="3.11"
BASE_OS="alpine"
IMG="all"

# TODO: add `-help` command.

# Parse input args
while [[ ! $# -eq 0 ]]; do
  case "$1" in
  --test)
    TEST=1
    ;;

  \
    --alt-ns)
    IMG_NAMESPACE="tkanstantsin/userver-"
    ;;
  --ns)
    IMG_NAMESPACE="$2"
    shift
    ;;

  --version)
    IMG_VERSION="$2"
    shift
    ;;
  --php-version)
    PHP_VERSION="$2"
    shift
    ;;
  --nginx-version)
    NGINX_VERSION="$2"
    shift
    ;;
  --os-version)
    BASE_OS_VERSION="$2"
    shift
    ;;

  --dockerfile | -f)
    IMG="$2"
    shift
    ;;

  esac
  shift
done

# Validate args
case "$BASE_OS" in
alpine)
  PHP_FPM="php-fpm-alpine"
  FULL="server-alpine"
  FULL_DEV="server-alpine-dev"
  NGINX="nginx"
  ;;
*)
  echo "Wrong --os parameter: '${BASE_OS}'"
  exit 1
  ;;
esac

if [[ -z "${IMG_VERSION}" ]]; then
  echo "Version must be not empty"
  exit 1
fi

if [[ "${TEST}" == "1" ]]; then
  echo "parsed input params are: ns='${IMG_NAMESPACE}'; version='${IMG_VERSION}'; os='${BASE_OS}'; dockerfile='${IMG}'"
fi

# Build images

# image names
NGINX_NAME="${IMG_NAMESPACE}nginx:${IMG_VERSION}"
PHP_FPM_NAME="${IMG_NAMESPACE}php-fpm:${IMG_VERSION}"
FULL_NAME="${IMG_NAMESPACE}server:${IMG_VERSION}"
FULL_DEV_NAME="${FULL_NAME}-dev"

if [[ "${IMG}" == "nginx" ]] || [[ "${IMG}" == "all" ]]; then
  COMMAND="docker build \\
    --build-arg BASE_IMG=\"alpine:${BASE_OS_VERSION}\" \\
    --build-arg NGINX_VERSION=${NGINX_VERSION} \\
    --build-arg NGINX_DEVEL_KIT_MODULE_VERSION=${NGINX_DEVEL_KIT_MODULE_VERSION} \\
    --build-arg NGINX_LUA_MODULE_VERSION=${NGINX_LUA_MODULE_VERSION} \\
    --build-arg NGINX_LUAJIT_VERSION=${NGINX_LUAJIT_VERSION} \\
    --build-arg NGINX_LUA_REDIS_VERSION=${NGINX_LUA_REDIS_VERSION} \\
    -t \"${NGINX_NAME}\" \\
    -f \"${CURRENT_DIR}/Dockerfile-${NGINX}\" \\
    \"${CURRENT_DIR}\""

  echo "Build nginx image: '${NGINX_NAME}'"
  echo "${COMMAND}"
  if [[ "${TEST}" == "0" ]]; then
    eval "${COMMAND}"
  fi
fi
if [[ "${IMG}" == "fpm" ]] || [[ "${IMG}" == "all" ]]; then
  COMMAND="docker build \\
    --build-arg BASE_IMG=php:${PHP_VERSION}-fpm-${BASE_OS}${BASE_OS_VERSION} \\
    -t \"${PHP_FPM_NAME}\" \\
    -f \"${CURRENT_DIR}/Dockerfile-${PHP_FPM}\" \\
    \"${CURRENT_DIR}\""

  echo "Build php-fpm image: '${PHP_FPM_NAME}'"
  echo "${COMMAND}"
  if [[ "${TEST}" == "0" ]]; then
    eval "${COMMAND}"
  fi
fi
if [[ "${IMG}" == "full" ]] || [[ "${IMG}" == "all" ]]; then
  COMMAND="docker build \\
    --build-arg BASE_IMG=${PHP_FPM_NAME} \\
    -t \"${FULL_NAME}\" \\
    -f \"${CURRENT_DIR}/Dockerfile-${FULL}\" \\
    \"${CURRENT_DIR}\""

  echo "Build full server image: '${FULL_NAME}'"
  echo "${COMMAND}"
  if [[ "${TEST}" == "0" ]]; then
    eval "${COMMAND}"
  fi
fi
if [[ "${IMG}" == "full-dev" ]] || [[ "${IMG}" == "all" ]]; then
  COMMAND="docker build \\
    --build-arg BASE_IMG=${FULL_NAME} \\
    -t \"${FULL_DEV_NAME}\" \\
    -f \"${CURRENT_DIR}/Dockerfile-${FULL_DEV}\" \\
    \"${CURRENT_DIR}\""

  echo "Build full server for dev image: '${FULL_DEV_NAME}'"
  echo "${COMMAND}"
  if [[ "${TEST}" == "0" ]]; then
    eval "${COMMAND}"
  fi
fi

if [[ "${TEST}" == "1" ]]; then
  echo "test finished successfully"
fi
