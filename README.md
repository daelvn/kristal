# Kristal
Kristal is a client for the [Krist](https://krist.ceriat.net) API. Despite not being complete, it covers the basic requirements such as account information and transaction handling. It uses Object-Oriented Lua.
## Dependencies
All dependencies come included in the repository.
- [Jua](https://github.com/justync7/Jua)
- [r.lua](https://github.com/justync7/r.lua)
- [w.lua](https://github.com/justync7/w.lua)
- [k.lua](https://github.com/justync7/k.lua)
- [json.lua](https://github.com/rxi/json.lua)

The r.lua dependency is yet to be removed, as it is not required.
## Features
### Complete and accurate parseMetadata
`Transaction.Agent` implements a fully accurate `parseMetadata` function that checks the length of name pieces and verifies addresses. To use it, you do not require an Object, is it as simple as doing: `Kristal.Transaction.Agent.parseMetadata (tbl)`.
If the table contains a key named `$`, that argument will be used as the name of the metastring.
### Organized user information
When you create an `Account` object, you are not simply wrapping a string, you are also verifying that it is a valid V2 address, and fetching information. That is why it is very easy to obtain the balance of any account.
```lua
local khugepoopy = Account:new {address="khugepoopy"}
local balance    = khugepoopy.info.balance
```

### Event-like transaction handling
You can assign a trigger to any address to `Transaction.Handle`, so that each name gets a different function to process.
```lua
local handler = Transaction.Handle:new ()
handler:on ("log@dv.kst", handleLogTransaction)
handler:on ("irn@dv.kst", handleIronTransaction)

local wrapper = Transaction.Agent:new ()

local myAddress = Address:new {name="dv.kst",own=true,key="pkey",format="dvseal"}

local socket = Krist:new ("krist.ceriat.net", "http://", "ws://")
socket:socketConnect (myAddress, wrapper:wrap, handler)
```
