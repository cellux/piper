local image = require("image")

local ffi = require("ffi")
local bit = require("bit")
local bcm_host = require("bcm_host")
local util = require("util")

local function main()
   local dmx = {}
   dmx.dpy = bcm_host.vc_dispmanx_display_open(0)
   dmx.info = ffi.new("DISPMANX_MODEINFO_T")
   bcm_host.vc_dispmanx_display_get_info(dmx.dpy, dmx.info)
   dmx.src, dmx.src_rect = image.load('image-test.jpg', 'dispmanx_resource')
   print(string.format("dmx.src_rect=(%d,%d,%d,%d)",
                       dmx.src_rect.x,
                       dmx.src_rect.y,
                       dmx.src_rect.width,
                       dmx.src_rect.height))
   local w = dmx.src_rect.width
   if w > dmx.info.width then
      h = (dmx.info.width/w) * h
      w = dmx.info.width
   end
   local h = dmx.src_rect.height
   if h > dmx.info.height then
      w = (dmx.info.height/h) * w
      h = dmx.info.height
   end
   local x = (dmx.info.width-w)/2
   local y = (dmx.info.height-h)/2
   dmx.dest_rect = ffi.new("VC_RECT_T", x, y, w, h)
   print(string.format("dmx.dest_rect=(%d,%d,%d,%d)",
                       dmx.dest_rect.x,
                       dmx.dest_rect.y,
                       dmx.dest_rect.width,
                       dmx.dest_rect.height))
   local u = bcm_host.vc_dispmanx_update_start(0)
   dmx.element = bcm_host.vc_dispmanx_element_add(
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
   bcm_host.vc_dispmanx_update_submit_sync(u)
   print("waiting for input")
   util.getchar()
   local u = bcm_host.vc_dispmanx_update_start(0)
   bcm_host.vc_dispmanx_element_remove(u, dmx.element)
   bcm_host.vc_dispmanx_update_submit_sync(u)
   bcm_host.vc_dispmanx_resource_delete(dmx.src)
   bcm_host.vc_dispmanx_display_close(dmx.dpy)
end

bcm_host.wrap(main)()
