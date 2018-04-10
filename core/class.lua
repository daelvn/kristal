-- ve | 26.03.2018
-- By daelvn
-- Module ve.class.manager

-- Return the class creator function
-- Class "name" (f)
return function (name)
  return function (construct)
    -- Metamethods and Class internals
    local Class = {}
    Class.__index = Class
    Class._name   = name
    Class._type   = name
    -- Class constructor
    function Class:new (argl, obj)
      -- Construct
      local cargl = construct (argl)
      if type (cargl) == "string" then error (cargl) end
      return setmetatable (obj or cargl, self)
    end
    -- Return
    return Class
  end
end
