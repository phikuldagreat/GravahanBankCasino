local Deck = require("models.deck")

local Blackjack = {}

local function handValue(hand)
  local total, aces = 0, 0
  for _, card in ipairs(hand) do
    local rank = card:sub(1, -2)
    if rank == "A" then
      total = total + 11; aces = aces + 1
    elseif rank == "J" or rank == "Q" or rank == "K" then
      total = total + 10
    else
      total = total + tonumber(rank)
    end
  end
  while total > 21 and aces > 0 do
    total = total - 10; aces = aces - 1
  end
  return total
end

-- returns payout (total returned to the player) and a message
function Blackjack.play(bet)
  local deck = Deck.new()
  local player = { deck:draw(), deck:draw() }
  local dealer = { deck:draw(), deck:draw() }
  print("Dealer shows: " .. dealer[1] .. " ??\n")

  while handValue(player) < 21 do
    print("Your hand: " .. table.concat(player, " ") .. " (" .. handValue(player) .. ")")
    io.write("[h]it or [s]tand? ")
    local choice = io.read()
    print()
    if choice == "h" then player[#player + 1] = deck:draw() else break end
  end

  local pv = handValue(player)
  print("Your final hand: " .. table.concat(player, " ") .. " (" .. pv .. ")")
  if pv > 21 then return 0, "Bust! You lose PHP " .. bet end

  repeat
    if handValue(dealer) < 17 then dealer[#dealer + 1] = deck:draw() end
  until handValue(dealer) >= 17
  local dv = handValue(dealer)
  print("Dealer hand: " .. table.concat(dealer, " ") .. " (" .. dv .. ")\n")

  if pv == 21 and #player == 2 and dv ~= 21 then
    return math.floor(bet * 2.5), "Blackjack! You win PHP " .. math.floor(bet * 1.5)
  elseif dv > 21 or pv > dv then
    return bet * 2, "You win PHP " .. bet
  elseif pv == dv then
    return bet, "Push. Bet returned."
  else
    return 0, "Dealer wins. You lose PHP " .. bet
  end
end

return Blackjack