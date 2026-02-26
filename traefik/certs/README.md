# traefik/certs

This directory is the designated location for TLS certificates used by Traefik's file provider. Place here your self-signed or locally-generated certificates for **LAN domains** that cannot use the Cloudflare ACME resolver (e.g. `*.lan` domains).

Certificate files (`.crt`, `.key`, `.toml`) are intentionally excluded from version control.

## How it works

Traefik watches this directory (`--providers.file.directory`) and loads any `.toml` file it finds. Each `.toml` points to a certificate/key pair:

```toml
[tls]
  [[tls.certificates]]
    certFile = "/etc/traefik/certs/your.domain-fullchain.crt"
    keyFile  = "/etc/traefik/certs/your.domain.key"
```

## Generating certificates

Certificates can be generated using [Certgen](https://github.com/Mstaaravin/Certgen), a local PKI tool that produces a three-tier CA hierarchy (Root CA → Intermediate CA → Host cert).

```bash
bash certgen.sh -d yourdomain.lan -n '*'
```

This generates the following files under `domains/yourdomain.lan/certs/`:

| File | Description |
|---|---|
| `*.key` | Private key |
| `*.crt` | Host certificate |
| `*-fullchain.crt` | Full chain (host + intermediate + root) |
| `*.toml` | Ready-to-use Traefik config |

Copy the `.crt`, `.key` and `.toml` files into this directory. Traefik picks them up automatically without restart.

> For the certificates to be trusted by browsers, install the Root CA on your local machines using the deploy scripts included in Certgen.
