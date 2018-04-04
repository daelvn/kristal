-- kristal | 31.03.2018
-- By daelvn
-- Connection to the Krist API

-- Linter
local http      = http
local textutils = textutils

-- Require
local Class   = require "class.manager"
local libjson = require "lib.json"
local Jua     = require "lib.jua"
local Wsk     = {
  k = require "lib.wsk.k",
  w = require "lib.wsk.w",
  r = require "lib.wsk.r"
}

-- Create Krist class
local Krist = Class "Krist" (
  function (argl) -- endpoint, http_protocol*, ws_protocol*
    -- Typechecks
    if     not   argl.endpoint                   then return "kristal/Krist  argl.endpoint expected!"
    elseif type (argl.endpoint)      ~= "string" then return "kristal/Krist  argl.endpoint must be a string!"
    elseif not   argl.http_protocol              then argl.http_protocol = "http://"
    elseif not   argl.ws_protocol                then argl.ws_protocol   = "ws://"
    elseif type (argl.http_protocol) ~= "string" then return "kristal/Krist  argl.http_protocol must be a string!"
    elseif type (argl.ws_protocol)   ~= "string" then return "kristal/Krist  argl.ws_protocol must be a string!"
    end
    -- Object
    return {
      endpoint     = argl.endpoint,
      httpProtocol = argl.http_protocol,
      wsProtocol   = argl.ws_protocol,
    }
  end
)

-- Turns :a into solved addresses
function Krist.format (at, ft)
  for param in at:gmatch ":[a-z]+" do
    if ft[param:sub (2)] then at = at:gsub (param, ft[param:sub (2)]) end
  end
  return at
end

-- Makes a GET request
function Krist:GET (t)
  local at, ft = t.at, t.ft or {}
  local handle = http.get (self.httpProtocol .. self.endpoint .. self:format (at,ft))
  if handle.getResponseCode () ~= 200 then
    error ("kristal/Krist:GET  HTTP Response code is "..tostring (handle.getResponseCode()))
  else
    local response = libjson.decode (handle.readAll ())
    handle.close ()
    return response.ok and response or error "kristal/Krist:GET  Failed request! ".. response["error"]
  end
end

-- Makes a POST request
function Krist:POST (t)
  local at, ft, params = t.at, t.ft or {}, t.params
  local paramstr
  for i,v in pairs (params) do
    paramstr = paramstr..i.."="..textutils.urlEncode (v).."&"
  end

  local handle = http.post (self.httpProtocol .. self.endpoint .. self:format (at,ft), paramstr)
  if handle.getResponseCode () ~= 200 then
    error ("kristal/Krist:POST  HTTP Response code is "..tostring (handle.getResponseCode()))
  else
    local response = libjson.decode (handle.readAll ())
    handle.close ()
    return response.ok and response or error "kristal/Krist:POST  Failed request!" .. response["error"]
  end
end

-- Makes a PUT request
function Krist:PUT (t)
  local at, ft, params = t.at, t.ft or {}, t.params
  local paramstr
  for i,v in pairs (params) do
    paramstr = paramstr..i.."="..textutils.urlEncode (v).."&"
  end

  local handle = http.post (self.httpProtocol
                         .. self.endpoint
                         .. self:format (at,ft), paramstr, {["X-HTTP-Method-Override"] = "PUT"})
  if handle.getResponseCode () ~= 200 then
    error ("kristal/Krist:PUT  HTTP Response code is "..tostring (handle.getResponseCode()))
  else
    local response = libjson.decode (handle.readAll())
    handle.close ()
    return response.ok and response or error "kristal/Krist:PUT  Failed request! ".. response["error"]
  end
end

-- Makes a DELETE request
function Krist:DELETE (t)
  local at, ft, params = t.at, t.ft or {}, t.params
  local paramstr
  for i,v in pairs (params) do
    paramstr = paramstr..i.."="..textutils.urlEncode (v).."&"
  end

  local handle = http.post (self.httpProtocol
                         .. self.endpoint
                         .. self:format (at,ft), paramstr, {["X-HTTP-Method-Override"] = "DELETE"})
  if handle.getResponseCode () ~= 200 then
    error ("kristal/Krist:PUT  HTTP Response code is "..tostring (handle.getResponseCode()))
  else
    local response = libjson.decode (handle.readAll())
    handle.close ()
    return response.ok and response or error "kristal/Krist:DELETE  Failed request! ".. response["error"]
  end
end

-- Websockets --
-- Krist:socketConnect (Address, TransactionAgent:handle, handle)
function Krist:socketConnect (endpoint, wsEndpoint, httpEndpoint, Address, _transactionWrapper, _transactionHandler) -- _transactionHandler (data)
  local ok, socket = Jua.await (Wsk.k.connect, endpoint, wsEndpoint, httpEndpoint, Address.key)
  if not ok then error "kristal/Krist:socketConnect  Could not connect to Krist Websocket!" end
  local success = Jua.await (socket.subscribe, "transactions", _transactionWrapper (_transactionHandler))
  if not success then error "kristal/Krist:socketConnect  Could not handle transaction!" end
  Jua.on ("terminate", function () socket.close (); Jua.stop () end)
end

function Krist._go (f) Jua.go (f) end

return Krist
