local ffi = require("ffi")
local bit = require("bit")
local bcm_host = require("bcm_host")

local lib_bcm_host = require("lib.bcm_host")
local dispmanx = {}

local VC_RECT_T_mt = {
   __index = {
      set = lib_bcm_host.vc_dispmanx_rect_set,
   },
   __tostring = function(rect)
      return string.format("(%d,%d,%d,%d)",
                           rect.x,
                           rect.y,
                           rect.width,
                           rect.height)
   end,
}
ffi.metatype("VC_RECT_T", VC_RECT_T_mt)
dispmanx.rect = ffi.typeof("VC_RECT_T")

local VC_IMAGE_TYPE_T_map = {
   [tonumber(lib_bcm_host.VC_IMAGE_RGB565)]        = "RGB565",
   [tonumber(lib_bcm_host.VC_IMAGE_1BPP)]          = "1BPP",
   [tonumber(lib_bcm_host.VC_IMAGE_YUV420)]        = "YUV420",
   [tonumber(lib_bcm_host.VC_IMAGE_48BPP)]         = "48BPP",
   [tonumber(lib_bcm_host.VC_IMAGE_RGB888)]        = "RGB888",
   [tonumber(lib_bcm_host.VC_IMAGE_8BPP)]          = "8BPP",
   [tonumber(lib_bcm_host.VC_IMAGE_4BPP)]          = "4BPP",
   [tonumber(lib_bcm_host.VC_IMAGE_3D32)]          = "3D32",
   [tonumber(lib_bcm_host.VC_IMAGE_3D32B)]         = "3D32B",
   [tonumber(lib_bcm_host.VC_IMAGE_3D32MAT)]       = "3D32MAT",
   [tonumber(lib_bcm_host.VC_IMAGE_RGB2X9)]        = "RGB2X9",
   [tonumber(lib_bcm_host.VC_IMAGE_RGB666)]        = "RGB666",
   [tonumber(lib_bcm_host.VC_IMAGE_PAL4_OBSOLETE)] = "PAL4_OBSOLETE",
   [tonumber(lib_bcm_host.VC_IMAGE_PAL8_OBSOLETE)] = "PAL8_OBSOLETE",
   [tonumber(lib_bcm_host.VC_IMAGE_RGBA32)]        = "RGBA32",
   [tonumber(lib_bcm_host.VC_IMAGE_YUV422)]        = "YUV422",
   [tonumber(lib_bcm_host.VC_IMAGE_RGBA565)]       = "RGBA565",
   [tonumber(lib_bcm_host.VC_IMAGE_RGBA16)]        = "RGBA16",
   [tonumber(lib_bcm_host.VC_IMAGE_YUV_UV)]        = "YUV_UV",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_RGBA32)]     = "TF_RGBA32",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_RGBX32)]     = "TF_RGBX32",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_FLOAT)]      = "TF_FLOAT",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_RGBA16)]     = "TF_RGBA16",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_RGBA5551)]   = "TF_RGBA5551",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_RGB565)]     = "TF_RGB565",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_YA88)]       = "TF_YA88",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_BYTE)]       = "TF_BYTE",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_PAL8)]       = "TF_PAL8",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_PAL4)]       = "TF_PAL4",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_ETC1)]       = "TF_ETC1",
   [tonumber(lib_bcm_host.VC_IMAGE_BGR888)]        = "BGR888",
   [tonumber(lib_bcm_host.VC_IMAGE_BGR888_NP)]     = "BGR888_NP",
   [tonumber(lib_bcm_host.VC_IMAGE_BAYER)]         = "BAYER",
   [tonumber(lib_bcm_host.VC_IMAGE_CODEC)]         = "CODEC",
   [tonumber(lib_bcm_host.VC_IMAGE_YUV_UV32)]      = "YUV_UV32",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_Y8)]         = "TF_Y8",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_A8)]         = "TF_A8",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_SHORT)]      = "TF_SHORT",
   [tonumber(lib_bcm_host.VC_IMAGE_TF_1BPP)]       = "TF_1BPP",
   [tonumber(lib_bcm_host.VC_IMAGE_OPENGL)]        = "OPENGL",
   [tonumber(lib_bcm_host.VC_IMAGE_YUV444I)]       = "YUV444I",
   [tonumber(lib_bcm_host.VC_IMAGE_YUV422PLANAR)]  = "YUV422PLANAR",
   [tonumber(lib_bcm_host.VC_IMAGE_ARGB8888)]      = "ARGB8888",
   [tonumber(lib_bcm_host.VC_IMAGE_XRGB8888)]      = "XRGB8888",
   [tonumber(lib_bcm_host.VC_IMAGE_YUV422YUYV)]    = "YUV422YUYV",
   [tonumber(lib_bcm_host.VC_IMAGE_YUV422YVYU)]    = "YUV422YVYU",
   [tonumber(lib_bcm_host.VC_IMAGE_YUV422UYVY)]    = "YUV422UYVY",
   [tonumber(lib_bcm_host.VC_IMAGE_YUV422VYUY)]    = "YUV422VYUY",
   [tonumber(lib_bcm_host.VC_IMAGE_RGBX32)]        = "RGBX32",
   [tonumber(lib_bcm_host.VC_IMAGE_RGBX8888)]      = "RGBX8888",
   [tonumber(lib_bcm_host.VC_IMAGE_BGRX8888)]      = "BGRX8888",
   [tonumber(lib_bcm_host.VC_IMAGE_YUV420SP)]      = "YUV420SP",
   [tonumber(lib_bcm_host.VC_IMAGE_YUV444PLANAR)]  = "YUV444PLANAR",
}

local function VC_IMAGE_TYPE_T_str(t)
   return VC_IMAGE_TYPE_T_map[t] or '?'
end

local VC_IMAGE_TRANSFORM_T_map = {
   [tonumber(lib_bcm_host.VC_IMAGE_ROT0)]          = "ROT0",
   [tonumber(lib_bcm_host.VC_IMAGE_MIRROR_ROT0)]   = "MIRROR_ROT0",
   [tonumber(lib_bcm_host.VC_IMAGE_MIRROR_ROT180)] = "MIRROR_ROT180",
   [tonumber(lib_bcm_host.VC_IMAGE_ROT180)]        = "ROT180",
   [tonumber(lib_bcm_host.VC_IMAGE_MIRROR_ROT90)]  = "MIRROR_ROT90",
   [tonumber(lib_bcm_host.VC_IMAGE_ROT270)]        = "ROT270",
   [tonumber(lib_bcm_host.VC_IMAGE_ROT90)]         = "ROT90",
   [tonumber(lib_bcm_host.VC_IMAGE_MIRROR_ROT270)] = "MIRROR_ROT270",
}

local function VC_IMAGE_TRANSFORM_T_str(t)
   return VC_IMAGE_TRANSFORM_T_map[t] or '?'
end

local DISPMANX_TRANSFORM_T_map = {
   [tonumber(lib_bcm_host.DISPMANX_NO_ROTATE)]  = "NO_ROTATE",
   [tonumber(lib_bcm_host.DISPMANX_ROTATE_90)]  = "ROTATE_90",
   [tonumber(lib_bcm_host.DISPMANX_ROTATE_180)] = "ROTATE_180",
   [tonumber(lib_bcm_host.DISPMANX_ROTATE_270)] = "ROTATE_270",
}

local function DISPMANX_TRANSFORM_T_str(t)
   t = tonumber(t)
   local s = DISPMANX_TRANSFORM_T_map[bit.band(t,3)] or '?'
   if bit.band(t,lib_bcm_host.DISPMANX_FLIP_HRIZ) ~= 0 then
      s = s.."+FLIP_HRIZ"
   end
   if bit.band(t,lib_bcm_host.DISPMANX_FLIP_VERT) ~= 0 then
      s = s.."+FLIP_VERT"
   end
   return s
end

local DISPMANX_FLAGS_ALPHA_T_map = {
   [tonumber(lib_bcm_host.DISPMANX_FLAGS_ALPHA_FROM_SOURCE)] = "FROM_SOURCE",
   [tonumber(lib_bcm_host.DISPMANX_FLAGS_ALPHA_FIXED_ALL_PIXELS)] = "FIXED_ALL_PIXELS",
   [tonumber(lib_bcm_host.DISPMANX_FLAGS_ALPHA_FIXED_NON_ZERO)] = "FIXED_NON_ZERO",
   [tonumber(lib_bcm_host.DISPMANX_FLAGS_ALPHA_FIXED_EXCEED_0X07)] = "FIXED_EXCEED_0X07",
}

local function DISPMANX_FLAGS_ALPHA_T_str(a)
   a = tonumber(a)
   local s = DISPMANX_FLAGS_ALPHA_T_map[bit.band(a,3)] or '?'
   if bit.band(a,lib_bcm_host.DISPMANX_FLAGS_ALPHA_PREMULT) ~= 0 then
      s = s.."+PREMULT"
   end
   if bit.band(a,lib_bcm_host.DISPMANX_FLAGS_ALPHA_MIX) ~= 0 then
      s = s.."+MIX"
   end
   return s
end

local VC_DISPMANX_ALPHA_T_mt = {
   __tostring = function(a)
      return string.format("alpha(flags=%s,opacity=0x%x,mask=0x%x)",
                           DISPMANX_FLAGS_ALPHA_T_str(a.flags),
                           a.opacity,
                           tonumber(a.mask))
   end,
}
ffi.metatype("VC_DISPMANX_ALPHA_T", VC_DISPMANX_ALPHA_T_mt)
dispmanx.alpha = ffi.typeof("VC_DISPMANX_ALPHA_T")

local DISPMANX_MODEINFO_T_mt = {
   __tostring = function(info)
      return string.format("mode(width=%d,height=%d,transform=%s,input_format=?)",
                           info.width,
                           info.height,
                           DISPMANX_TRANSFORM_T_str(info.transform))
   end,
}
ffi.metatype("DISPMANX_MODEINFO_T", DISPMANX_MODEINFO_T_mt)

ffi.cdef [[
typedef struct {
  DISPMANX_RESOURCE_HANDLE_T res;
  uint32_t width;
  uint32_t height;
} piper_dispmanx_resource;
]]

local piper_dispmanx_resource_mt = {
   __new = function(ct, type, width, height)
      local native_image_handle = ffi.new("uint32_t[1]")
      local res = lib_bcm_host.vc_dispmanx_resource_create(type,
                                                           width,
                                                           height,
                                                           native_image_handle)
      return res == lib_bcm_host.DISPMANX_NO_HANDLE and nil
         or ffi.new("piper_dispmanx_resource", res, width, height)
   end,
   __index = {
      write_data = function(self, ...)
         return lib_bcm_host.vc_dispmanx_resource_write_data(self.res, ...)
      end,
      read_data = function(self, ...)
         return lib_bcm_host.vc_dispmanx_resource_read_data(self.res, ...)
      end,
      delete = function(self, ...)
         return lib_bcm_host.vc_dispmanx_resource_delete(self.res)
      end,
   },
   __tostring = function(self)
      return string.format("resource(0x%x,%d,%d)",
                           tonumber(self.res),
                           self.width,
                           self.height)
   end,
}
ffi.metatype("piper_dispmanx_resource", piper_dispmanx_resource_mt)
dispmanx.resource = ffi.typeof("piper_dispmanx_resource")

ffi.cdef [[
typedef struct {
  DISPMANX_DISPLAY_HANDLE_T dpy;
} piper_dispmanx_display;
]]

local piper_dispmanx_display_mt = {
   __new = function(ct, device)
      device = device or 0
      local dpy = lib_bcm_host.vc_dispmanx_display_open(device)
      return dpy == lib_bcm_host.DISPMANX_NO_HANDLE and nil
         or ffi.new("piper_dispmanx_display", dpy)
   end,
   __index = {
      set_background = function(self, update, red, green, blue)
         return lib_bcm_host.vc_dispmanx_display_set_background(update.u,
                                                                self.dpy,
                                                                red,
                                                                green,
                                                                blue)
      end,
      get_info = function(self)
         local info = ffi.new("DISPMANX_MODEINFO_T")
         lib_bcm_host.vc_dispmanx_display_get_info(self.dpy, info)
         return info
      end,
      close = function(self)
         return lib_bcm_host.vc_dispmanx_display_close(self.dpy)
      end,
   },
   __tostring = function(self)
      return string.format("display(0x%x)", tonumber(self.dpy))
   end,
}
ffi.metatype("piper_dispmanx_display", piper_dispmanx_display_mt)
dispmanx.display = ffi.typeof("piper_dispmanx_display")

ffi.cdef [[
typedef struct {
  DISPMANX_UPDATE_HANDLE_T u;
} piper_dispmanx_update;
]]

local piper_dispmanx_update_mt = {
   __new = function(ct, priority)
      priority = priority or 0
      local u = lib_bcm_host.vc_dispmanx_update_start(priority)
      return u == lib_bcm_host.DISPMANX_NO_HANDLE and nil
         or ffi.new("piper_dispmanx_update", u)
   end,
   __index = {
      submit = function(self)
         return lib_bcm_host.vc_dispmanx_update_submit(self.u)
      end,
      submit_sync = function(self)
         return lib_bcm_host.vc_dispmanx_update_submit_sync(self.u)
      end,
   },
}
ffi.metatype("piper_dispmanx_update", piper_dispmanx_update_mt)
dispmanx.update = ffi.typeof("piper_dispmanx_update")

ffi.cdef [[
typedef struct {
  DISPMANX_ELEMENT_HANDLE_T e;
} piper_dispmanx_element;
]]
local piper_dispmanx_element_mt = {
   __new = function(ct,u,d,l,dr,s,sr,p,a,c,t)
      -- if source rect's width and height are in the lower 16 bits of the uint32_t,
      -- shift them up to the higher 16 bits as vc_dispmanx_element_add requires that
      local sr_shifted = ffi.new("VC_RECT_T", sr)
      if bit.band(sr_shifted.width,0xffff) ~= 0 then
         sr_shifted.width = bit.lshift(sr_shifted.width, 16)
         sr_shifted.height = bit.lshift(sr_shifted.height, 16)
      end
      local s_ = s == 0 and 0 or s.res
      local e = lib_bcm_host.vc_dispmanx_element_add(u.u,d.dpy,l,dr,s_,sr_shifted,p,a,c,t)
      return e == lib_bcm_host.DISPMANX_NO_HANDLE and nil
         or ffi.new("piper_dispmanx_element", e)
   end,
   __index = {
      change_source = function(self, update, src)
         return lib_bcm_host.vc_dispmanx_element_change_source(update.u, self.e, src.res)
      end,
      change_layer = function(self, update, layer)
         return lib_bcm_host.vc_dispmanx_element_change_layer(update.u, self.e, layer)
      end,
      modified = function(self, update, rect)
         return lib_bcm_host.vc_dispmanx_element_modified(update.u, self.e, rect)
      end,
      remove = function(self, update)
         return lib_bcm_host.vc_dispmanx_element_remove(update.u, self.e)
      end,
      change_attributes = function(self,u,cf,l,o,dr,sr,m,t)
         return lib_bcm_host.vc_dispmanx_element_change_attributes(u.u, self.e, cf, l, o, dr, sr, m == 0 and 0 or m.res, t)
      end,
   },
   __tostring = function(self)
      return string.format("element(0x%x)", self.e)
   end,
}
ffi.metatype("piper_dispmanx_element", piper_dispmanx_element_mt)
dispmanx.element = ffi.typeof("piper_dispmanx_element")

return dispmanx
