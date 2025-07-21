#!/bin/bash

# === Discord Terminal Bot ===
# Sends messages or embed content to a channel in your Discord server
#insert Bot token and Guild ID (Server ID) below.
TOKEN=""
GUILD_ID=""

while true; do
  # Fetch server channels
  channels_json=$(curl -s -H "Authorization: Bot $TOKEN" \
    "https://discord.com/api/v10/guilds/$GUILD_ID/channels")

  if [[ -z "$channels_json" ]]; then
    echo "Error: Failed to fetch channels. Check your TOKEN and GUILD_ID."
    exit 1
  fi

  # Extract channel names and IDs
  mapfile -t channels < <(echo "$channels_json" | jq -r '.[] | "\(.name) |\(.id)"')

  echo -e "\nAvailable channels:"
  for i in "${!channels[@]}"; do
    echo "$((i+1))) ${channels[$i]}"
  done

  echo -n "Select a channel by number: "
  read choice

  if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 )) || (( choice > ${#channels[@]} )); then
    echo "Invalid choice."
    continue
  fi

  channel_info=${channels[$((choice-1))]}
  channel_id=$(echo "$channel_info" | cut -d'|' -f2 | tr -d ' ')

  echo -n "Type your message (/list to read messages, /embed to send embed): "
  read MESSAGE

  if [[ "$MESSAGE" == "/list" ]]; then
    echo -n "How many messages to retrieve? "
    read LIMIT

    if ! [[ "$LIMIT" =~ ^[0-9]+$ ]] || (( LIMIT < 1 )); then
      echo "Invalid number."
      continue
    fi

    messages_json=$(curl -s -H "Authorization: Bot $TOKEN" \
      "https://discord.com/api/v10/channels/$channel_id/messages?limit=$LIMIT")

    echo -e "\nLast $LIMIT messages from channel ${channel_info%%|*}:"
    echo "$messages_json" | jq -r 'reverse[] | "\(.author.username): \(.content)"'
    echo
    continue
  fi

  if [[ "$MESSAGE" == "/embed" ]]; then
    # Embed creation flow
    echo -n "Enter embed title (--title): "
    read EMBED_TITLE
    echo -n "Enter embed description (--description): "
    read EMBED_DESCRIPTION
    echo -n "Enter image URL (optional --image): "
    read EMBED_IMAGE

    if [[ -n "$EMBED_IMAGE" ]]; then
      EMBED_JSON=$(jq -n \
        --arg title "$EMBED_TITLE" \
        --arg description "$EMBED_DESCRIPTION" \
        --arg image "$EMBED_IMAGE" \
        '{
          embeds: [{
            title: $title,
            description: $description,
            image: { url: $image }
          }]
        }')
    else
      EMBED_JSON=$(jq -n \
        --arg title "$EMBED_TITLE" \
        --arg description "$EMBED_DESCRIPTION" \
        '{
          embeds: [{
            title: $title,
            description: $description
          }]
        }')
    fi

    response=$(curl -s -o /dev/null -w "%{http_code}" \
      -H "Authorization: Bot $TOKEN" \
      -H "Content-Type: application/json" \
      -X POST \
      -d "$EMBED_JSON" \
      "https://discord.com/api/v10/channels/$channel_id/messages")

    if [[ "$response" == "200" || "$response" == "201" ]]; then
      echo "Embed sent successfully!"
    else
      echo "Failed to send embed. HTTP status code: $response"
    fi
    continue
  fi

  # Send a regular message
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

  break
done
