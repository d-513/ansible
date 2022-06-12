#!/bin/bash
ssh root@arch.d513.space 'podman auto-update'

ansible-playbook server.yml -e rcr=ye
