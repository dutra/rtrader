require 'active_support'
require 'btce'
require './trader'

ticker = Btce::Ticker.new "btc_usd"

puts ticker.inspect

trader = Trader.new

trap("INT") do
  trader.print_orders
  exit
end


info = Btce::TradeAPI.new_from_keyfile.trade

FEE_MARGIN = 0.002
PROFIT_MARGIN = 0.002
PAIR = "btc_usd"
AMOUNT = 0.1
SLEEP_DURATION = 5 # Amount of time to wait before pinging server again
state = 'buy'

while true do # ping btce forever
  sleep SLEEP_DURATION # added this to prevent nonce increment errors (pinging server too fast)

  if trader.check_selling or trader.check_buying
    next
  end
    
  # go through all current orders and see if this pair has a trade placed yet

  ticker = Btce::Ticker.new PAIR
  sleep 1
  p ticker
  
  # buy currency @ buy price
  buy_base = ticker.sell - ticker.sell * (PROFIT_MARGIN+FEE_MARGIN)
  sell_base = ticker.buy + ticker.buy * (PROFIT_MARGIN+FEE_MARGIN)
  # buy_base = BASE_PRICE - (AMOUNT * BASE_PRICE * (PROFIT_MARGIN+FEE_MARGIN))
  # sell_base = BASE_PRICE + (AMOUNT * BASE_PRICE * (PROFIT_MARGIN+FEE_MARGIN))

  puts "Buy Price is #{buy_base}. Ticker price is #{ticker.buy}. Difference #{buy_base - ticker.buy}."
  puts "Sell Price is #{sell_base}. Ticker price is #{ticker.sell}. Difference #{ticker.sell - sell_base}."

  trader.buy AMOUNT, buy_base
  trader.sell AMOUNT, sell_base
end
