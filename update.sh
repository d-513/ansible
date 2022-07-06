#!/bin/bash
ssh root@archserver.home 'podman auto-update'

ansible-playbook server.yml -e rcr=ye
