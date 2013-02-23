local image = require("image")

local ffi = require("ffi")
local bit = require("bit")
local bcm_host = require("bcm_host")
local dispmanx = require("dispmanx")
local util = require("util")

local function main()
   local dmx = {}
   dmx.dpy = dispmanx.display()
   dmx.info = dmx.dpy:get_info()
   dmx.src, dmx.src_rect = image.load('image-test.jpg', 'dispmanx_resource')
   print(string.format("dmx.src_rect=%s", dmx.src_rect))
   local w = dmx.src_rect.width
   local h = dmx.src_rect.height
   if w > dmx.info.width then
      local scale = dmx.info.width/w
      w = scale * w
      h = scale * h
   end
   if h > dmx.info.height then
      local scale = dmx.info.height/h
      w = scale * w
      h = scale * h
   end
   local x = (dmx.info.width-w)/2
   local y = (dmx.info.height-h)/2
   dmx.dest_rect = dispmanx.rect(x,y,w,h)
   print(string.format("dmx.dest_rect=%s", dmx.dest_rect))
   local u = dispmanx.update()
   dmx.element = dispmanx.element(
      u,                                 -- update
      dmx.dpy,                           -- display
      0,                                 -- layer
      dmx.dest_rect,                     -- dest_rect
      dmx.src,                           -- src
      dmx.src_rect,                      -- src_rect
      bcm_host.DISPMANX_PROTECTION_NONE, -- protection
      nil,                               -- alpha
      nil,                               -- clamp
      bcm_host.DISPMANX_NO_ROTATE)       -- transform
   u:submit_sync()
   print("waiting for input")
   util.getchar()
   local u = dispmanx.update()
   dmx.element:remove(u)
   u:submit_sync()
   dmx.src:delete()
   dmx.dpy:close()
end

bcm_host.wrap(main)()
