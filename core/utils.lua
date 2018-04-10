-- kristal | 10.04.2018
-- By daelvn
-- Util functions for Kristal

local Utils = {}

-- Assert a type
function Utils.typeassert (f,v)
  return function (w)
    return (type (v) == type (w)) or error (
      "kristal/Utils.typeassert  At "..tostring(f)..": Type `"..type (w).."` expected, got `"..type (v).."`"
    )
  end
end

return Utils
