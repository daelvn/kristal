-- kristal | 31.03.2018
-- By daelvn
-- Connection to the Krist API

-- Require
package.path  = "../?.lua"
local Class   = require "class.manager"
local libjson = require "lib.json"
local Jua     = require "lib.jua"

-- Create Krist class
local Krist = Class "Krist" (
  function (argl) -- endpoint, http_protocol*, ws_protocol*
    -- Typechecks
    if     not argl.endpoint                     then return "kristal/Krist  argl.endpoint expected!"
    elseif type (argl.endpoint) ~= "string"      then return "kristal/Krist  argl.endpoint must be a string!"
    elseif not argl.http_protocol                then argl.http_protocol = "http://"
    elseif not argl.ws_protocol                  then argl.ws_protocol   = "ws://"
    elseif type (argl.http_protocol) ~= "string" then return "kristal/Krist  argl.http_protocol must be a string!"
    elseif type (argl.ws_protocol) ~= "string"   then return "kristal/Krist  argl.ws_protocol must be a string!"
    end
    -- Object
    return {
      endpoint = argl.endpoint,
      httpProtocol = argl.http_protocol,
      wsProtocol   = argl.ws_protocol,
    }
  end
)

-- Turns :a into solved addresses
function Krist:format (at, ft)
  for param in at:gmatch ":[a-z]+" do
    if ft[param:sub (2)] then at:gsub (param, ft[param:sub (2)]) end
  end
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
    return response.ok and response or error "kristal/Krist:GET  Failed request!"
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
    return response.ok and response or error "kristal/Krist:POST  Failed request!"
  end
end

-- Makes a PUT request
function Krist:PUT (t)
  local at, ft, params = t.at, t.ft or {}, t.params
  local paramstr
  for i,v in pairs (params) do
    paramstr = paramstr..i.."="..textutils.urlEncode (v).."&"
  end

  local handle = http.post (self.httpProtocol .. self.endpoint .. self:format (at,ft), paramstr, {["X-HTTP-Method-Override"] = "PUT"})
  if handle.getResponseCode () ~= 200 then
    error ("kristal/Krist:PUT  HTTP Response code is "..tostring (handle.getResponseCode()))
  else
    local response = libjson.decode (handle.readAll())
    handle.close ()
    return response.ok and response or error "kristal/Krist:PUT  Failed request!"
  end
end

-- Makes a DELETE request
function Krist:DELETE (t)
  local at, ft, params = t.at, t.ft or {}, t.params
  local paramstr
  for i,v in pairs (params) do
    paramstr = paramstr..i.."="..textutils.urlEncode (v).."&"
  end

  local handle = http.post (self.httpProtocol .. self.endpoint .. self:format (at,ft), paramstr, {["X-HTTP-Method-Override"] = "DELETE"})
  if handle.getResponseCode () ~= 200 then
    error ("kristal/Krist:PUT  HTTP Response code is "..tostring (handle.getResponseCode()))
  else
    local response = libjson.decode (handle.readAll())
    handle.close ()
    return response.ok and response or error "kristal/Krist:DELETE  Failed request!"
  end
end

-- Websockets --
function Krist:asyncSocketConnect ()
  if not http.websocketAsync then
    error "kristal/Krist:wsConnect  Could not find http.websocketAsync! Do you have CC:Tweaked installed?"
  end
  http.websocketAsync (self.wsProtocol..self.endpoint)
end

Jua.on ("websocket_failure", function ()                   error "kristal/Krist:asyncSocketConnect  Could not connect to websocket!" end)
Jua.on ("websocket_success", function (event, url, handle) os.queueEvent ("kristal:init",    url, handle) end)
Jua.on ("websocket_message", function (event, url, data)   os.queueEvent ("kristal:message", url, data)   end)
Jua.on ("websocket_closed" , function (event, url)         os.queueEvent ("kristal:end",     url)         end)

-- Return
return Krist
