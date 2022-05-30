# Podman Containers deploy role for:

- Caddy
- Pi-Hole
- Vaultwarden
- Cloudflare DDNS
- LLDAP
- Mariadb
- Nextcloud
- Authelia

All web-based services require caddy.
Playbook is structured like this:  
vars to deploy are `servicename_deploy` as boolean. For example `caddy_deploy: true`

Authelia requires LLDAP and caddy
Vaultwarden requires caddy
Nextcloud requires caddy, LLDAP and mariadb
