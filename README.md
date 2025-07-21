# Discord Bot with Terminal

A collection of Bash scripts to interact with the Discord API via terminal commands.  
Allows you to send messages, embeds, manage DMs, and list messages from channels or users directly from the command line.

---

## Features

- List available channels in a Discord server  
- Send normal and embedded messages to channels  
- Send private messages (DMs) with optional embed support  
- List recent messages from channels or DMs  
- Simple and lightweight, runs entirely in Bash  
- Uses Discord API v10 and `curl` for requests

---

## Requirements

- Bash shell (Linux, macOS, Windows with WSL or Git Bash)  
- `curl` command line HTTP client  
- `jq` for JSON parsing (https://stedolan.github.io/jq/)  
- Discord Bot token and Guild (server) ID

---

## Setup

1. Create a Discord Bot and get its token.  
2. Invite the bot to your Discord server with appropriate permissions.  
3. Edit the scripts and replace the placeholder values for:  
   - `TOKEN` with your bot's token  
   - `GUILD_ID` with your server's ID  
4. Make sure you have `curl` and `jq` installed on your system.

---

## Usage

Run the scripts from your terminal. The scripts will prompt you to:  

- Select the Discord channel  
- Input the message or command (`/lista` to list recent messages, `/embed` for embedded messages, etc.)  
- For DMs, input user ID and message content  

---

## Important Notes

- Keep your bot token secure! Do **not** share it publicly.  
- Follow Discord’s API rate limits to avoid being banned.  
- This project is open-source under the [MIT License](LICENSE).  
- See [Terms of Usage](TERMS_of_usage.md) for rules regarding usage and contributions.

---

## Contributing

Contributions and improvements are welcome! Feel free to open issues or submit pull requests.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact

For questions or support, open an issue on GitHub or contact the maintainer.

---

## Discussion

if you want to enter in the discussion or see more n
information, go to my [Reddit Post](https://www.reddit.com/r/termux/s/g9uWfkN0l5)
