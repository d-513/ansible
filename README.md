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

### `roles/custom`

Custom services that aren't meant to be operated by most selfhosted users. These are discord bots for my servers, custom websites, etc  
These will have minimal docs and support
