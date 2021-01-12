require 'discordrb'
require 'dotenv/load'
require 'faraday'

BASE_URL = 'https://pro-api.coinmarketcap.com/v1/tools/price-conversion'.freeze

bot = Discordrb::Commands::CommandBot.new token: ENV['BOT_TOKEN'], prefix: '!'

bot.command :btc do |event|
  params = { symbol: 'BTC', amount: 1 }

  response = Faraday.get(BASE_URL, params, { 'X-CMC_PRO_API_KEY' => ENV['COINMARKET_API_KEY']})

  return unless response.success?

  response_body = JSON.parse(response.body, symbolize_names: true)

  data = response_body[:data][:quote][:USD]
  price = data[:price]
  last_updated = data[:last_updated]

  event << "Current BTC price is: #{price} USD"
  event << "Last updated at: #{DateTime.parse(last_updated).strftime('%Y %B %d, %H:%M UTC')}"
end

bot.run