local Kristal = require "main"

-- Accounts
local khugepoopy = Kristal.Account:new {address="khugepoopy"}
local dv_kst     = Kristal.Account:new {name="dv.kst", own=true, key="pkey", format="dvseal"}

-- Agent
local agent = Kristal.Transaction.Agent:new ()

-- Handler
local handler = Kristal.Transaction.Handler:new ()
handler:on ("donate-to-lem@dv.kst", function(Transaction,Metadata)
  agent:make (dv_kst, khugepoopy, Transaction.value, {donate="true",message="Someone donated through dv.kst"})
end)

-- Start listening to the Websocket
agent:socketConnect (dv_kst, agent.wrap, handler)

-- Tell Kristal to start executing
Kristal.go ()
