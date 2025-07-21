
#Script to make the bot send private messages. can send simple embed messages with text and description. will be able to send embed messages with images soon.


TOKEN="YOUR_BOT_TOKEN_HERE"  # Replace this with your bot token securely.

# Ask for the Discord User ID
echo -n "Enter the user ID to send a warning or private message: "
read USER_ID

# Ask for the message
echo -n "Enter the warning message (use /embed to send an embed with options): "
read -r WARN_MESSAGE_RAW

# Create a DM channel with the user
DM_CHANNEL_JSON=$(curl -s -X POST "https://discord.com/api/v10/users/@me/channels" \
  -H "Authorization: Bot $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"recipient_id\":\"$USER_ID\"}")

DM_CHANNEL_ID=$(echo "$DM_CHANNEL_JSON" | jq -r '.id')

# Check if DM channel was created successfully
if [[ "$DM_CHANNEL_ID" == "null" || -z "$DM_CHANNEL_ID" ]]; then
  echo "Error creating DM or invalid user."
  exit 1
fi

# Function to extract parameters like --title or --description
extract_param() {
  local param="$1"
  echo "$WARN_MESSAGE_RAW" | grep -oP "(?<=${param} \")[^\"]*"
}

# Handle embed message if /embed command is used
if [[ "$WARN_MESSAGE_RAW" == /embed* ]]; then
  # Extract title and description from input
  TITLE=$(extract_param --title)
  DESCRIPTION=$(extract_param --description)

  # If description is empty, use the remainder of the message
  if [[ -z "$DESCRIPTION" ]]; then
    DESCRIPTION=$(echo "$WARN_MESSAGE_RAW" | sed -E 's|^/embed||' | sed -E 's|--title "[^"]*"||g' | sed -E 's|--description "[^"]*"||g' | xargs)
  fi

  # Create embed JSON
  JSON_PAYLOAD=$(jq -n \
    --arg title "$TITLE" \
    --arg description "$DESCRIPTION" \
    '{embeds: [{title: $title, description: $description, color: 65280}]}')

  # Send embed message
  curl -s -X POST "https://discord.com/api/v10/channels/$DM_CHANNEL_ID/messages" \
    -H "Authorization: Bot $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$JSON_PAYLOAD"

else
  # Send plain text message
  curl -s -X POST "https://discord.com/api/v10/channels/$DM_CHANNEL_ID/messages" \
    -H "Authorization: Bot $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"content\":\"$WARN_MESSAGE_RAW\"}"
fi

echo "Message sent to user $USER_ID!"
