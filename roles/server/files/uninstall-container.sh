#!/bin/bash

echo Container Uninstaller

cont=$1

if [[ -z $1 ]]; then
  echo "No container provided! uninstall-container <name>"
fi

systemctl stop container-$1.service
podman rm $1
rm /etc/systemd/system/container-$1.service
