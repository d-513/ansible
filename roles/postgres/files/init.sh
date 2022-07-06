#!/bin/bash
set -e

createdb --encoding=UTF8 --owner=postgres --template=template0 nextcloud
createdb --encoding=UTF8 --owner=postgres --template=template0 keycloak
