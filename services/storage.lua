local Storage = {}
local SAVE_FILE = "bankcasino.sav"

function Storage.save(wallet, bank)
  local tmp = SAVE_FILE .. ".tmp"
  local f = assert(io.open(tmp, "w"))
  f:write("wallet=", wallet.balance, "\n", "bank=", bank.balance, "\n")
  f:close()
  if not os.rename(tmp, SAVE_FILE) then
    os.remove(SAVE_FILE)
    os.rename(tmp, SAVE_FILE)
  end
end

function Storage.load()
  local data = { wallet = 100, bank = 500 }
  local f = io.open(SAVE_FILE, "r")
  if f then
    for key, val in f:read("*a"):gmatch("(%w+)=(%d+)") do
      data[key] = tonumber(val)
    end
    f:close()
  end
  return data
end

return Storage