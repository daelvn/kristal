-- kristal | 06.04.2018
-- By daelvn
-- Logger

local log = {
  lines = {}
}

function log:open ()
  if fs.exists "logs/dumped.log" then fs.move ("logs/dumped.log", "logs/dumped.log.old") end
  self.file = "logs/dumped.log" 
end

function log:write (str)
  self.lines[#self.lines+1] = {msg="[INFO:" .. tostring (os.clock ()) .. "] " .. log.project .. "/" .. log.name .. ": " .. str, level=0}
end

function log:success (str)
  self.lines[#self.lines+1] = {msg="[SUCCESS:" .. tostring (os.clock ()) .. "] " .. log.project .. "/" .. log.name .. ": " .. str, level=1}
end

function log:warn (str)
  self.lines[#self.lines+1] = {msg="[WARN:" .. tostring (os.clock ()) .. "] " .. log.project .. "/" .. log.name .. ": " .. str, level=2}
end

function log:failure (str)
  self.lines[#self.lines+1] = {msg="[SUCCESS:" .. tostring (os.clock ()) .. "] " .. log.project .. "/" .. log.name .. ": " .. str, level=3}
end

function log:critical (str)
  self.lines[#self.lines+1] = {msg="[SUCCESS:" .. tostring (os.clock ()) .. "] " .. log.project .. "/" .. log.name .. ": " .. str, level=4}
end

function log:dump ()
  local h = fs.open (self.file, "w")
  for _,line in log.lines do
    h:write (line.msg)
    if line.level == 0 then
      term.setTextColor (colors.white)
      print (line.msg)
    elseif line.level == 1 then
      term.setTextColor (colors.green)
      print (line.msg)
    elseif line.level == 2 then
      term.setTextColor (colors.yellow)
      print (line.msg)
    elseif line.level == 3 then
      term.setTextColor (colors.red)
      print (line.msg)
    elseif line.level == 4 then
      term.setTextColor (colors.orange)
      print (line.msg)
    end
  end
  h:close ()
end

return log
