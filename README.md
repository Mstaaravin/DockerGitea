# Docker Gitea

Self-hosted [Gitea](https://gitea.com) instance with [Traefik](https://traefik.io) as a reverse proxy, automatic TLS via Cloudflare DNS challenge, and MariaDB as the database backend.

## Stack

| Service | Image | Description |
|---|---|---|
| `traefik` | `traefik:v3` | Reverse proxy, handles HTTPS and certificate management |
| `gitea` | `gitea/gitea` | Git service |
| `gitea_db` | `linuxserver/mariadb` | Database backend |
| `zabbix-agent` | `zabbix/zabbix-agent2` | **Example only** — remove or adapt to your monitoring setup |

## Requirements

- Docker with the Compose plugin
- A domain managed by Cloudflare
- A Cloudflare API token with `Zone:DNS:Edit` permissions

## Setup

**1. Clone the repo**

```bash
git clone <repo-url>
cd <repo-dir>
```

**2. Configure environment**

```bash
cp .env.example .env
```

Edit `.env` and fill in your values:

| Variable | Description |
|---|---|
| `GITEA_DOMAIN` | Public domain for Gitea (e.g. `gitea.example.com`) |
| `TRAEFIK_DOMAIN` | Domain for the Traefik dashboard (e.g. `traefik.example.com`) |
| `CLOUDFLARE_EMAIL` | Cloudflare account email |
| `CLOUDFLARE_DNS_API_TOKEN` | Cloudflare API token for DNS challenge |
| `MYSQL_ROOT_PASSWORD` | MariaDB root password |
| `MYSQL_PASSWORD` | MariaDB password for the Gitea user |
| `GITEA__database__PASSWD` | Must match `MYSQL_PASSWORD` |
| `USER_UID` / `USER_GID` | UID/GID of the user running Docker on the host |

**3. Traefik dashboard IP whitelist**

The dashboard is restricted by IP. Edit the middleware in `compose.yml` to match your network:

```yaml
- "traefik.http.middlewares.dashboard-ipwhitelist.ipwhitelist.sourcerange=192.168.1.0/24"
```

**4. Start**

```bash
docker compose up -d
```

Traefik will automatically request a TLS certificate on first boot. Gitea's initial setup wizard will be available at `https://<GITEA_DOMAIN>` once the DNS A record is properly configured.

## Directory structure

```
.
├── compose.yml
├── .env               # Local config, never committed
├── .env.example       # Template
├── gitea/             # Gitea persistent data
├── gitea_db/          # MariaDB persistent data
└── traefik/
    ├── acme.json      # TLS certificates (auto-created, chmod 600)
    └── certs/         # Optional local certificates
```

## Backup

Database backups can be automated using [backup-db.sh](https://github.com/Mstaaravin/HomelabScripts/blob/main/scripts/backup-db.md) from [HomelabScripts](https://github.com/Mstaaravin/HomelabScripts). It reads credentials directly from the container's environment variables — no extra configuration needed.

A ready-to-use config file is included at `gitea_db/backup.conf`. Example cron entry:

```bash
0 3 * * * /usr/local/bin/backup-db.sh /path/to/gitea_db/backup.conf
```

## Notes

- `traefik/acme.json` is created automatically on first run with the correct permissions.
- The `zabbix-agent` service is included as a reference example for monitoring integration. Adjust `ZBX_SERVER_HOST`,`ZBX_HOSTNAME` and `ZBX_STARTAGENTS` to match your Zabbix setup, or remove it if not needed.
- Extra supported variables for zabbix-agent can be added from [https://hub.docker.com/r/zabbix/zabbix-agent2#other-variables](https://hub.docker.com/r/zabbix/zabbix-agent2#other-variables)

