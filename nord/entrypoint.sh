#!/bin/bash

set -e

function run_nord() {
    /etc/init.d/nordvpn start
    sleep 5
}

# start tailscaled before
function run_tailscaled() {
    mkdir -p /var/lib/dpkg
    touch /var/lib/dpkg/status
    systemctl start tailscaled
    (tailscale up --advertise-exit-node=true --accept-dns=true --accept-routes=true --login-server="$PUBLIC_ADDR" >/tailscaled-setup.log 2>&1 &)
}

run_tailscaled
run_nord
bash
