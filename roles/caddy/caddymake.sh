#!/bin/bash
cat Caddyfile | sed -e "s/dns.dns/{{ main_domain}}/" > templates/Caddyfile.j2
