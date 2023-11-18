#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export XDG_CONFIG_HOME="${SCRIPT_DIR}/.testenv/config"
export XDG_DATA_HOME="${SCRIPT_DIR}/.testenv/data"
export XDG_STATE_HOME="${SCRIPT_DIR}/.testenv/state"
export XDG_RUNTIME_DIR="${SCRIPT_DIR}/.testenv/run"
export XDG_CACHE_HOME="${SCRIPT_DIR}/.testenv/cache"

mkdir -p "${XDG_CONFIG_HOME}/nvim"
mkdir -p "${XDG_DATA_HOME}/nvim"
mkdir -p "${XDG_STATE_HOME}/nvim"
mkdir -p "${XDG_RUNTIME_DIR}/nvim"
mkdir -p "${XDG_CACHE_HOME}/nvim"

nvim -u "${SCRIPT_DIR}/minimal_init.lua" "${SCRIPT_DIR}/minimal_init.lua"
