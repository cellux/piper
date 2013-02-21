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
   --dmx.dest_rect = ffi.new("VC_RECT_T", 0, 0, dmx.info.width, dmx.info.height)
   local w = bit.rshift(dmx.src_rect.width,16)
   local h = bit.rshift(dmx.src_rect.height,16)
   local x = (dmx.info.width-w)/2
   local y = (dmx.info.height-h)/2
   dmx.dest_rect = ffi.new("VC_RECT_T", x, y, w, h)
   print("vc_dispmanx_update_start()")
   local u = bcm_host.vc_dispmanx_update_start(0)
   print("vc_dispmanx_element_add()")
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
   print("vc_dispmanx_update_submit_sync()")
   bcm_host.vc_dispmanx_update_submit_sync(u)
   print("waiting for input")
   util.getchar()
   local u = bcm_host.vc_dispmanx_update_start(0)
   assert(u ~= bcm_host.DISPMANX_NO_HANDLE)
   local rv = bcm_host.vc_dispmanx_element_remove(u, dmx.element)
   assert(rv == 0)
   local rv = bcm_host.vc_dispmanx_update_submit_sync(u)
   assert(rv == 0)
   local rv = bcm_host.vc_dispmanx_resource_delete(dmx.src)
   assert(rv == 0)
   print("vc_dispmanx_display_close()")
   local rv = bcm_host.vc_dispmanx_display_close(dmx.dpy)
   assert(rv == 0)
end

bcm_host.wrap(main)()
