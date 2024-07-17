# ionscale-vpn

> **Note**:
> I built a self-hosted tailscale setup solution for the purpose of being able to use an external network at the office and still be able to use it remotely very simply.

**What is Tailscale?**

[Tailscale](https://tailscale.com) is a VPN service that makes the devices and applications you own accessible anywhere in the world, securely and effortlessly. 
It enables encrypted point-to-point connections using the open source [WireGuard](https://www.wireguard.com/) protocol, which means only devices on your private network can communicate with each other.

**What is ionscale?**

While the Tailscale software running on each node is open source, their centralized "coordination server" which act as a shared drop box for public keys is not.

_ionscale_ aims to implement such lightweight, open source alternative Tailscale control server.

## Setup
First, we need to configure the DNS of 1 public domain/subdomain to the IP VPS address we will use to deploy this solution.

You can use dig to make sure that DNS records are propagated:

```bash
dig ionscale.example.com
```

Next, you need to rename the ionscale configuation located in the `./ionscale` folder:

```bash
mv config.yaml.example config.yaml
```

Modify this config to your options setup:

```yaml
listen_addr: ":443"
public_addr: "ionscale.example.com:443"  # change to your domain/subdomain
stun_public_addr: "ionscale.example.com:3478" # change to your domain/subdomain

tls:
  acme: true
  acme_email: "example@ionscale.com" # not required

keys:
  system_admin_key: "sha256(randomstring)" # Ex: tr -dc A-Za-z0-9 </dev/urandom | head -c 13 | sha256sum

database:
  url: "/data/ionscale.db?_pragma=busy_timeout(5000)&_pragma=journal_mode(WAL)"

logging:
  level: info
```

Modify file docker-compose.yml:

```yaml
...
environment:
      - PUBLIC_ADDR= # public address in public_addr 
      - WARP_LICENSE_KEY= # License key for Warp+ (not required)
...
environment:
      - PUBLIC_ADDR= # public address in public_addr 
```

Next, i created the file ./run.sh by mistake and optimizes it when you execute it into the container

```bash
chmod +x ./run.sh
./run.sh init
```

![image](https://github.com/user-attachments/assets/5e62b94a-e594-4f75-bdb2-781512c33094)

Next, before creating an auth key, you need to create a tailnet first:

> ./run.sh tailnet create \<name for tailnet\>

Ex:

```bash
./run.sh tailnet create troller
```

![image](https://github.com/user-attachments/assets/c4ac0dcc-f004-4341-984f-1608b5387fb6)

Once we have created the tailnet, we will now create auth key mapping into that tailnet

> ./run.sh auth create \<name for machine\> \<name for tailnet\>

Ex:

```bash
./run.sh auth create warp-exit-node troller

./run.sh auth create nord-exit-node troller
```

![image](https://github.com/user-attachments/assets/940f353a-eabb-43bb-a58a-753b23c7e0e1)

Once you have auth, you can authenticate for 2 urls `https://ionscale.example.com/a/r/<string>`

To see the machines that have joined the tailnet:

> ./run.sh auth list \<name for tailnet\>

Ex:

```bash
./run.sh auth list troller
```

![image](https://github.com/user-attachments/assets/5428d253-4f07-4b12-884c-ca02b4163a75)

Now need to enable exit-node for 2 machines: warp, nordvpn

> ./run.sh enable_exit_node \<ID of machines\>

Ex:

```bash
./run.sh enable_exit_node 117216020300564994
./run.sh enable_exit_node 117216000016910850
```

![image](https://github.com/user-attachments/assets/444c110c-d582-4bbe-a605-3c2fd1e8ac72)

Finally, you need to enable nordvpn

```bash
chmod +x nord.sh
./nord.sh login
```

Here i have configured Nordvpn's manual login, without 2FA to create API Token on the dashboard

![image](https://github.com/user-attachments/assets/039c6903-ac00-4113-a8b5-c2e1d9f7f8ba)

Visit the url and login your Nordvpn account there

![image](https://github.com/user-attachments/assets/0d142573-3b78-4508-b6e8-002355500a51)

You copy the callback link that Nordvpn returns containing the exchange token for you

```bash
./nordvpn login --callback "nordvpn://login?action=login&exchange_token="
```

![image](https://github.com/user-attachments/assets/ee6a3d93-ad6b-4816-ac0a-4cf25624acd0)

Connect vpn:

```bash
./nord.sh connect Vietnam
```

Now you can use your personal computer and join these tailnet networks

### Guide:

- Windows: https://github.com/juanfont/headscale/blob/main/docs/windows-client.md
- Linux: `tailscale up --accept-dns=true --accept-routes=true --login-server=https://ionscale.example.com`

### Credit

https://support.nordvpn.com/hc/en-us/articles/20465811527057-How-to-build-the-NordVPN-Docker-image

https://jsiebens.github.io/ionscale/

https://github.com/cmj2002/warp-docker
