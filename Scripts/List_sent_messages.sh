#!/bin/bash

# === Discord DM Message Lister ===
# Description: Opens a DM with a specific user and lists recent messages in a readable format.

# Replace this with your bot token
TOKEN="YOUR_BOT_TOKEN_HERE"

# Prompt for the user ID to open a DM with
echo -n "Enter the user ID: "
read USER_ID

# Prompt for how many messages to retrieve
echo -n "How many messages to list? "
read LIMIT

# Step 1: Open (or fetch) a DM channel with the given user
CHANNEL_ID=$(curl -s -X POST -H "Authorization: Bot $TOKEN" -H "Content-Type: application/json" \
  -d "{\"recipient_id\":\"$USER_ID\"}" \
  https://discord.com/api/v10/users/@me/channels | jq -r '.id')

if [ -z "$CHANNEL_ID" ]; then
  echo "Failed to get the DM channel."
  exit 1
fi

# Step 2: Get the bot's user ID to identify its own messages
BOT_ID=$(curl -s -H "Authorization: Bot $TOKEN" https://discord.com/api/v10/users/@me | jq -r '.id')

# Step 3: Fetch recent messages from the DM channel
MESSAGES_JSON=$(curl -s -H "Authorization: Bot $TOKEN" \
  "https://discord.com/api/v10/channels/$CHANNEL_ID/messages?limit=$LIMIT")

if [ -z "$MESSAGES_JSON" ]; then
  echo "Failed to fetch messages."
  exit 1
fi

# Step 4: Display messages in a readable format
echo
echo "Listing the last $LIMIT messages in DM with user $USER_ID:"
echo

echo "$MESSAGES_JSON" | jq -r --arg BOT_ID "$BOT_ID" '
  reverse | .[] |
  if .author.id == $BOT_ID then
    "You: \(.content)"
  else
    "\(.author.username): \(.content)"
  end
'
