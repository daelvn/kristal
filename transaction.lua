-- kristal | 02.04.2018
-- By daelvn
-- Transaction manager

-- Require
local Krist = require "core.krist"
local Jua   = require "lib.jua"

-- Namespace
local Transactions = {}

-- Make a transaction
function Transactions.make (From, To, value, meta)
  local kristAgent = Krist:new ("krist.ceriat.net", "http://", "ws://")
  kristAgent:asyncSocketConnect ()
  local ws_handle = {}
  -- Jua handlers
  Jua.on ("kristal:init", function(event, url, handle)
    ws_handle = handle
  end)
end
