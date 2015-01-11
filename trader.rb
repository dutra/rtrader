require 'active_support'
require 'btce'


class Trader

  def initialize
    @orders = []
  end

  def confirm_last
    if @orders[-1] then
      @orders[-1][:confirmed] = true
    end
  end
  
  def buy(amount, rate)
    sleep 1
    puts "Buying bitcoin for #{rate}"
    buy_json = {"pair" => "btc_usd", "type" => "buy", "rate" => rate.round(3).to_s, "amount" => amount.to_s}
    p Btce::TradeAPI.new_from_keyfile.trade buy_json
    @orders.push({ amount: (-1)*amount, rate: rate, confirmed: false })
  end
  
  def sell(amount, rate)
    sleep 1
    puts "Selling bitcoin for #{rate}"
    sell_json = {"pair" => "btc_usd", "type" => "sell", "rate" => rate.round(3).to_s, "amount" => amount.to_s}
    p Btce::TradeAPI.new_from_keyfile.trade sell_json
    @orders.push({ amount: amount, rate: rate, confirmed: false})    
  end

  def check_selling
    sleep 1
    order_list = Btce::TradeAPI.new_from_keyfile.order_list
    p order_list
    if order_list["success"] == 1 then
      for id in order_list["return"]
        if id[1]["type"] == "sell"
          return true
        end
      end
    end
    return false
  end

  def check_buying
    sleep 1
    order_list = Btce::TradeAPI.new_from_keyfile.order_list
    p order_list
    if order_list["success"] == 1 then
      for id in order_list["return"]
        if id[1]["type"] == "buy"
          return true
        end
      end
    end
    return false
  end

  def print_orders
    total = 0
    profit = 0
    fee = 0
    @orders.each do |order|
      fee += (order[:amount]*order[:rate]).abs*0.002
      total += (order[:amount]*order[:rate]).abs
      profit += order[:amount]*order[:rate]
    end
    puts "Profit: #{profit-fee}"
    puts "Fee: #{fee}"
  end
  

end

