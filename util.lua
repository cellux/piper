local ffi = require("ffi")

ffi.cdef [[
unsigned int sleep (unsigned int seconds);
int getchar(void);
]]

local util = {}

util.sleep = ffi.C.sleep
util.getchar = ffi.C.getchar

return util
