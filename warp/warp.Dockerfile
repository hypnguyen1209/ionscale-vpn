FROM ubuntu:22.04

RUN apt-get update && apt-get upgrade -y && apt-get install -y curl gnupg lsb-release dbus systemctl

# TS
RUN curl -fsSL https://tailscale.com/install.sh | sh

# WARP
RUN curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list

RUN apt-get update && apt-get install -y cloudflare-warp && apt-get clean

# Accept Cloudflare WARP TOS
RUN mkdir -p /root/.local/share/warp \
  && echo -n 'yes' > /root/.local/share/warp/accepted-tos.txt

ENV WARP_LICENSE_KEY=""

COPY ./warp/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT /entrypoint.sh
