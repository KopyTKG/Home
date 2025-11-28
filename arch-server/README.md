# Arch linux server setup

## Services

1. **\*arr stack**
   - `sonarr`: TV show downloader and manager
   - `radarr`: Movie downloader and manager
   - `prowlarr`: Indexer manager for arr stack
   - `nox`: Qbittorrent nox client
2. **Monitoring**
   - `uptime-kuma`: self-hosted monitoring tool
3. **Zerotier hosting**
   - `FoundryTT`: self-hosted virtual tabletop for playing RPGs online
   - `Palworlds server`: self-hosted server for the game Palworlds (Currently down)
4. **Infrastructure** (will be used with OPNsense Unbound DNS resolver)
   - `nginx`: as reverse proxy
   - `certbot`: for ssl certificates
   - `certbot-dns-cloudflare`: for cloudflare dns challenge

<details>
<summary><h2>\*arr stack</h2></summary>

> [!NOTE]
> Because the server is running Arch linux, i've decided to go the AUR route for installing the \*arr stack. I used `yay` as aur helper.

### Prowlarr

[link](https://prowlarr.com/)

|----- | -------- |
| Port | Protocol |
| 9696 | HTTP |

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
| 7878 | HTTP |

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
| 8989 | HTTP |

Install `sonarr` from AUR using `yay`:

```bash
yay -S sonarr
```

Start and enable the service:

```bash
sudo systemctl enable --now sonarr
```

</details>
