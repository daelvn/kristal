-- kristal | 1.04.2018
-- By daelvn
-- Wallet formats

local function repeatf (f, a, n)
  local arg = a
  for i=1,n do f(a) end
  return arg
end

return function (wtype)
  return function (pkey, hash, username)
    local kwu_error = "kristal/core/wallets  Username was not provided for the kristwallet_username format!"
    if     wtype == "kristwallet"          then return hash ("KRISTWALLET" .. pkey) .. "-000"
    elseif wtype == "kristwallet_username" then local huser = hash(hash(username and username or error(kwu_error)))
                                                return hash ("KRISTWALLETEXTENSION" .. huser .. "^" .. hash (pkey)) .. "-000"
    elseif wtype == "jwalelset"            then return repeatf (hash, pkey, 18)
    elseif wtype == "plain"                then return pkey
    elseif wtype == "dvseal"               then -- Only to be used with Kristecon 
      -- Generate securer/hrnd
      local rnd16 = ""
      for i=1,16 do
        math.randomseed (os.epoch "utc")
        rnd16 = rnd16 .. tostring (math.random(0,9))
      end
      local hrnd = ("%x"):format (tonumber(rnd16))
      -- Generate wpkey
      -- DVSEAL:password;hrnd-000
      local wpkey = hash ("DVSEAL:" .. hash(pkey) .. ";" .. hrnd) .. "-000"
      -- Return
      return wpkey, hrnd
    else   error "kristal/core/wallets  Wallet type was not specified!"
    end
  end
end
