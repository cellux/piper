local ffi = require("ffi")

local bcm_host = require("bcm_host")
local egl = require("egl")
local vg = require("vg")
local uv = require("uv")

local egl_config_limits = {
   BUFFER_SIZE = 32,
   RED_SIZE = 8,
   GREEN_SIZE = 8,
   BLUE_SIZE = 8,
   ALPHA_SIZE = 8,
   SURFACE_TYPE = bit.bor(egl.EGL_WINDOW_BIT,
                          egl.EGL_PBUFFER_BIT),
   BIND_TO_TEXTURE_RGBA = egl.EGL_TRUE,
   RENDERABLE_TYPE = bit.bor(egl.EGL_OPENGL_ES2_BIT,
                             egl.EGL_OPENVG_BIT),
}

local egl_display
local egl_config
local gl_context, vg_context
local dmx = {}
local egl_surface

local video_callback = function() end
local audio_callback = function() end

local running = true

local function main(dpy)
   egl_display = dpy
   egl_config = egl.chooseConfig(dpy, egl_config_limits)

   egl.bindAPI(egl.EGL_OPENGL_ES_API)
   gl_context = egl.createContext(dpy, egl_config)
   egl.bindAPI(egl.EGL_OPENVG_API)
   vg_context = egl.createContext(dpy, egl_config)

   dmx.dpy = bcm_host.vc_dispmanx_display_open(0)
   assert(dmx.dpy ~= bcm_host.DISPMANX_NO_HANDLE, "vc_dispmanx_display_open() failed")

   dmx.info = ffi.new("DISPMANX_MODEINFO_T")
   local rv = bcm_host.vc_dispmanx_display_get_info(dmx.dpy, dmx.info)
   assert(rv==0, "vc_dispmanx_display_get_info() failed")

   local u = bcm_host.vc_dispmanx_update_start(0)
   assert(u ~= bcm_host.DISPMANX_NO_HANDLE, "vc_dispmanx_update_start() failed")

   dmx.src_rect = ffi.new("VC_RECT_T")
   bcm_host.vc_dispmanx_rect_set(dmx.src_rect,
                                 0,
                                 0,
                                 dmx.info.width,
                                 dmx.info.height)
   dmx.dest_rect = dmx.src_rect

   dmx.element = bcm_host.vc_dispmanx_element_add(
      u,                                 -- update
      dmx.dpy,                           -- display
      0,                                 -- layer
      dmx.dest_rect,                     -- dest_rect
      0,                                 -- src
      dmx.src_rect,                      -- src_rect
      bcm_host.DISPMANX_PROTECTION_NONE, -- protection
      nil,                               -- alpha
      nil,                               -- clamp
      bcm_host.DISPMANX_NO_ROTATE)       -- transform
   assert(dmx.element ~= bcm_host.DISPMANX_NO_HANDLE, "vc_dispmanx_element_add() failed")

   local rv = bcm_host.vc_dispmanx_update_submit_sync(u)
   assert(rv==0, "vc_dispmanx_update_submit_sync() failed")

   dmx.egl_window = ffi.new("EGL_DISPMANX_WINDOW_T", 
                            dmx.element,
                            dmx.info.width,
                            dmx.info.height)

   egl_surface = egl.createWindowSurface(dpy,
                                         egl_config,
                                         dmx.egl_window)

   egl.bindAPI(egl.EGL_OPENGL_ES_API)
   egl.makeCurrent(dpy, egl_surface, egl_surface, gl_context)
   egl.bindAPI(egl.EGL_OPENVG_API)
   egl.makeCurrent(dpy, egl_surface, egl_surface, vg_context)
   vg.vgSetfv(vg.VG_CLEAR_COLOR, 4, ffi.new("VGfloat[4]", 0,0,0,1))
   vg.vgClear(0,0,dmx.info.width,dmx.info.height)
   egl.swapBuffers(egl_display, egl_surface)

   print("entering avloop")
   while running do
      video_callback()
      audio_callback()
      uv.run_nowait()
      uv.resume()
      egl.swapBuffers(egl_display, egl_surface)
   end
   print("leaving avloop")

   egl.destroySurface(dpy, egl_surface)
   egl.destroyContext(dpy, gl_context)
   egl.destroyContext(dpy, vg_context)

   local u = bcm_host.vc_dispmanx_update_start(0)
   assert(u ~= bcm_host.DISPMANX_NO_HANDLE)
   local rv = bcm_host.vc_dispmanx_element_remove(u, dmx.element)
   assert(rv == 0)
   local rv = bcm_host.vc_dispmanx_update_submit_sync(u)
   assert(rv == 0)

   bcm_host.vc_dispmanx_display_close(dmx.dpy)
end

local avloop = {}

function avloop.start()
   running = true
   uv.watch('signal',
            function() running = false end,
            { signum = uv.SIGINT })
   bcm_host.wrap(egl.wrap(main))()
end

function avloop.stop()
   running = false
end

function avloop.set_video_callback(cb)
   video_callback = cb
end

function avloop.set_audio_callback(cb)
   audio_callback = cb
end

return avloop
