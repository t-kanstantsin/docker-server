#!/usr/bin/env bash

for i in "$@"
do
case $i in
    -e=*|--env-file=*)
    ENV_FILES="${i#*=}"
    shift
    ;;
    *)
          # unknown option
    ;;
esac
done

# Get absolute path from the relative
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

# Get index element in array if exist or return -1
indexOf() {
    element=$1 && shift
	array=($@)
    index=$(echo ${array[@]/$element//} | cut -d/ -f1 | wc -w | tr -d ' ')
    lastIndex=$(($(echo ${#array[@]})-1))

    if (( $index > $lastIndex )); then
        echo -1;
    else
        echo $index
    fi
}

# Get package vendor dir
VENDOR_DIR=$(dirname $(dirname $(realpath "${BASH_SOURCE[0]}")))

# Get vendor parent dir
VENDOR_PARENT_DIR=$(sed -n -e 's/\(^.*\)\(\(\/vendor\).*\)/\1/p' <<< "$VENDOR_DIR")
# Get vendor common dir
VENDOR_COMMON_DIR=$(sed -n -e 's/\(^.*\)\(\(\/vendor\).*\)/\2/p' <<< "$VENDOR_DIR")

# Add default env to config
ENV_FILES="${VENDOR_DIR}/docker/.env-default,${ENV_FILES}"

# Detect server init
if [ "$1" = "init" ]; then
    return
fi

# Handle env files
SERVER_ENVS=""
SERVER_ENVS_RECOMPILE_NAMES=()
SERVER_ENVS_RECOMPILE_VALUES=()
IFS=',' read -ra ADDR <<< "$ENV_FILES"
for ENV_FILE in "${ADDR[@]}"; do
    ENV_FILE_FULL_PATH=$(realpath "$ENV_FILE")

    if [ ! -f "$ENV_FILE_FULL_PATH" ]; then
        echo "Env file does not exist (skip): $ENV_FILE"
    else
        # Getting environments for using in current and parent script
        # This environments will be passed in docker compose files
        set -a
        . $ENV_FILE_FULL_PATH
        set +a

        while IFS='=' read -r name value; do
            case "$name" in \#*) continue ;; esac
            if [ ! -z "$name" ] && [ ! -z "$value" ]; then
                # Collect the environments, which will be added to result file
                if [[ $SERVER_ENVS != *" $name"* ]]; then
                    SERVER_ENVS="${SERVER_ENVS} $name"
                fi

                # Collect the environments, which will be recompile
                if [[ $value = *"\${"* ]]; then
                    if [[ ! ${SERVER_ENVS_RECOMPILE_NAMES[@]} =~ " $name " ]]; then
                        SERVER_ENVS_RECOMPILE_NAMES+=("$name")
                    fi

                    nameIndex=$(indexOf $name ${SERVER_ENVS_RECOMPILE_NAMES[@]})

                    SERVER_ENVS_RECOMPILE_VALUES[$nameIndex]=$value
                fi
            fi
        done < $ENV_FILE_FULL_PATH
    fi
done

# Recompile environments
if [ ! -z $PROJECT_ENV_PATH_FORCE ]; then
    TMP_RECOMPILE_ENVS="${PROJECT_ENV_PATH_FORCE}/.env-tmp"
else
    TMP_RECOMPILE_ENVS="${PROJECT_DOCKER_FOLDER}/.env-tmp"
fi

echo -n "" > $TMP_RECOMPILE_ENVS
for recompile_env_name_index in ${!SERVER_ENVS_RECOMPILE_NAMES[@]}; do
    recompile_env_name=${SERVER_ENVS_RECOMPILE_NAMES[$recompile_env_name_index]}
    echo "$recompile_env_name=${SERVER_ENVS_RECOMPILE_VALUES[$recompile_env_name_index]}" >> $TMP_RECOMPILE_ENVS
    . $TMP_RECOMPILE_ENVS
done
rm $TMP_RECOMPILE_ENVS

# Get realpath docker compose files by default
SERVICES_PATHS=""

for SERVICE in $SERVICES; do
    if [ "${SERVICE: -3}" = "yml" ]; then
        if [ "${SERVICE:0:2}" = "!!" ]; then
            SERVICES_PATHS="${SERVICES_PATHS} -f $(realpath "${VENDOR_DIR}/docker/${SERVICE: 2}")"
        else
            SERVICES_PATHS="${SERVICES_PATHS} -f $(realpath "$SERVICE")"
        fi
    fi
done

export SERVICES=$SERVICES_PATHS

# Generated env path
export PROJECT_ENV_PATH="${PROJECT_DOCKER_FOLDER}/.env"
ENV_PATH=$PROJECT_ENV_PATH

if [ ! -z $PROJECT_ENV_PATH_FORCE ]; then
    ENV_PATH="${PROJECT_ENV_PATH_FORCE}/.env-compiled"
fi

# Collect all project environment to result temp env file
if [ "$ENV_PATH" != "" ]; then
    PROJECT_ENV_PATH_TMP=$(dirname "$ENV_PATH")
    if [ -d "$PROJECT_ENV_PATH_TMP" ]; then
        SERVER_ENVS=$(echo "$SERVER_ENVS" | xargs -n1 | sort -u | xargs)

        echo -n "" > "${ENV_PATH}"
        for ENV_NAME in $SERVER_ENVS; do
            case "${!ENV_NAME}" in
                *\ * )
                    echo "$ENV_NAME=\"${!ENV_NAME}\"" >> ${ENV_PATH}
                ;;
                *\=* )
                    echo "$ENV_NAME=\"${!ENV_NAME}\"" >> ${ENV_PATH}
                ;;
                *)
                    echo "$ENV_NAME=${!ENV_NAME}" >> ${ENV_PATH}
                ;;
            esac
        done
    else
        echo "Folder does not exist: $PROJECT_ENV_PATH_TMP"
        exit 1;
    fi
fi