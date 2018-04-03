-- kristal | 02.04.2018
-- By daelvn
-- Transaction manager
-- INFO  This module requires websockets

-- Require
local Class = require "class.manager"
local Krist = require "core.krist"
local Jua   = require "lib.jua"
local Wsk   = {
  k = require "lib.wsk.k",
  w = require "lib.wsk.w",
  r = require "lib.wsk.r",
}

-- Namespace
local TransactionAgent = Class "TransactionAgent" (
  function (argl)
    -- Typechecking
    if not argl.socket then return "kristal/TransactionAgent:new  Did not receive socket!" end
    -- Object
    return {
      socket = argl.socket
    }
  end
)
-- Parse metadata
function parseMetadata (str)
  if str:len() > 255 then error "kristal/TransactionAgent:parseMetadata  Metadata string is not valid: too long!" end
  -- Table with metadata
  local metadata = {}
  -- Iterate all non-semicolon groups
  for field in str:gmatch "[^;]+" do
    -- Match a field --
    if field:match "^(.+)=(.+)$" then
      local key, value = field:match "^(.+)=(.+)$"
      if key and value then
        if tonumber(value) then value = tonumber(value) end
        metadata[key] = value
      else
        error "kristal/TransactionAgent:parseMetadata  Malformed field in metadata!"
      end
    -- Match an address --
    elseif field:match "^k([a-z0-9])$" then
      if address:len() ~= 9 then error "kristal/TransactionAgent:parseMetadata  Address is not valid!" end
      metadata.address = address
    -- Match a name --
    elseif field:match "^([a-z0-9-_]*)@*([a-z0-9-_]-)%.kst$" then
      local meta, name = str:match "^([a-z0-9-_]*)@*([a-z0-9-_]-)%.kst"
      if meta or name then
        -- Check length
        if   (name:len () > 64) or (meta:len () > 32) then error "kristal/TransactionAgent:parseMetadata  The name exceeds the permitted length!" end
        -- Save data
        if name == "" then
          metadata.name = meta
          metadata.full = metadata.name .. ".kst"
        else
          metadata.name = name
          metadata.meta = meta
          metadata.full = metadata.meta .. "@" .. metadata.name .. ".kst"
        end
      end
    end
  end
  return metadata
end

-- Handle builder
local TransactionHandler = Class "TransactionHandler" (
  function (argl)
    -- Object
    return {
      triggers = {}
    }
  end 
)

-- Run all the triggers
getmetatable (TransactionHandler).__call = function (t, Transaction, Metadata)
  for k,v in pairs(t.triggers) do
    if k == Metadata.full then
      -- Trigger has matched, execute it
      v (Transaction, Metadata)
    end
  end
end

-- Create a new trigger
function TransactionHandler:on (Address, handler)
  triggers[Address.point] = {address=Address,handler=handler}
end

-- Handle all transactions
-- Users should provide their own handler for managing transactions
-- You can use TransactionAgent:handlerBuild -> Handle
function TransactionAgent:wrap (data, handler)
  local Transaction = data.transaction
  local Metadata    = self.parseMetadata (Transaction.metadata)

  return function () handler (Transaction, Metadata) end
end

-- Make a transaction
function TransactionAgent:make (From, To, amount, meta)
  
end
