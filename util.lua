local ffi = require("ffi")

ffi.cdef [[
unsigned int sleep (unsigned int seconds);
int getchar(void);
]]

-- bcm_host depends on vcos
local util = {}

util.sleep = ffi.C.sleep
util.getchar = ffi.C.getchar

return util
