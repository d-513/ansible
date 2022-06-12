#!/bin/bash
pushd ~/Projects/ansible-scripts/roles/caddy
cat Caddyfile | sed -e "s/dns.dns/{{ main_domain}}/" > templates/Caddyfile.j2
popd
