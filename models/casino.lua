local Transaction = require("services.transaction")
local Blackjack   = require("games.blackjack")

local Casino = {}
Casino.__index = Casino

function Casino.new(wallet)
  return setmetatable({ wallet = wallet }, Casino)
end

function Casino:playBlackjack(bet)
  return Transaction.run({ self.wallet }, function()
    self.wallet:withdraw(bet)
    local payout, msg = Blackjack.play(bet)
    if payout > 0 then self.wallet:deposit(payout) end
    print(msg)
  end)
end

return Casino