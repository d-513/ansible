# ansible-dada513

my ansible scripts for deploying serveral things

### `roles/server`

This is the main role for deploying FOSS well-known selfhosted applications.  
Features:

- Podman
- Systemd & Timers instead of cron
- Formatted meta
- Easy config for services
- Not hardcoded - setup flexible

Services:

- Caddy
- Pi-Hole
- Vaultwarden
- Cloudflare DDNS
- LLDAP
- Mariadb
- Nextcloud
- Authelia
- Postgres
