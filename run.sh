#!/bin/bash

set -e

SYSTEM_KEY= # keys.system_admin_key
PUBLIC_ADDR= # public address in public_addr 

function ion_exec() {
    local args=$1
    docker exec ionscale-vpn sh -c "${args}"
}

function ion_auth_exec() {
    local args=$1
    ion_exec "ionscale ${args} --addr $PUBLIC_ADDR --system-admin-key $SYSTEM_KEY"
}

function init() {
    docker-compose up -d
    echo "Waiting...."
    sleep 10
    echo "==================="
    echo "Setup for Warp:"
    docker exec ionscale-warp bash -c "cat /tailscaled-setup.log"
    echo "==================="
    echo "Setup for NordVPN:"
    docker exec ionscale-nord bash -c "cat /tailscaled-setup.log"
    echo "==================="
}

function tailnet_exec() {
    local args=("$@")
    local name=$2
    case "$1" in
    create)
        ion_auth_exec "tailnets create --name $name"
        ;;
    list)
        ion_auth_exec "tailnets list"
        ;;
    delete)
        ion_auth_exec "tailnets delete ${args[*]}"
        ;;
    *)
        exit 1
        ;;
    esac
}

function enable_exit_node_exec() {
    local args=("$@")
    local uid=$1
    ion_auth_exec "machines enable-exit-node  --machine-id $uid"
}

function auth_key_exec() {
    local args=("$@")
    local name=$2
    local tailnet=$3
    case "$1" in
    create)
        ion_auth_exec "auth-keys create --expiry 3600d --tag tag:$name --tailnet $tailnet"
        ;;
    list)
        echo "authen keys:"
        ion_auth_exec "auth-keys list --tailnet $2"
        echo "\nmachines:"
        ion_auth_exec "machines list --tailnet $2"
        ;;
    delete)
        ion_auth_exec "auth-keys delete --id $name"
        ;;
    *)
        exit 1
        ;;
    esac
}
function machine_exec() {
    local args=("$@")
    local machine_opt=$1
    case "$machine_opt" in
    get)
        if  [ -z "$2" ]; then
                echo "$0 $machine_opt {machine-id}"
        fi
        local uid=$2
        ion_auth_exec "machines get --machine-id $uid"
    ;;
    list)
        local tailnetName=$2
        if  [ -z "$tailnetName" ]; then
                echo "$0 $machine_opt {Tailnet Name}"
        fi
        ion_auth_exec "machines list --tailnet $tailnetName"
    ;;
    delete)
        local id=$2
        if [ -z "$id" ]; then
                echo "$0 $machine_opt {machine-id}"
        fi
        ion_auth_exec "machines delete --machine-id $id"
    ;;
*)
    exit 1
    ;;
    esac
}

case "$1" in
init)
    init
    ;;
tailnet)
    if [ -z "$2" ]; then
        echo "$0 $1 {create|list|delete} name"
        exit 1
    fi
    tailnet_exec "${@:2}"
    ;;
auth)
    if [ -z "$2" ]; then
        echo "$0 $1 {create|list|delete} name tailscale"
        exit 1
    fi
    auth_key_exec "${@:2}"
    ;;
enable_exit_node)
    if [ -z "$2" ]; then
        echo "$0 $1 {machine-id}"
        exit 1
    fi
    enable_exit_node_exec "${@:2}"
    ;;
machine)
    if [ -z "$2" ]; then
        echo "$0 $1 {get|list|delete} {machine-id}"
        exit 1
    fi
    machine_exec "${@:2}"
    ;;
*)
    echo "Usage: $0 {tailnet|auth|enable_exit_node|machine}"
    exit 1
    ;;

esac
