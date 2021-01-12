require 'discordrb'
require 'dotenv/load'

bot = Discordrb::Commands::CommandBot.new token: ENV['BOT_TOKEN'], prefix: '!'

bot.command :me do |event|
    event.user.name
  end

bot.run