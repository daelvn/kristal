-- Kristal | 13.04.2018
-- By daelvn
-- CLI utility for running tests

local argl = {...}
local doAll --[[ -* ]], doSetup --[[ -s ]], libPath --[[ -l ]]
local nextIs_l

for arg in pairs (argl) do
  if arg == "-a" then
    doAll = true
  elseif arg == "-s" then
    doSetup = true
  elseif arg == "-l" then
    nextIs_l = true
  elseif nextIs_l then
    libPath = arg
    nextIs_l = false
  end
end

if doSetup then
  package.path = libPath and libPath .. "?.lua" or ""
end
