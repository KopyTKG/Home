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

|----- | -------- |
| Port | Protocol |
| 9696 | TCP |

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

|----- | -------- |
| Port | Protocol |
| 7878 | TCP |

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

|----- | -------- |
| Port | Protocol |
| 8989 | TCP |

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

|----- | -------- |
| Port | Protocol |
| 8080 | TCP |

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

|----- | -------- |
| Port | Protocol |
| 8191 | TCP |
| 8192 | TCP |

_Installation is done via podman container:_

Create `compose.yaml` file:

```bash
tee ~/compose.yaml >> /dev/null <<EOF
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
sudo podman-compose -f ~/compose.yaml up -d
```

</details>
