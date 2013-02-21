require("rpilibs")
local ffi = require("ffi")

local piper = {}

function piper.ffi_abi()
   local rv = {}
   for k,v in ipairs({ "32bit", "64bit", "le", "be", "fpu", "softfp", "hardfp", "eabi", "win" }) do
      rv[v] = ffi.abi(v)
   end
   return rv
end

return piper
