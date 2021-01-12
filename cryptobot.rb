require 'discordrb'
require 'dotenv/load'

bot = Discordrb::Bot.new token: 

puts "This bot's invite URL is #{bot.invite_url}."

bot.message(content: 'Ping!') do |event|
  event.respond 'Pong!'
end

bot.run