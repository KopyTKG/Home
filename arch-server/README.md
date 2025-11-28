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
