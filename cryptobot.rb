require 'discordrb'
require 'dotenv/load'
require 'faraday'

BASE_URL = 'https://pro-api.coinmarketcap.com/v1/tools/price-conversion'.freeze

bot = Discordrb::Commands::CommandBot.new token: ENV['BOT_TOKEN'], prefix: '!'

puts "Invite url: #{bot.invite_url}"

bot.command :btc do |event|
  params = { symbol: 'BTC', amount: 1 }

  response = Faraday.get(BASE_URL, params, { 'X-CMC_PRO_API_KEY' => ENV['COINMARKET_API_KEY']})

  return unless response.success?

  response_body = JSON.parse(response.body, symbolize_names: true)

  data = response_body[:data][:quote][:USD]
  price = data[:price]
  last_updated = data[:last_updated]

  event.channel.send_embed('BTC price') do |embed|
    embed.colour = '#0099ff'
    embed.title = 'BTC Price'
    embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'Crypto Bot',
                                                        icon_url: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/BTC_Logo.svg/1200px-BTC_Logo.svg.png')
    embed.add_field(name: 'Price',  value: "#{price.round(2)} USD")
    embed.add_field(name: 'Last updated at', value: DateTime.parse(last_updated).strftime('%Y %B %d, %H:%M UTC'))
  end
end

bot.run