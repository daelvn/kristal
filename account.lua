-- kristal | 21.03.2018
-- By daelvn
-- Krist API - Addresses and Names

-- Require
local Class  = require "class.manager"
local Krist  = require "core.krist"
local Wallet = require "core.wallets"
local routes = require "core.route"

-- SHA256
local g = string.gsub
local sha256 = loadstring(g(g(g(g(g(g(g(g('Sa=XbandSb=XbxWSc=XlshiftSd=unpackSe=2^32SYf(g,h)Si=g/2^hSj=i%1Ui-j+j*eVSYk(l,m)Sn=l/2^mUn-n%1VSo={0x6a09e667Tbb67ae85T3c6ef372Ta54ff53aT510e527fT9b05688cT1f83d9abT5be0cd19}Sp={0x428a2f98T71374491Tb5c0fbcfTe9b5dba5T3956c25bT59f111f1T923f82a4Tab1c5ed5Td807aa98T12835b01T243185beT550c7dc3T72be5d74T80deb1feT9bdc06a7Tc19bf174Te49b69c1Tefbe4786T0fc19dc6T240ca1ccT2de92c6fT4a7484aaT5cb0a9dcT76f988daT983e5152Ta831c66dTb00327c8Tbf597fc7Tc6e00bf3Td5a79147T06ca6351T14292967T27b70a85T2e1b2138T4d2c6dfcT53380d13T650a7354T766a0abbT81c2c92eT92722c85Ta2bfe8a1Ta81a664bTc24b8b70Tc76c51a3Td192e819Td6990624Tf40e3585T106aa070T19a4c116T1e376c08T2748774cT34b0bcb5T391c0cb3T4ed8aa4aT5b9cca4fT682e6ff3T748f82eeT78a5636fT84c87814T8cc70208T90befffaTa4506cebTbef9a3f7Tc67178f2}SYq(r,q)if e-1-r[1]<q then r[2]=r[2]+1;r[1]=q-(e-1-r[1])-1 else r[1]=r[1]+qVUrVSYs(t)Su=#t;t[#t+1]=0x80;while#t%64~=56Zt[#t+1]=0VSv=q({0,0},u*8)fWw=2,1,-1Zt[#t+1]=a(k(a(v[w]TFF000000),24)TFF)t[#t+1]=a(k(a(v[w]TFF0000),16)TFF)t[#t+1]=a(k(a(v[w]TFF00),8)TFF)t[#t+1]=a(v[w]TFF)VUtVSYx(y,w)Uc(y[w]W0,24)+c(y[w+1]W0,16)+c(y[w+2]W0,8)+(y[w+3]W0)VSYz(t,w,A)SB={}fWC=1,16ZB[C]=x(t,w+(C-1)*4)VfWC=17,64ZSD=B[C-15]SE=b(b(f(B[C-15],7),f(B[C-15],18)),k(B[C-15],3))SF=b(b(f(B[C-2],17),f(B[C-2],19)),k(B[C-2],10))B[C]=(B[C-16]+E+B[C-7]+F)%eVSG,h,H,I,J,j,K,L=d(A)fWC=1,64ZSM=b(b(f(J,6),f(J,11)),f(J,25))SN=b(a(J,j),a(Xbnot(J),K))SO=(L+M+N+p[C]+B[C])%eSP=b(b(f(G,2),f(G,13)),f(G,22))SQ=b(b(a(G,h),a(G,H)),a(h,H))SR=(P+Q)%e;L,K,j,J,I,H,h,G=K,j,J,(I+O)%e,H,h,G,(O+R)%eVA[1]=(A[1]+G)%e;A[2]=(A[2]+h)%e;A[3]=(A[3]+H)%e;A[4]=(A[4]+I)%e;A[5]=(A[5]+J)%e;A[6]=(A[6]+j)%e;A[7]=(A[7]+K)%e;A[8]=(A[8]+L)%eUAVUY(t)t=t W""t=type(t)=="string"and{t:byte(1,-1)}Wt;t=s(t)SA={d(o)}fWw=1,#t,64ZA=z(t,w,A)VU("%08x"):rep(8):format(d(A))V',"S"," local "),"T",",0x"),"U"," return "),"V"," end "),"W","or "),"X","bit32."),"Y","function "),"Z"," do "))()

-- Create Account class
local Account = Class "Account" (
  function (argl)
    -- Object
    local object = {
      address = "",
      hrnd    = "",
      name    = false,
      key     = "",
    }
    -- Typechecking and functionality
    if argl.own then
      if     not argl.key then              return "kristal/Account:new  Key was not provided!"
      elseif type (argl.key) ~= string then return "kristal/Account:new  Key must be a string!"
      end
      if     argl.format then object.key  = Wallet (argl.format) (argl.key, sha256) end
      if     argl.hrnd   then object.hrnd = argl.hrnd                               end
    end

    if     argl.new     then
      -- If new=true, then create a new address
      if not argl.format then return "kristal/Account:new{new=true}  Wallet format was not provided!" end
      -- Format pkey
      local key, hrnd = Wallet (argl.format) (argl.key, sha256)
      object.hrnd = hrnd
      if argl.format and (not hrnd) then return "kristal/Account:new{new=true}  Error creating dvseal wallet!" end
      -- Use krist.ceriat.net/v2 or not?
      if argl.online then
        local kristV2AddressGen = Krist:new {endpoint="krist.ceriat.net"}
        local response = kristV2AddressGen:POST {at="/v2", params={privatekey=key}}
        object.address = response.address
      else
        -- HexTo36
        local hexTo36 = function (input) tonumber (input, 36) end
        -- MakeV2Address
        local chars  = {}
        local v2     = "k"
        local hash   = sha256 (sha256( key ))

        for i = 0, 8 do
          chars[i] = hash:sub (1,3)
          hash     = sha256 (sha256( hash ))
        end

        local i = 0
        repeat
          local index = tonumber ( hash:sub (2*i,2+2*i), 16) % 9
          --
          if chars[index] == nil then
            hash = sha256 (hash)
          else
            v2 = v2 .. hexTo36 (tonumber(chars[index],16))
            chars[index] = nil
            i = i + 1
          end
        until i > 8
        object.address = v2
      end
    -- If an account is provided, verify and use it
    elseif argl.address then
      local admatch     = ("^k---------$"):gsub ("-", "%[a%-z0%-9%]")
      local admatch_alt = ("^k----------$"):gsub ("-", "%[a%-f0%-9%]")

      if argl.address:match (admatch)
      or argl.address:match (admatch_alt)
      then object.address = argl.address
      else return "kristal/Account:new{address="..tostring(argl.address).."}  Could not validate address!" end
    -- If a name is provided, validate it and set
    elseif argl.name    then
      local kristNameValidator   = Krist:new {endpoint="krist.ceriat.net"}
      local response             = kristNameValidator:GET {at=routes.name.get, ft={name=argl.name}}
      object.name                = response.name
      object.name.pretty         = argl.name
      object.address             = response.name.owner
    else
      return "kristal/Account:new{name="..tostring(argl.name).."}  Could not validate name!"
    end
    object.recipient = object.name or object.address
    -- Get address info
    object.update = function (self)
      object.info = {}
      local kristAddressInfo = Krist:new {endpoint="krist.ceriat.net"}
      -- Basic info
      local basic = kristAddressInfo:GET {at=routes.addresses.get, ft={address=self.address}}
      self.info.balance   = basic.address.balance
      self.info.totalIn   = basic.address.totalin
      self.info.totalOut  = basic.address.totalout
      self.info.firstSeen = basic.address.firstseen
      -- Latest transactions
      local transactions = kristAddressInfo:GET {
        at=routes.addresses.transactions,
        ft={address=self.address,limit=10,offset=0}
      }
      self.info.transactions = {
        total = transactions.total,
        list  = transactions.transactions
      }
      -- Registered names
      local names = kristAddressInfo:GET {at=routes.addresses.names, ft={address=self.address}}
      self.info.names = {
        total=names.total,
        list=names.names
      }
    end
    -- Get info
    object:update ()
    -- Authenticate
    if argl.auth then
      local kristAuthenticator = Krist:new {endpoint="krist.ceriat.net"}
      local response = kristAuthenticator:POST {at=routes.misc.login, ft={v=2}, params={privatekey=argl.pkey}}
      if not response.authed then return "kristal/Account:new{auth=true}  Could not authorize pkey!" end
    end

    return object
  end
)

return Account
