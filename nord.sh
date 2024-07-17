#!/bin/bash

set -e
docker exec ionscale-nord nordvpn "$@"
