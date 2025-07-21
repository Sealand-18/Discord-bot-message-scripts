#!/bin/bash

# === Discord Terminal Bot ===
# Description: Sends messages to a selected Discord channel or lists recent messages.

# Insert your bot token and server ID below:
TOKEN=""
GUILD_ID=""

while true; do
  # Get the server's channels
  channels_json=$(curl -s -H "Authorization: Bot $TOKEN" \
    "https://discord.com/api/v10/guilds/$GUILD_ID/channels")

  if [[ -z "$channels_json" ]]; then
    echo "Error retrieving channels. Check your TOKEN and GUILD_ID."
    exit 1
  fi

  # Extract name and ID using jq
  mapfile -t channels < <(echo "$channels_json" | jq -r '.[] | "\(.name) |\(.id)"')

  echo -e "\nAvailable channels:"
  for i in "${!channels[@]}"; do
    echo "$((i+1))) ${channels[$i]}"
  done

  echo -n "Enter the number of the channel to send a message: "
  read choice

  if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 )) || (( choice > ${#channels[@]} )); then
    echo "Invalid selection."
    continue
  fi

  channel_info=${channels[$((choice-1))]}
  channel_id=$(echo "$channel_info" | cut -d'|' -f2 | tr -d ' ')

  echo -n "Type the message to send (use /list to view messages): "
  read MESSAGE

  if [[ "$MESSAGE" == "/list" ]]; then
    echo -n "How many messages do you want to retrieve? "
    read LIMIT

    if ! [[ "$LIMIT" =~ ^[0-9]+$ ]] || (( LIMIT < 1 )); then
      echo "Invalid number."
      continue
    fi

    messages_json=$(curl -s -H "Authorization: Bot $TOKEN" \
      "https://discord.com/api/v10/channels/$channel_id/messages?limit=$LIMIT")

    echo -e "\nLast $LIMIT messages from channel ${channel_info%%|*}:"

    # Iterate through messages in chronological order (reverse the JSON list)
    echo "$messages_json" | jq -r 'reverse[] | "\(.author.username): \(.content)"'

    echo
    continue
  fi

  # If not /list, send the message
  response=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bot $TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "{\"content\":\"$MESSAGE\"}" \
    "https://discord.com/api/v10/channels/$channel_id/messages")

  if [[ "$response" == "200" || "$response" == "201" ]]; then
    echo "Message sent successfully!"
  else
    echo "Failed to send message. HTTP status code: $response"
  fi

  # Exit loop after sending
  break
done