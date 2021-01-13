require 'discordrb'
require 'dotenv/load'
require 'faraday'
require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

BASE_URL = 'https://api.nomics.com/v1'.freeze

def send_embed_to_channel(channel, symbol)
  return if channel.nil? || symbol.nil?

  symbol = symbol.upcase

  params = { ids: symbol, convert: 'USD', key: ENV['NOMICS_API_KEY'] }

  response = Faraday.get("#{BASE_URL}/currencies/ticker", params)

  return unless response.success?

  response_body = JSON.parse(response.body, symbolize_names: true)

  data = response_body.first

  channel.send_embed do |embed|
    price = data[:price]
    last_updated = data[:price_timestamp]

    embed.colour = '#0099ff'
    embed.title = "#{symbol} Price"
    embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'Crypto Bot',
                                                        icon_url: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/BTC_Logo.svg/1200px-BTC_Logo.svg.png')
    embed.add_field(name: 'Price',  value: "#{price.round(2)} USD")
    embed.add_field(name: 'Last updated at', value: DateTime.parse(last_updated).strftime('%Y %B %d, %H:%M UTC'))
  end
end

bot = Discordrb::Commands::CommandBot.new token: ENV['BOT_TOKEN'], prefix: '!'

puts "Invite url: #{bot.invite_url}"

bot.command :btc do |event|
  send_embed_to_channel(event.channel, 'btc')
end

bot.command :eth do |event|
  send_embed_to_channel(event.channel, 'eth')
end

bot.run :async

scheduler.every '27m' do
  puts "Running scheduler"

  channels = bot.find_channel('crypto-prices')

  if channels.any?
    channels.each do |channel|
      pp channel

      begin
        send_embed_to_channel(channel, 'btc')
        send_embed_to_channel(channel, 'eth')
      rescue Discordrb::Errors::NoPermission
        next
      end
    end
  end
end

bot.join