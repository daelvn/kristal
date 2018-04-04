-- kristal | 02.04.2018
-- By daelvn
-- Transaction manager
-- INFO  This module requires websockets

-- Require
local routes = require "core.route"
local Class  = require "class.manager"
local Krist  = require "core.krist"
local _go    = Krist._go

local TransactionAgent = Class "TransactionAgent" (
  function (argl)
    -- Object
    return {
      involved = {
        ingoing  = {},
        outgoing = {}
      } -- Transactions that the library has been involved in
    }
  end
)

-- Parse metadata
function TransactionAgent.parseMetadata (str)
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
      local address = field:match "^k([a-z0-9])$"
      if address:len() ~= 9 then error "kristal/TransactionAgent:parseMetadata  Address is not valid!" end
      metadata.address = address
    -- Match a name --
    elseif field:match "^([a-z0-9-_]*)@*([a-z0-9-_]-)%.kst$" then
      local meta, name = str:match "^([a-z0-9-_]*)@*([a-z0-9-_]-)%.kst"
      if meta or name then
        -- Check length
        if (name:len () > 64) or (meta:len () > 32) then
          error "kristal/TransactionAgent:parseMetadata  The name exceeds the permitted length!"
        end
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
  self.triggers[Address.point] = {address=Address,handler=handler}
end

-- Handle all transactions
-- Users should provide their own handler for managing transactions
-- You can use TransactionAgent:handlerBuild -> Handle
function TransactionAgent:wrap (data, handler)
  local Transaction = data.transaction
  local Metadata    = self.parseMetadata (Transaction.metadata)
  -- Store transaction
  self.involved.ingoing[#self.involved.ingoing+1] = Transaction
  return function () handler (Transaction, Metadata) end
end

-- Serialize a metadata string
function TransactionAgent:serializeMetadata (metadata)
  local final = ""
  for k,v in pairs (metadata) do
    if k == "$" then
      final = v .. final
    else
       final = final .. tostring (k) .. "=" .. tostring (v) .. ";"
    end
  end
  if final:match ";$" then final:gsub (";$", "") end
  return final
end

-- Make a transaction (HTTP-POST)
function TransactionAgent:make (From, To, amount, meta)
  local kristAgent = Krist:new ("krist.ceriat.net", "http://", "ws://")
  local response   = kristAgent:POST {at=routes.transactions.make, params={
    privatekey = From.key or error "krist/TransactionAgent:make  You must provide a source account with a key!",
    to         = To.recipient,
    amount     = amount,
    metadata   = self.serializeMetadata (meta)
  }}
  From.info.balance = From.info.balance - amount
  -- Return the transaction id and save it on a registry
  self.involved.outgoing[#self.involved.outgoing+1] = response.transaction
  return response.transaction.id
end

-- Transaction sorters
-- By default tables should be already sorted by-time, as well as after filtering (not inner-filtering)
-- on:
--   ingoing
--   outgoing
-- filter:
--   from-address
--   to-address
--   amount
--   id
-- by:
--   from-address
--   to-address
--   id
--   amount
-- inner-by:
--   id
--   amount
function TransactionAgent:sort (on, filter, by, inner_by)
  local actOn  = ( (on == "ingoing")  and self.involved.ingoing  )
              or ( (on == "outgoing") and self.involved.outgoing )
              or error "kristal/TransactionAgent:sort  Could not match the table to act on!"
  local pre = {}

  if filter == "from-address" then
    for i,tr in pairs (actOn) do
      --
      if     pre[tr.name] then pre[tr.name][#pre[tr.name]+1] = tr
      elseif pre[tr.from] then pre[tr.from][#pre[tr.from]+1] = tr
      else
        if     tr.name then pre[tr.name] = {}; pre[tr.name][#pre[tr.name]+1] = tr
        elseif tr.from then pre[tr.from] = {}; pre[tr.from][#pre[tr.from]+1] = tr
        else   error "kristal/TransactionAgent:sort{filter=from-address}  Malformed transaction!"
        end
      end
      --
    end
  elseif filter == "to-address" then
    for i,tr in pairs (actOn) do
      --
      if   pre[tr.to] then pre[tr.to][#pre[tr.to]+1] = tr
      else
        if   tr.to then pre[tr.to] = {}; pre[tr.to][#pre[tr.to]+1] = tr
        else error "kristal/TransactionAgent:sort{filter=to-address}  Malformed transaction!"
        end
      end
      --
    end
  elseif filter == "amount" then
    table.sort (actOn, function (a,b) return a.value > b.value end)
    pre = actOn
  elseif filter == "id" then
    table.sort (actOn, function (a,b) return a.id > b.id end)
    pre = actOn
  end

  if not by then return pre end

  if by == "from-address" then
    for ad,l in pairs (pre) do -- pre.khugepoopy.1 == Transaction
      for i,tr in pairs (l) do
      --
        if     l[tr.name] then l[tr.name][#l[tr.name]+1] = tr
        elseif l[tr.from] then l[tr.from][#l[tr.from]+1] = tr
        else
          if     tr.name then l[tr.name] = {}; l[tr.name][#l[tr.name]+1] = tr
          elseif tr.from then l[tr.from] = {}; l[tr.from][#l[tr.from]+1] = tr
          else   error "kristal/TransactionAgent:sort{filter=by-address}  Malformed transaction!"
          end
        end
        --
      end
    end
  elseif by == "to-address" then
    for ad,l in pairs (pre) do
      for i,tr in pairs (l) do
        --
        if   l[tr.to] then l[tr.to][#l[tr.to]+1] = tr
        else
          if   tr.to then l[tr.to] = {}; l[tr.to][#l[tr.to]+1] = tr
          else error "kristal/TransactionAgent:sort{filter=to-address}  Malformed transaction!"
          end
        end
        --
      end
    end
  elseif by == "amount" then
    for ad,l in pairs (pre) do
      table.sort (l, function (a,b) return a.value > b.value end)
    end
  elseif by == "id" then
    for ad,l in pairs (pre) do
      table.sort (l, function (a,b) return a.id > b.id end)
    end
  else error "kristal/TransactionAgent:sort  $by was passed but it has an incorrect value!" end

  if not inner_by then return pre end
  if inner_by == "amount" then
    for ad,l in pairs (pre) do
      for ad2,l2 in pairs (l) do
        table.sort (l2, function (a,b) return a.value > b.value end)
      end
    end
  elseif inner_by == "id" then
    for ad,l in pairs (pre) do
      for ad2,l2 in pairs (l) do
        table.sort (l2, function (a,b) return a.id > b.id end)
      end
    end
  else error "kristal/TransactionAgent:sort  $inner_by was passed but it has an incorrect value!" end

  return pre
end

return {
  Agent   = TransactionAgent,
  Handler = TransactionHandler,
  _go     = _go
}








