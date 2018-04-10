-- kristal | 10.04.2018
-- By daelvn
-- Asynchronous library for making HTTP requests using callbacks
-- Http.go MUST be called in parallel

-- Luacheck
-- luacheck: ignore http
-- luacheck: ignore os

-- Check the platform
if not http then error "kristal/Http  HTTP API was not found" end

-- Requires
package.path     = "../?.lua"
local Class      = require "core.class"
local typeassert = require "core.utils".typeassert

-- Create a Http class
local Http = Class ( function (argl)
  -- Typechecking
  local cf = "Http:new"
  typeassert (cf, argl.url) "string"
  -- Object
  return {url=argl.url}
end)

-- .format string at, table replace
function Http.format (at, replace)
  -- Typechecking
  local cf = "Http.format"
  typeassert (cf, at)      "string"
  typeassert (cf, replace) "table"
  --
  for placeholder in at:gmatch ":(%w+)" do
    if typeassert (cf, replace[placeholder]) "string" then
      at = at:gsub (placeholder, replace[placeholder])
    end
  end
  return at
end

-- .toPOST table postdata
function Http.toPOST (postdata)
  -- Typechecking
  local cf = "Http.toPOST"
  typeassert (cf, postdata) "table"
  --
  local result = ""
  for i,v in pairs (postdata) do
    typeassert (i) "string"
    result = result .. i .. "=" .. tostring (v) .. "&"
  end
  result = result:gsub ("&$","")
  return result
end

-- :GET string at, function onSuccess, function onFailure
function Http:GET (at, onSuccess, onFailure)
  -- Typechecking
  local cf = "Http:GET"
  typeassert (cf, at) "string"
  --
  http.request (at)
  os.queueEvent ("kristal:http", onSuccess, onFailure)
end

-- :POST string at, table postdata, function onSuccess, function onFailure
function Http:POST (at, postdata, onSuccess, onFailure)
  -- Typechecking
  local cf = "Http:GET"
  typeassert (cf, at)       "string"
  typeassert (cf, postdata) "table"
  --
  http.request (at, self.toPOST (postdata))
  os.queueEvent ("kristal:http", onSuccess, onFailure)
end

-- :go
function Http:go ()
  local httpUrl, httpHandle, httpDone
  local onSuccess, onFailure
  while true do
    local event, a, b = os.pullEvent ()
    if     event == "http_success" then httpUrl = a; httpHandle = b; httpDone = true
    elseif event == "http_failure" then httpDone = false
    elseif event == "kristal:http" then
      onSuccess = a; onFailure = b
      if httpDone then onSuccess (httpUrl, httpHandle) else onFailure () end
    end
  end
end

-- Return
return Http
