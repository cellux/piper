local avloop = require('avloop')

local function vcb()
end

avloop.set_video_callback(vcb)
avloop.start()
