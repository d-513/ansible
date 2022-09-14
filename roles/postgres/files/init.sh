#!/bin/bash
set -e

createdb --encoding=UTF8 --owner=postgres --template=template0 nextcloud
createdb --encoding=UTF8 --owner=postgres --template=template0 authelia
createdb --encoding=UTF8 --owner=postgres --template=template0 hedgedoc
createdb --encoding=UTF8 --owner=postgres --template=template0 synapse
createdb --encoding=UTF8 --owner=postgres --template=template0 mautrix-whatsapp
createdb --encoding=UTF8 --owner=postgres --template=template0 mautrix-discord
createdb --encoding=UTF8 --owner=postgres --template=template0 mautrix-facebook
