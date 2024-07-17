FROM debian:stable-slim

RUN apt-get update && apt-get install -y curl gnupg lsb-release dbus systemctl

# TS
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Nord
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget apt-transport-https ca-certificates && \
    wget -qO /etc/apt/trusted.gpg.d/nordvpn_public.asc https://repo.nordvpn.com/gpg/nordvpn_public.asc && \
    echo "deb https://repo.nordvpn.com/deb/nordvpn/debian stable main" > /etc/apt/sources.list.d/nordvpn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nordvpn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./nord/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT /entrypoint.sh
