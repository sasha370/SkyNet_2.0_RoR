This is a simple Telegram bot, the idea of which I spied on in one of the chats.
The bot can respond to text or voice messages.
For this, Wisper speech recognition technologies and ChatGPT capabilities are used.

### Technologies
1) Simple RoR app that runs Bot in a separate Thread as it listens a channel in a loop.
2) CI ( RSpec + Rubocop)
3) CD to VPS server with docker-compose
4) Whisper for voice transcribation ( ffmpeg for converting OGG to MP3)


### How to run
1. create `.env` file from `.env.example`
2. rails server
3. Visit your Bot and start chatting


