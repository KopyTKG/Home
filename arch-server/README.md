# Arch linux server setup

> [!IMPORTANT]
> My server is running Arch linux, with hardened kernel, BTRFS as filesystem and podman as container runtime.
> This setup is done on a headless server, so everything is done via ssh.
> By default hardened kernel does not support bridge networking, so all my containers are running on host network behind OPNsense firewall.

## Pre-requisites

- Arch linux installed on server
- SSH access to server
- Basic knowledge of linux command line

### Tools / Software used

- `ssh`: for remote access
- `yay`: AUR helper for installing packages from AUR
- `podman`: container runtime

#### Yay installation

```bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
```

#### Podman installation

```bash
sudo pacman -S podman podman-compose
```

enable podman socket

```bash
sudo systemctl enable --now podman.socket
sudo systemctl enable --now podman-restart.service
```

## Services

1. **\*arr stack**
   - `sonarr`: TV show downloader and manager
   - `radarr`: Movie downloader and manager
   - `prowlarr`: Indexer manager for arr stack
   - `nox`: Qbittorrent nox client
   - `flaresolverr`: Cloudflare challenge solver for arr stack
2. **Monitoring**
   - `uptime-kuma`: self-hosted monitoring tool
3. **Zerotier hosting**
   - `FoundryTT`: self-hosted virtual tabletop for playing RPGs online
   - `Palworlds server`: self-hosted server for the game Palworlds (Currently down)
4. **Infrastructure** (will be used with OPNsense Unbound DNS resolver)
   - `nginx`: as reverse proxy
   - `certbot`: for ssl certificates
   - `certbot-dns-cloudflare`: for cloudflare dns challenge

> [!NOTE]
> Because the server is running Arch linux, i've decided to go the AUR route for installing the \*arr stack. I used `yay` as aur helper.

<details>
<summary><h2>*arr stack</h2></summary>

### Prowlarr

[link](https://prowlarr.com/)

<table>
    <thead>
        <tr>
            <th>Port</th>
            <th>Protocol</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>9696</td>
            <td>TCP</td>
        </tr>
    </tbody>
</table>

Install `prowlarr` from AUR using `yay`:

```bash
yay -S prowlarr
```

Start and enable the service:

```bash
sudo systemctl enable --now prowlarr
```

### Radarr

[link](https://radarr.video/)

<table>
    <thead>
        <tr>
            <th>Port</th>
            <th>Protocol</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>7878</td>
            <td>TCP</td>
        </tr>
    </tbody>
</table>

Install `radarr` from AUR using `yay`:

```bash
yay -S radarr
```

Start and enable the service:

```bash
sudo systemctl enable --now radarr
```

### Sonarr

[link](https://sonarr.tv/)

<table>
    <thead>
        <tr>
            <th>Port</th>
            <th>Protocol</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>8989</td>
            <td>TCP</td>
        </tr>
    </tbody>
</table>

Install `sonarr` from AUR using `yay`:

```bash
yay -S sonarr
```

Start and enable the service:

```bash
sudo systemctl enable --now sonarr
```

### Nox

[link](https://github.com/userdocs/qbittorrent-nox-static)

<table>
    <thead>
        <tr>
            <th>Port</th>
            <th>Protocol</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>8080</td>
            <td>TCP</td>
        </tr>
    </tbody>
</table>

Install `nox` from AUR using `yay`:

```bash
yay -S qbittorrent-nox # extra/qbittorrent-nox
```

Start and enable the service:

```bash
sudo systemctl enable --now qbittorrent-nox
```

### Flaresolverr

[link](https://github.com/FlareSolverr/FlareSolverr)

 <table>
    <thead>
        <tr>
            <th>Port</th>
            <th>Protocol</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>8191</td>
            <td>TCP</td>
        </tr>
        <tr>
            <td>8192</td>
            <td>TCP</td>
        </tr>
    </tbody>

</table>

_Installation is done via podman container:_

Create `compose.yaml` file:

```bash
tee ~/compose-flare.yaml >> /dev/null <<EOF
services:
  flaresolverr:
    image: flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    restart: unless-stopped
    network_mode: "host"
    environment:
      - LOG_LEVEL=info
      - TZ=Europe/Prague
EOF
```

Start the container (depends on [Podman installation](#podman-installation)):

```bash
sudo podman-compose -f ~/compose-flare.yaml up -d
```

</details>

<details>
<summary><h2>Monitoring</h2></summary>

### Uptime Kuma

[link](https://uptime.kuma.pet/)

<table>
    <thead>
        <tr>
            <th>Port</th>
            <th>Protocol</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>3001</td>
            <td>TCP</td>
        </tr>
    </tbody>
</table>

_Installation is done via podman container:_

Create `compose.yaml` file:

```bash
tee ~/compose-uptimekuma.yaml >> /dev/null <<EOF
services:
  uptime-kuma:
    image: louislam/uptime-kuma:2
    container_name: uptime-kuma
    restart: unless-stopped
    network_mode: "host"
    volumes:
      - ./data:/app/data
    cap_add:
      - NET_RAW
EOF
```

Start the container (depends on [Podman installation](#podman-installation)):

```bash
sudo podman-compose -f ~/compose-uptimekuma.yaml up -d
```

</details>

<details>
<summary><h2>Zerotier hosting</h2></summary>

### TBD

</details>

<details>
<summary><h2>Infrastructure</h2></summary>

### Prerequisites

- Cloudflare account with domain added
- API token with DNS edit permissions

#### Nginx installation

```bash
sudo pacman -S nginx
```

Enable and start nginx service

```bash
sudo systemctl enable --now nginx
```

#### Certbot installation

```bash
sudo pacman -S certbot certbot-dns-cloudflare
```

### Cloudflare DNS challenge setup

Create Cloudflare API token file

```bash
mkdir -p ~/.secrets/certbot
```

Fill in the file with your API token

```bash
tee ~/.secrets/certbot/cloudflare.ini >> /dev/null <<EOF
dns_cloudflare_api_token = YOUR_API_TOKEN_HERE
EOF
```

Set proper permissions

```bash
chmod 600 ~/.secrets/certbot/cloudflare.ini
```

### Obtaining SSL certificates

Run certbot with cloudflare dns challenge

```bash
sudo certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini \
  -d 'yourdomain.com' \
  -d '*.yourdomain.com' \
  --agree-tos \
  --non-interactive
```

Replace `yourdomain.com` with your actual domain name.
This will obtain a wildcard SSL certificate for your domain.

### Nginx reverse proxy setup

Create NGING configuration folder

```bash
sudo mkdir -p /etc/nginx/conf.d
```

Edit the file `/etc/nginx/nginx.conf` to include the conf.d directory

```bash
# Add
include /etc/nginx/conf.d/*.conf;
# at the end of /etc/nginx/nginx.conf file inside http block
```

Add your subdomain configuration file (mine is `lab.conf` based on `*.lab.thekrew.app`)

```bash
sudo touch /etc/nginx/conf.d/lab.conf
```

Example for `lab.conf`:

```bash
# ---------------------------------------
# 1. GLOBAL SSL SETTINGS
# ---------------------------------------
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5;

# Point to your new certs here
ssl_certificate /etc/letsencrypt/live/lab.thekrew.app/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/lab.thekrew.app/privkey.pem;

# ---------------------------------------
# 2. HTTP -> HTTPS REDIRECT
# ---------------------------------------
server {
    listen 80;
    server_name *.lab.thekrew.app;
    return 301 https://$host$request_uri;
}

# ---------------------------------------
# 3. SERVICES (Repeat this block for each app)
# ---------------------------------------

# SONARR
server {
    listen 443 ssl;
    http2 on;
    server_name sonarr.lab.thekrew.app;

    location / {
        proxy_pass http://127.0.0.1:8989;

        # Standard Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

# RADARR
server {
    listen 443 ssl;
    http2 on;
    server_name radarr.lab.thekrew.app;

    location / {
        proxy_pass http://127.0.0.1:7878;

        # Standard Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

# PROWLARR
server {
    listen 443 ssl;
    http2 on;
    server_name prowlarr.lab.thekrew.app;

    location / {
        proxy_pass http://127.0.0.1:9696;

        # Standard Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

# NOX (QBITTORRENT)
server {
    listen 443 ssl;
    http2 on;
    server_name nox.lab.thekrew.app;

    location / {
        proxy_pass http://127.0.0.1:8080;

        # Standard Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

# UPTIME KUMA
server {
    listen 443 ssl;
    http2 on;
    server_name kuma.lab.thekrew.app;

    location / {
        proxy_pass http://127.0.0.1:3001;

        # Standard Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

# HOME ASSISANT
server {
    listen 443 ssl;
    http2 on;
    server_name ha.lab.thekrew.app;

    location / {
        proxy_pass http://10.25.0.11:8123;

        # Standard Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

# UNIFI
server {
    listen 443 ssl;
    http2 on;
    server_name ui.lab.thekrew.app;

    location / {
        proxy_pass https://10.25.0.2;

        # Standard Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

# PLEX
server {
    listen 443 ssl;
    http2 on;
    server_name plex.lab.thekrew.app;

    location / {
        proxy_pass https://10.25.0.21:32400;

        # Standard Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### Start nginx + certbot renewal service

Reload nginx to apply changes

```bash
sudo systemctl reload nginx
```

Start and enable certbot renewal service

```bash
sudo systemctl enable --now certbot-renew.timer
```
