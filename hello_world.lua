#!/usr/bin/luajit

local ffi = require("ffi")
local bit = require("bit")
local bcm_host = require("bcm_host")
local egl = require("egl")
local vg = require("vg")
local util = require("util")

function main(dpy)
   egl.bindAPI(egl.EGL_OPENVG_API)
   assert(egl.queryAPI() == egl.EGL_OPENVG_API)
   print("bound OpenVG_API")

   for _,n in ipairs({"VENDOR","VERSION","EXTENSIONS","CLIENT_APIS"}) do
      print(n.."="..egl.queryString(dpy, egl["EGL_"..n]))
   end

   for id,config in pairs(egl.getConfigs(dpy)) do
      io.write("config #"..id..":")
      io.write(tostring(config))
      io.write("\n")
   end

   local limits = {
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
   local config = egl.chooseConfig(dpy, limits);
   print("result of chooseConfig:")
   print(config)

   local ctx = egl.createContext(dpy, config)
   print("created EGL context (OpenVG)")
   print(ctx)

   local dmx = {}
   dmx.dpy = bcm_host.vc_dispmanx_display_open(0)
   assert(dmx.dpy ~= bcm_host.DISPMANX_NO_HANDLE, "vc_dispmanx_display_open() failed")
   dmx.info = ffi.new("DISPMANX_MODEINFO_T")
   local rv = bcm_host.vc_dispmanx_display_get_info(dmx.dpy, dmx.info)
   assert(rv==0, "vc_dispmanx_display_get_info() failed")
   print(string.format("(dispmanx) display width=%d", dmx.info.width))
   print(string.format("(dispmanx) display height=%d", dmx.info.height))
   local u = bcm_host.vc_dispmanx_update_start(0)
   assert(u ~= bcm_host.DISPMANX_NO_HANDLE, "vc_dispmanx_update_start() failed")
   dmx.src_rect = ffi.new("VC_RECT_T")
   bcm_host.vc_dispmanx_rect_set(dmx.src_rect,
                                 0,
                                 0,
                                 bit.lshift(dmx.info.width,16),
                                 bit.lshift(dmx.info.height,16))
   print(string.format("src_rect: %d,%d,%d,%d",
                       dmx.src_rect.x,
                       dmx.src_rect.y,
                       dmx.src_rect.width,
                       dmx.src_rect.height))
   dmx.dest_rect = ffi.new("VC_RECT_T")
   bcm_host.vc_dispmanx_rect_set(dmx.dest_rect,
                                 0,
                                 0,
                                 dmx.info.width,
                                 dmx.info.height)
   print(string.format("dest_rect: %d,%d,%d,%d",
                       dmx.dest_rect.x,
                       dmx.dest_rect.y,
                       dmx.dest_rect.width,
                       dmx.dest_rect.height))
   local alpha = ffi.new("VC_DISPMANX_ALPHA_T",
                         bcm_host.DISPMANX_FLAGS_ALPHA_FIXED_ALL_PIXELS, 0xff, 0)
   dmx.element = bcm_host.vc_dispmanx_element_add(
      u,                                 -- update
      dmx.dpy,                           -- display
      0,                                 -- layer
      dmx.dest_rect,                     -- dest_rect
      0,                                 -- src
      dmx.src_rect,                      -- src_rect
      bcm_host.DISPMANX_PROTECTION_NONE, -- protection
      alpha,                             -- alpha
      nil,                               -- clamp
      bcm_host.DISPMANX_NO_ROTATE)       -- transform
   assert(dmx.element ~= bcm_host.DISPMANX_NO_HANDLE, "vc_dispmanx_element_add() failed")
   print("dispmanx.element = ",dmx.element)
   dmx.egl_window = ffi.new("EGL_DISPMANX_WINDOW_T", 
                                 dmx.element,
                                 dmx.info.width,
                                 dmx.info.height)
   print(string.format("dmx.egl_window = %d/%d/%d",
                       dmx.egl_window.element,
                       dmx.egl_window.width,
                       dmx.egl_window.height))
   local rv = bcm_host.vc_dispmanx_update_submit_sync(u)
   assert(rv==0, "vc_dispmanx_update_submit_sync() failed")

   local s = egl.createWindowSurface(dpy,
                                     config,
                                     dmx.egl_window)
   print("created EGL surface")
   print(s)
   assert(s.RENDER_BUFFER == egl.EGL_BACK_BUFFER)

   --[[
   egl.bindAPI(egl.EGL_OPENGL_ES_API)
   assert(egl.queryAPI() == egl.EGL_OPENGL_ES_API)
   print("bound OpenGL_ES_API")
   local ctx = egl.createContext(dpy, config)
   print("created EGL context (OpenGL_ES)")
   print(ctx)
   egl.makeCurrent(dpy, s, s, ctx)
   print("EGL context (OpenGL_ES) made current")
   print(ctx)
   assert(egl.getCurrentDisplay()==dpy)
   assert(egl.getCurrentContext(dpy)==ctx)
   assert(egl.getCurrentSurface(dpy, egl.EGL_DRAW)==s)
   assert(egl.getCurrentSurface(dpy, egl.EGL_READ)==s)
   egl.destroyContext(dpy, ctx)
   print("destroyed EGL context (OpenGL_ES)")
   ]]--

   egl.makeCurrent(dpy, s, s, ctx)
   print("EGL context (OpenVG) made current")
   print(ctx)
   --[[
   for _,n in ipairs({"VENDOR","RENDERER","VERSION","EXTENSIONS"}) do
      local i = vg["VG_"..n]
      local s = vg.vgGetString(i)
      -- for some reason, we get NULLs here
   end
   ]]--
   vg.vgSeti(vg.VG_SCISSORING, vg.VG_FALSE)
   vg.vgSeti(vg.VG_MASKING, vg.VG_FALSE)
   local clearColor = ffi.new("VGfloat[4]", 0.33,0,0,1)
   vg.vgSetfv(vg.VG_CLEAR_COLOR, 4, clearColor)
   vg.vgClear(0,0,dmx.info.width,dmx.info.height)
   local paint = vg.vgCreatePaint()
   assert(vg.vgGetError()==vg.VG_NO_ERROR,"vgCreatePaint() failed")
   vg.vgSetParameteri(paint, vg.VG_PAINT_TYPE, vg.VG_PAINT_TYPE_COLOR)
   assert(vg.vgGetError()==vg.VG_NO_ERROR,"vgSetParameteri() failed")
   local color = ffi.new("VGfloat[4]",1,1,1,1)
   vg.vgSetParameterfv(paint, vg.VG_PAINT_COLOR, 4, color)
   assert(vg.vgGetColor(paint) == 0xffffffff)
   assert(vg.vgGetError()==vg.VG_NO_ERROR,"vgSetParameterfv() failed")
   vg.vgSetPaint(paint, vg.VG_STROKE_PATH)
   assert(vg.vgGetError()==vg.VG_NO_ERROR,"vgSetPaint() failed")
   assert(vg.vgGetPaint(vg.VG_STROKE_PATH) == paint)
   print("ffi.sizeof(VGfloat)=",ffi.sizeof("VGfloat"))
   print("ffi.sizeof(VGint)=",ffi.sizeof("VGint"))
   print("ffi.sizeof(VGPathDatatype)=",ffi.sizeof("VGPathDatatype"))
   print("ffi.sizeof(VGbitfield)=",ffi.sizeof("VGbitfield"))
   local flt = ffi.new("VGfloat[1]")
   flt[0] = 1234.125
   assert(flt[0] == 1234.125)
   local path = vg.vgCreatePath(vg.VG_PATH_FORMAT_STANDARD,
                                vg.VG_PATH_DATATYPE_F,
                                1.0, 0.0,
                                8, 9,
                                vg.VG_PATH_CAPABILITY_ALL)
   if path == vg.VG_INVALID_HANDLE then
      local error_code = vg.vgGetError()
      error("vgCreatePath() failed:"..vg.error_string(error_code))
   end
   assert(vg.vgGetParameteri(path, vg.VG_PATH_FORMAT) == vg.VG_PATH_FORMAT_STANDARD)
   assert(vg.vgGetParameteri(path, vg.VG_PATH_DATATYPE) == vg.VG_PATH_DATATYPE_F)
   assert(vg.vgGetParameterf(path, vg.VG_PATH_SCALE) == 1.0, "VG_PATH_SCALE="..tonumber(vg.vgGetParameterf(path, vg.VG_PATH_SCALE)))
   assert(vg.vgGetParameterf(path, vg.VG_PATH_BIAS) == 0.0)
   assert(vg.vgGetPathCapabilities(path)==vg.VG_PATH_CAPABILITY_ALL)
   local num_segments = 2
   local path_segments = ffi.new("VGubyte[?]", num_segments)
   path_segments[0] = vg.VG_MOVE_TO_ABS
   path_segments[1] = vg.VG_LINE_TO_ABS
   local path_data = ffi.new("VGfloat[?]", 4)
   path_data[0] = 0
   path_data[1] = 0
   path_data[2] = dmx.info.width
   path_data[3] = dmx.info.height
   vg.vgAppendPathData(path, num_segments, path_segments, path_data)
   assert(vg.vgGetError()==vg.VG_NO_ERROR,"vgAppendPathData() failed")
   vg.vgSetf(vg.VG_STROKE_LINE_WIDTH, 10)
   assert(vg.vgGetError()==vg.VG_NO_ERROR,"vgSetf() failed")
   vg.vgSeti(vg.VG_STROKE_CAP_STYLE, vg.VG_CAP_ROUND)
   assert(vg.vgGetError()==vg.VG_NO_ERROR,"vgSeti() failed")
   vg.vgSetfv(vg.VG_STROKE_DASH_PATTERN, 0, nil)
   assert(vg.vgGetError()==vg.VG_NO_ERROR,"vgSetfv() failed")
   vg.vgSeti(vg.VG_MATRIX_MODE, vg.VG_MATRIX_PATH_USER_TO_SURFACE)
   vg.vgLoadIdentity()
   vg.vgSeti(vg.VG_MATRIX_MODE, vg.VG_MATRIX_FILL_PAINT_TO_USER)
   vg.vgLoadIdentity()
   vg.vgSeti(vg.VG_MATRIX_MODE, vg.VG_MATRIX_STROKE_PAINT_TO_USER)
   vg.vgLoadIdentity()
   vg.vgDrawPath(path, vg.VG_STROKE_PATH)
   assert(vg.vgGetError() == vg.VG_NO_ERROR, "vgDrawPath() failed")
   vg.vgSetColor(paint, 0x000000ff)
   vg.vgSetf(vg.VG_STROKE_LINE_WIDTH, 1)
   vg.vgClearPath(path, vg.VG_PATH_CAPABILITY_ALL)
   local unit = 32
   local cx = dmx.info.width/2
   local cy = dmx.info.height/2
   local steps = math.floor(cy/unit)
   for i=1,steps do
      vg.vguLine(path, cx, cy+((steps-i)*unit), cx+((i-1)*unit), cy)
      vg.vguLine(path, cx, cy-((steps-i)*unit), cx+((i-1)*unit), cy)
      vg.vguLine(path, cx, cy+((steps-i)*unit), cx-((i-1)*unit), cy)
      vg.vguLine(path, cx, cy-((steps-i)*unit), cx-((i-1)*unit), cy)
   end
   vg.vgDrawPath(path, vg.VG_STROKE_PATH)
   --vg.vgFinish()
   local rv = egl.swapBuffers(dpy, s)
   assert(rv ~= egl.EGL_FALSE, "eglSwapBuffers() failed: "..string.format('0x%x', egl.eglGetError()))
   --util.sleep(10)
   vg.vgDestroyPaint(paint)
   vg.vgDestroyPath(path)
   egl.destroyContext(dpy, ctx)
   print("destroyed EGL (OpenVG) context")
   egl.destroySurface(dpy, s)
   print("destroyed EGL surface")
   bcm_host.vc_dispmanx_display_close(dmx.dpy)
end

bcm_host.wrap(egl.wrap(main))()
