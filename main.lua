math.randomseed(os.time())

local Account     = require("models.account")
local Savings     = require("models.savings")
local Casino      = require("models.casino")
local Transaction = require("services.transaction")
local Storage     = require("services.storage")

-- Setup
local data   = Storage.load()
local wallet = Account.new("Wallet", data.wallet)
local bank   = Savings.new("Bank", data.bank, 0.05)
local casino = Casino.new(wallet)

local function ask(prompt)
  io.write(prompt)
  local value = tonumber(io.read())
  print()
  return value
end

local function report(ok, msg)
  print(msg)
  print()
  if ok then Storage.save(wallet, bank) end
end

local LINE = string.rep("-", 34)

local function section(title)
  print("\n" .. LINE)
  print(title)
  print(LINE)
end

-- dispatch table (Lua has no switch)
local actions = {
  ["1"] = function()
    section("BALANCES")
    print(wallet:describe())
    print(bank:describe())
    print()
  end,
  ["2"] = function()
    section("DEPOSIT TO BANK")
    report(Transaction.transfer(wallet, bank, ask("Amount: PHP ")))
  end,
  ["3"] = function()
    section("WITHDRAW FROM BANK")
    report(Transaction.transfer(bank, wallet, ask("Amount: PHP ")))
  end,
  ["4"] = function()
    section("BLACKJACK")
    report(casino:playBlackjack(ask("Bet: PHP ")))
  end,
  ["5"] = function()
    section("INTEREST")
    local earned = 0
    local ok, msg = Transaction.run({ bank }, function()
      earned = bank:addInterest()
    end)
    if ok then msg = msg .. " (interest earned: PHP " .. earned .. ")" end
    report(ok, msg)
  end,
  ["6"] = function()
    section("HISTORY")
    for _, acc in ipairs({ wallet, bank }) do
      print("-- " .. acc.owner .. " --")
      if #acc.history == 0 then print("(no transactions)") end
      for i, h in ipairs(acc.history) do print(i, h) end
      print()
    end
  end,
}

-- Menu loop
local running = true
repeat
  print("\n" .. string.rep("=", 34))
  print("   GRAVAHAN BANK & CASINO")
  print(string.rep("=", 34))
  print("  1  Balances     4  Blackjack")
  print("  2  Deposit      5  Interest")
  print("  3  Withdraw     6  History")
  print("  0  Quit")
  print(string.rep("=", 34))
  io.write("> ")
  local choice = io.read()

  if choice == nil or choice == "0" then
    running = false
  elseif actions[choice] then
    actions[choice]()
  else
    print("Invalid option.")
  end
until not running

print("\n=== GOODBYE! COME AGAIN. ===")