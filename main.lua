-- kristal | 04.04.2018
-- By daelvn
-- Main file to be imported

-- Namespace
local Kristal = {
  Account     = require "account",
  Transaction = require "transaction",
  Wallet      = require "core.wallets"
}

-- Jua.go
Kristal.go = Kristal.Transaction._go

-- Return
return Kristal

