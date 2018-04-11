package.path = "../?.lua"
local Http = "core.lua"

-- Callbacks
local function onSuccess (url, handle)
  print (url, handle.readAll())
end

-- Vars
local at = "https://krist.ceriat.net"

-- Make request
Http.GET (Http.format (at.."/names/:name", {name="dv.kst"}), onSuccess, function()end)

-- Start loop
Http.go ()
