-- k.lua | 02.04.2018
-- Websocket-only version
-- By justync7

local textutils = textutils

local w     = require "lib.wsk.w"
local r     = require "lib.wsk.r"
local jua   = require "lib.jua"
local json  = require "lib.json"
local await = jua.await

local function asserttype(var, name, vartype, optional)
  if not (type(var) == vartype or optional and type(var) == "nil") then
    error(name..": expected "..vartype.." got "..type(var), 3)
  end
end

local function url(httpEndpoint, call)
  return httpEndpoint..call
end

local function api_request(cb, api, data)
  local success, url, handle = await(r.request, url(api), {["Content-Type"]="application/json"}, data and json.encode(data))
  if success then
    cb(success, json.decode(handle.readAll()))
    handle.close()
  else
    cb(success)
  end
end

local function authorize_websocket(cb, privatekey)
  asserttype(cb, "callback", "function")
  asserttype(privatekey, "privatekey", "string", true)

  api_request(function(success, data)
    cb(success, data and data.url:gsub("wss:", "ws:"))
  end, "/ws/start", {
    privatekey = privatekey
  })
end

local wsEventNameLookup = {
  blocks = "block",
  ownBlocks = "block",
  transactions = "transaction",
  ownTransactions = "transaction",
  names = "name",
  ownNames = "name",
  ownWebhooks = "webhook",
  motd = "motd"
}

local wsEvents = {}

local wsReqID = 0
local wsReqRegistry = {}
local wsEvtRegistry = {}
local wsHandleRegistry = {}

local function newWsID()
  local id = wsReqID
  wsReqID = wsReqID + 1
  return id
end

local function registerEvent(id, event, callback)
  if wsEvtRegistry[id] == nil then
    wsEvtRegistry[id] = {}
  end

  if wsEvtRegistry[id][event] == nil then
    wsEvtRegistry[id][event] = {}
  end

  table.insert(wsEvtRegistry[id][event], callback)
end

local function registerRequest(id, reqid, callback)
  if wsReqRegistry[id] == nil then
    wsReqRegistry[id] = {}
  end

  wsReqRegistry[id][reqid] = callback
end

local function discoverEvents(id, event)
    local evs = {}
    for k,v in pairs(wsEvtRegistry[id]) do
        if k == event or string.match(k, event) or event == "*" then
            for i,v2 in ipairs(v) do
                table.insert(evs, v2)
            end
        end
    end

    return evs
end

wsEvents.success = function(id, handle)
  -- fire success event
  wsHandleRegistry[id] = handle
  if wsEvtRegistry[id] then
    local evs = discoverEvents(id, "success")
    for i, v in ipairs(evs) do
      v(id, handle)
    end
  end
end

wsEvents.failure = function(id)
  -- fire failure event
  if wsEvtRegistry[id] then
    local evs = discoverEvents(id, "failure")
    for i, v in ipairs(evs) do
      v(id)
    end
  end
end

wsEvents.message = function(id, edata)
  local data = json.decode(edata)
  --print("msg:"..tostring(data.ok)..":"..tostring(data.type)..":"..tostring(data.id))
  --prints(data)
  -- handle events and responses
  if wsReqRegistry[id] and wsReqRegistry[id][tonumber(data.id)] then
    wsReqRegistry[id][tonumber(data.id)](data)
  elseif wsEvtRegistry[id] then
    local evs = discoverEvents(id, data.type)
    for i, v in ipairs(evs) do
      v(data)
    end

    if data.event then
      local evs = discoverEvents(id, data.event)
      for i, v in ipairs(evs) do
        v(data)
      end
    end

    local evs2 = discoverEvents(id, "message")
    for i, v in ipairs(evs2) do
      v(id, data)
    end
  end
end

wsEvents.closed = function(id)
  -- fire closed event
  if wsEvtRegistry[id] then
    local evs = discoverEvents(id, "closed")
    for i, v in ipairs(evs) do
      v(id)
    end
  end
end

local function wsRequest(cb, id, type, data)
  local reqID = newWsID()
  registerRequest(id, reqID, function(data)
    cb(data)
  end)
  data.id = tostring(reqID)
  data.type = type
  wsHandleRegistry[id].send(json.encode(data))
end

local function barebonesMixinHandle(id, handle)
  handle.on = function(event, cb)
    registerEvent(id, event, cb)
  end

  return handle
end

local function mixinHandle(id, handle)
  handle.subscribe = function(cb, event, eventcb)
    local data = await(wsRequest, id, "subscribe", {
      event = event
    })
    registerEvent(id, wsEventNameLookup[event], eventcb)
    cb(data.ok, data)
  end

  return barebonesMixinHandle(id, handle)
end

local function connect(endpoint, wsEndpoint, httpEndpoint, cb, privatekey, preconnect)
  asserttype(cb, "callback", "function")
  asserttype(privatekey, "privatekey", "string", true)
  asserttype(preconnect, "preconnect", "function", true)
  local url
  if privatekey then
    local success, auth = await(authorize_websocket, privatekey)
    url = success and auth or wsEndpoint
  end
  local id = w.open(wsEvents, url)
  if preconnect then
    preconnect(id, barebonesMixinHandle(id, {}))
  end
  registerEvent(id, "success", function(id, handle)
    cb(true, mixinHandle(id, handle))
  end)
  registerEvent(id, "failure", function(id)
    cb(false)
  end)
end

return {connect=connect}
