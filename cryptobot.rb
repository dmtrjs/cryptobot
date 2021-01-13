require 'discordrb'
require 'dotenv/load'
require 'faraday'
require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

BASE_URL = 'https://pro-api.coinmarketcap.com/v1/tools/price-conversion'.freeze

def send_embed_to_channel(channel, symbol)
  return if channel.nil? || symbol.nil?

  params = { symbol: symbol, amount: 1 }

  response = Faraday.get(BASE_URL, params, { 'X-CMC_PRO_API_KEY' => ENV['COINMARKET_API_KEY']})

  return unless response.success?

  response_body = JSON.parse(response.body, symbolize_names: true)

  channel.send_embed do |embed|
    data = response_body[:data][:quote][:USD]
    price = data[:price]
    last_updated = data[:last_updated]

    embed.colour = '#0099ff'
    embed.title = "#{symbol.upcase} Price"
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