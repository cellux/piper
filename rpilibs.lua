local ffi = require("ffi")
local format = string.format

-- rpi userland libraries
local rpi_libs = { "bcm_host",
		   "EGL",
		   "GLESv2",
		   "mmal",
		   "mmal_vc_client",
		   "openmaxil",
		   "OpenVG",
		   "vchiq_arm",
		   "vcos",
		   "WFC",
}

local ffi_namespace = 'lib'

for _,l in ipairs(rpi_libs) do
   local m = format("%s.%s", ffi_namespace, l)
   package.preload[m] = function()
      --print(format("loading module: %s",m))
      return ffi.load(l, true)
   end
end

return true
