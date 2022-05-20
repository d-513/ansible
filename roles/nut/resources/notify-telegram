#!/bin/bash

# Telegram notify script

if [[ -z $1 ]]; then
  echo "usage: notify <message>"
  exit 1
fi

curl -X POST \
   -H 'Content-Type: application/json' \
   -d '{"chat_id": "'$TELEGRAM_CHATID'", "text": "'$0'", "disable_notification": true}' \
   https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage
