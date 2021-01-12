# cryptobot
A discord bot for getting current crypto prices

## Setup

1. Clone this repo
2. `cd cryptobot`
3. Run `bundle install`
4. Add `COINMARKET_API_KEY` to your `.env` file. API key can be generated here: https://pro.coinmarketcap.com/signup/?plan=0
5. Add `BOT_TOKEN` to your `.env` file. In order to do that, you need to create an application (https://discord.com/developers/applications), build a bot and copy your Bot token.
6. Generate an invite link (https://discordapi.com/permissions.html#2048), follow the link and specify the server in which the bot should be added.

## Run

1. Run `bundle exec ruby cryptobot.rb`
2. Voila! Your bot should be up and running.

## Usage

Send any [supported command](#supported-commands) in your discord server and you should receive an embedded response back (e.g., try `!btc`)

## Supported commands

`!btc` - get current BTC price in USD.
