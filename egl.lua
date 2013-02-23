require("rpilibs")
require("bcm_host") -- for EGL_DISPMANX_WINDOW_T

local ffi = require("ffi")
local bit = require("bit")

ffi.cdef [[
typedef unsigned int EGLBoolean;
typedef unsigned int EGLenum;
typedef int32_t EGLint;

typedef void *EGLConfig;
typedef void *EGLContext;
typedef void *EGLDisplay;
typedef void *EGLSurface;
typedef void *EGLClientBuffer;

typedef void *EGLNativeDisplayType;
typedef void *EGLNativePixmapType;
typedef EGL_DISPMANX_WINDOW_T *EGLNativeWindowType;

EGLint eglGetError(void);

EGLDisplay eglGetDisplay(EGLNativeDisplayType display_id);
EGLBoolean eglInitialize(EGLDisplay dpy, EGLint *major, EGLint *minor);
EGLBoolean eglTerminate(EGLDisplay dpy);
const char * eglQueryString(EGLDisplay dpy, EGLint name);

EGLBoolean eglGetConfigs(EGLDisplay dpy, EGLConfig *configs, EGLint config_size, EGLint *num_config);
EGLBoolean eglChooseConfig(EGLDisplay dpy, const EGLint *attrib_list, EGLConfig *configs, EGLint config_size, EGLint *num_config);
EGLBoolean eglGetConfigAttrib(EGLDisplay dpy, EGLConfig config, EGLint attribute, EGLint *value);

EGLSurface eglCreateWindowSurface(EGLDisplay dpy, EGLConfig config, EGLNativeWindowType win, const EGLint *attrib_list);
EGLSurface eglCreatePbufferSurface(EGLDisplay dpy, EGLConfig config, const EGLint *attrib_list);
EGLSurface eglCreatePixmapSurface(EGLDisplay dpy, EGLConfig config, EGLNativePixmapType pixmap, const EGLint *attrib_list);
EGLBoolean eglDestroySurface(EGLDisplay dpy, EGLSurface surface);
EGLBoolean eglQuerySurface(EGLDisplay dpy, EGLSurface surface, EGLint attribute, EGLint *value);

EGLBoolean eglBindAPI(EGLenum api);
EGLenum eglQueryAPI(void);

EGLBoolean eglWaitClient(void);
EGLBoolean eglReleaseThread(void);
EGLSurface eglCreatePbufferFromClientBuffer(EGLDisplay dpy, EGLenum buftype, EGLClientBuffer buffer, EGLConfig config, const EGLint *attrib_list);
EGLBoolean eglSurfaceAttrib(EGLDisplay dpy, EGLSurface surface, EGLint attribute, EGLint value);
EGLBoolean eglBindTexImage(EGLDisplay dpy, EGLSurface surface, EGLint buffer);
EGLBoolean eglReleaseTexImage(EGLDisplay dpy, EGLSurface surface, EGLint buffer);
EGLBoolean eglSwapInterval(EGLDisplay dpy, EGLint interval);
EGLContext eglCreateContext(EGLDisplay dpy, EGLConfig config, EGLContext share_context, const EGLint *attrib_list);
EGLBoolean eglDestroyContext(EGLDisplay dpy, EGLContext ctx);
EGLBoolean eglMakeCurrent(EGLDisplay dpy, EGLSurface draw, EGLSurface read, EGLContext ctx);
EGLContext eglGetCurrentContext(void);
EGLSurface eglGetCurrentSurface(EGLint readdraw);
EGLDisplay eglGetCurrentDisplay(void);
EGLBoolean eglQueryContext(EGLDisplay dpy, EGLContext ctx, EGLint attribute, EGLint *value);
EGLBoolean eglWaitGL(void);
EGLBoolean eglWaitNative(EGLint engine);
EGLBoolean eglSwapBuffers(EGLDisplay dpy, EGLSurface surface);
EGLBoolean eglCopyBuffers(EGLDisplay dpy, EGLSurface surface, EGLNativePixmapType target);

/* EGL aliases */
static const int EGL_FALSE = 0;
static const int EGL_TRUE  = 1;

/* Out-of-band handle values */

/* LuaJIT allows only integer static const ints
   so just use nil */

/*
 * static const void* EGL_DEFAULT_DISPLAY = NULL;
 * static const void* EGL_NO_CONTEXT      = NULL;
 * static const void* EGL_NO_DISPLAY      = NULL;
 * static const void* EGL_NO_SURFACE      = NULL;
 */

/* Out-of-band attribute value */
static const int EGL_DONT_CARE = -1;

/* Errors / GetError return values */
static const int EGL_SUCCESS             = 0x3000;
static const int EGL_NOT_INITIALIZED     = 0x3001;
static const int EGL_BAD_ACCESS          = 0x3002;
static const int EGL_BAD_ALLOC           = 0x3003;
static const int EGL_BAD_ATTRIBUTE       = 0x3004;
static const int EGL_BAD_CONFIG          = 0x3005;
static const int EGL_BAD_CONTEXT         = 0x3006;
static const int EGL_BAD_CURRENT_SURFACE = 0x3007;
static const int EGL_BAD_DISPLAY         = 0x3008;
static const int EGL_BAD_MATCH           = 0x3009;
static const int EGL_BAD_NATIVE_PIXMAP   = 0x300A;
static const int EGL_BAD_NATIVE_WINDOW   = 0x300B;
static const int EGL_BAD_PARAMETER       = 0x300C;
static const int EGL_BAD_SURFACE         = 0x300D;
static const int EGL_CONTEXT_LOST        = 0x300E;

/* Config attributes */
static const int EGL_BUFFER_SIZE             = 0x3020;
static const int EGL_ALPHA_SIZE              = 0x3021;
static const int EGL_BLUE_SIZE               = 0x3022;
static const int EGL_GREEN_SIZE              = 0x3023;
static const int EGL_RED_SIZE                = 0x3024;
static const int EGL_DEPTH_SIZE              = 0x3025;
static const int EGL_STENCIL_SIZE            = 0x3026;
static const int EGL_CONFIG_CAVEAT           = 0x3027;
static const int EGL_CONFIG_ID               = 0x3028;
static const int EGL_LEVEL                   = 0x3029;
static const int EGL_MAX_PBUFFER_HEIGHT      = 0x302A;
static const int EGL_MAX_PBUFFER_PIXELS      = 0x302B;
static const int EGL_MAX_PBUFFER_WIDTH       = 0x302C;
static const int EGL_NATIVE_RENDERABLE       = 0x302D;
static const int EGL_NATIVE_VISUAL_ID        = 0x302E;
static const int EGL_NATIVE_VISUAL_TYPE      = 0x302F;
static const int EGL_SAMPLES                 = 0x3031;
static const int EGL_SAMPLE_BUFFERS          = 0x3032;
static const int EGL_SURFACE_TYPE            = 0x3033;
static const int EGL_TRANSPARENT_TYPE        = 0x3034;
static const int EGL_TRANSPARENT_BLUE_VALUE  = 0x3035;
static const int EGL_TRANSPARENT_GREEN_VALUE = 0x3036;
static const int EGL_TRANSPARENT_RED_VALUE   = 0x3037;
static const int EGL_NONE                    = 0x3038; /* Attrib list terminator */
static const int EGL_BIND_TO_TEXTURE_RGB     = 0x3039;
static const int EGL_BIND_TO_TEXTURE_RGBA    = 0x303A;
static const int EGL_MIN_SWAP_INTERVAL       = 0x303B;
static const int EGL_MAX_SWAP_INTERVAL       = 0x303C;
static const int EGL_LUMINANCE_SIZE          = 0x303D;
static const int EGL_ALPHA_MASK_SIZE         = 0x303E;
static const int EGL_COLOR_BUFFER_TYPE       = 0x303F;
static const int EGL_RENDERABLE_TYPE         = 0x3040;
static const int EGL_MATCH_NATIVE_PIXMAP     = 0x3041; /* Pseudo-attribute (not queryable) */
static const int EGL_CONFORMANT              = 0x3042;

/* Config attribute values (EGL_CONFIG_CAVEAT) */
static const int EGL_SLOW_CONFIG             = 0x3050;
static const int EGL_NON_CONFORMANT_CONFIG   = 0x3051;

/* Config attribute values (EGL_TRANSPARENT_TYPE) */
static const int EGL_TRANSPARENT_RGB         = 0x3052;

/* Config attribute values (EGL_COLOR_BUFFER_TYPE) */
static const int EGL_RGB_BUFFER              = 0x308E;
static const int EGL_LUMINANCE_BUFFER        = 0x308F;

/* Config attribute values (EGL_TEXTURE_FORMAT) */
static const int EGL_NO_TEXTURE              = 0x305C;
static const int EGL_TEXTURE_RGB             = 0x305D;
static const int EGL_TEXTURE_RGBA            = 0x305E;
static const int EGL_TEXTURE_2D              = 0x305F;

/* Config attribute mask bits (EGL_SURFACE_TYPE) */
static const int EGL_PBUFFER_BIT                 = 0x0001;
static const int EGL_PIXMAP_BIT                  = 0x0002;
static const int EGL_WINDOW_BIT                  = 0x0004;
static const int EGL_VG_COLORSPACE_LINEAR_BIT    = 0x0020;
static const int EGL_VG_ALPHA_FORMAT_PRE_BIT     = 0x0040;
static const int EGL_MULTISAMPLE_RESOLVE_BOX_BIT = 0x0200;
static const int EGL_SWAP_BEHAVIOR_PRESERVED_BIT = 0x0400;

/* Config attribute mask bits (EGL_RENDERABLE_TYPE) */
static const int EGL_OPENGL_ES_BIT  = 0x0001;
static const int EGL_OPENVG_BIT     = 0x0002;
static const int EGL_OPENGL_ES2_BIT = 0x0004;
static const int EGL_OPENGL_BIT     = 0x0008;

/* QueryString targets */
static const int EGL_VENDOR      = 0x3053;
static const int EGL_VERSION     = 0x3054;
static const int EGL_EXTENSIONS  = 0x3055;
static const int EGL_CLIENT_APIS = 0x308D;

/* QuerySurface / SurfaceAttrib / CreatePbufferSurface targets */
static const int EGL_HEIGHT                = 0x3056;
static const int EGL_WIDTH                 = 0x3057;
static const int EGL_LARGEST_PBUFFER       = 0x3058;
static const int EGL_TEXTURE_FORMAT        = 0x3080;
static const int EGL_TEXTURE_TARGET        = 0x3081;
static const int EGL_MIPMAP_TEXTURE        = 0x3082;
static const int EGL_MIPMAP_LEVEL          = 0x3083;
static const int EGL_RENDER_BUFFER         = 0x3086;
static const int EGL_VG_COLORSPACE         = 0x3087;
static const int EGL_VG_ALPHA_FORMAT       = 0x3088;
static const int EGL_HORIZONTAL_RESOLUTION = 0x3090;
static const int EGL_VERTICAL_RESOLUTION   = 0x3091;
static const int EGL_PIXEL_ASPECT_RATIO    = 0x3092;
static const int EGL_SWAP_BEHAVIOR         = 0x3093;
static const int EGL_MULTISAMPLE_RESOLVE   = 0x3099;

/* EGL_RENDER_BUFFER values / BindTexImage / ReleaseTexImage buffer targets */
static const int EGL_BACK_BUFFER   = 0x3084;
static const int EGL_SINGLE_BUFFER = 0x3085;

/* OpenVG color spaces (EGL_VG_COLORSPACE) */
static const int EGL_VG_COLORSPACE_sRGB   = 0x3089;
static const int EGL_VG_COLORSPACE_LINEAR = 0x308A;

/* OpenVG alpha formats (EGL_ALPHA_FORMAT) */
static const int EGL_VG_ALPHA_FORMAT_NONPRE = 0x308B;
static const int EGL_VG_ALPHA_FORMAT_PRE    = 0x308C;

/* Constant scale factor by which fractional display resolutions &
   aspect ratio are scaled when queried as integer values. */
static const int EGL_DISPLAY_SCALING = 10000;

/* Unknown display resolution/aspect ratio */
static const int EGL_UNKNOWN = -1;

/* Back buffer swap behaviors (EGL_SWAP_BEHAVIOR) */
static const int EGL_BUFFER_PRESERVED = 0x3094;
static const int EGL_BUFFER_DESTROYED = 0x3095;

/* Createpbufferfromclientbuffer buffer types */
static const int EGL_OPENVG_IMAGE = 0x3096;

/* QueryContext targets */
static const int EGL_CONTEXT_CLIENT_TYPE = 0x3097;

/* CreateContext attributes */
static const int EGL_CONTEXT_CLIENT_VERSION = 0x3098;

/* Multisample resolution behaviors (EGL_MULTISAMPLE_RESOLVE) */
static const int EGL_MULTISAMPLE_RESOLVE_DEFAULT = 0x309A;
static const int EGL_MULTISAMPLE_RESOLVE_BOX     = 0x309B;

/* BindAPI/QueryAPI targets */
static const int EGL_OPENGL_ES_API = 0x30A0;
static const int EGL_OPENVG_API    = 0x30A1;
static const int EGL_OPENGL_API    = 0x30A2;

/* GetCurrentSurface targets */
static const int EGL_DRAW = 0x3059;
static const int EGL_READ = 0x305A;

/* WaitNative engines */
static const int EGL_CORE_NATIVE_ENGINE = 0x305B;

]]

require("lib.GLESv2") -- EGL depends on stuff in libGLESv2.so
local egl = setmetatable({ _NAME = "egl" },
                         { __index = require("lib.EGL") })

function egl.queryString(dpy, name)
   local s = egl.eglQueryString(dpy, name)
   return ffi.string(s)
end

-- EGL attribute types
--
-- there is a constructor for each attribute type
-- which creates a descriptor for documentation/stringify purposes

local attr_type = {
   integer = function(n, docstring)
      return {
         n = n,
         docstring = docstring,
         stringify = function(v)
            return string.format('%d', v)
         end
             }
   end,
   enum = function(n, docstring, map)
      return {
         n = n,
         docstring = docstring,
         stringify = function(v)
            return map[v] or "NONE"
         end
             }
   end,
   boolean = function(n, docstring)
      return {
         n = n,
         docstring = docstring,
         stringify = function(v)
            local rv = "yes"
            if v == egl.EGL_FALSE then
               rv = "no"
            end
            return rv
         end
             }
   end,
   bitmask = function(n, docstring, map)
      return {
         n = n,
         docstring = docstring,
         stringify = function(v)
            local rv = {}
            for mask,label in pairs(map) do
               if bit.band(v,mask) == mask then
                  table.insert(rv, label)
               end
            end
            return table.concat(rv,"|")
         end
             }
   end,
}

local attribute_descriptors = {
   config = {
      CONFIG_ID = attr_type.integer(egl.EGL_CONFIG_ID, "unique EGLConfig identifier"),
      BUFFER_SIZE = attr_type.integer(egl.EGL_BUFFER_SIZE, "total color component bits in the color buffer"),
      ALPHA_SIZE = attr_type.integer(egl.EGL_ALPHA_SIZE, "bits of Alpha in the color buffer"),
      BLUE_SIZE = attr_type.integer(egl.EGL_BLUE_SIZE, "bits of Blue in the color buffer"),
      GREEN_SIZE = attr_type.integer(egl.EGL_GREEN_SIZE, "bits of Green in the color buffer"),
      RED_SIZE = attr_type.integer(egl.EGL_RED_SIZE, "bits of Red in the color buffer"),
      DEPTH_SIZE = attr_type.integer(egl.EGL_DEPTH_SIZE, "bits of Z in the depth buffer"),
      STENCIL_SIZE = attr_type.integer(egl.EGL_STENCIL_SIZE, "bits of Stencil in the stencil buffer"),
      CONFIG_CAVEAT = attr_type.enum(egl.EGL_CONFIG_CAVEAT, "any caveats for the configuration",
                                    { [egl.EGL_SLOW_CONFIG] = "SLOW_CONFIG",
                                      [egl.EGL_NON_CONFORMANT_CONFIG] = "NON_CONFORMANT_CONFIG" }),
      LEVEL = attr_type.integer(egl.EGL_LEVEL, "frame buffer level"),
      MAX_PBUFFER_HEIGHT = attr_type.integer(egl.EGL_MAX_PBUFFER_HEIGHT, "maximum height of pbuffer"),
      MAX_PBUFFER_PIXELS = attr_type.integer(egl.EGL_MAX_PBUFFER_PIXELS, "maximum size of pbuffer"),
      MAX_PBUFFER_WIDTH = attr_type.integer(egl.EGL_MAX_PBUFFER_WIDTH, "maximum width of pbuffer"),
      NATIVE_RENDERABLE = attr_type.boolean(egl.EGL_NATIVE_RENDERABLE, "native rendering APIs can render to surface"),
      NATIVE_VISUAL_ID = attr_type.integer(egl.EGL_NATIVE_VISUAL_ID, "handle of corresponding native visual"),
      NATIVE_VISUAL_TYPE = attr_type.integer(egl.EGL_NATIVE_VISUAL_TYPE, "native visual type of the associated visual"),
      SAMPLES = attr_type.integer(egl.EGL_SAMPLES, "number of samples per pixel"),
      SAMPLE_BUFFERS = attr_type.integer(egl.EGL_SAMPLE_BUFFERS, "number of multisample buffers"),
      SURFACE_TYPE = attr_type.bitmask(egl.EGL_SURFACE_TYPE, "which types of EGL surfaces are supported",
                                      { [egl.EGL_WINDOW_BIT] = "WINDOW",
                                        [egl.EGL_PIXMAP_BIT] = "PIXMAP",
                                        [egl.EGL_PBUFFER_BIT] = "PBUFFER",
                                        [egl.EGL_MULTISAMPLE_RESOLVE_BOX_BIT] = "MULTISAMPLE_RESOLVE_BOX",
                                        [egl.EGL_VG_ALPHA_FORMAT_PRE_BIT] = "VG_ALPHA_FORMAT_PRE",
                                        [egl.EGL_SWAP_BEHAVIOR_PRESERVED_BIT] = "SWAP_BEHAVIOR_PRESERVED",
                                        [egl.EGL_VG_COLORSPACE_LINEAR_BIT] = "VG_COLORSPACE_LINEAR" }),
      TRANSPARENT_TYPE = attr_type.enum(egl.EGL_TRANSPARENT_TYPE, "type of transparency supported",
                                       { [egl.EGL_TRANSPARENT_RGB] = "TRANSPARENT_RGB" }),
      TRANSPARENT_BLUE_VALUE = attr_type.integer(egl.EGL_TRANSPARENT_BLUE_VALUE, "transparent blue value"),
      TRANSPARENT_GREEN_VALUE = attr_type.integer(egl.EGL_TRANSPARENT_GREEN_VALUE, "transparent green value"),
      TRANSPARENT_RED_VALUE = attr_type.integer(egl.EGL_TRANSPARENT_RED_VALUE, "transparent red value"),
      BIND_TO_TEXTURE_RGB = attr_type.boolean(egl.EGL_BIND_TO_TEXTURE_RGB, "bindable to RGB textures"),
      BIND_TO_TEXTURE_RGBA = attr_type.boolean(egl.EGL_BIND_TO_TEXTURE_RGBA, "bindable to RGBA textures"),
      MIN_SWAP_INTERVAL = attr_type.integer(egl.EGL_MIN_SWAP_INTERVAL, "minimum swap interval"),
      MAX_SWAP_INTERVAL = attr_type.integer(egl.EGL_MAX_SWAP_INTERVAL, "maximum swap interval"),
      LUMINANCE_SIZE = attr_type.integer(egl.EGL_LUMINANCE_SIZE, "bits of Luminance in the color buffer"),
      ALPHA_MASK_SIZE = attr_type.integer(egl.EGL_ALPHA_MASK_SIZE, "bits of Alpha Mask in the mask buffer"),
      COLOR_BUFFER_TYPE = attr_type.enum(egl.EGL_COLOR_BUFFER_TYPE, "color buffer type",
                                        { [egl.EGL_RGB_BUFFER] = "RGB_BUFFER",
                                          [egl.EGL_LUMINANCE_BUFFER] = "LUMINANCE_BUFFER" }),
      RENDERABLE_TYPE = attr_type.bitmask(egl.EGL_RENDERABLE_TYPE, "which client APIs are supported",
                                         { [egl.EGL_OPENGL_BIT] = "OPENGL",
                                           [egl.EGL_OPENGL_ES_BIT] = "OPENGL_ES",
                                           [egl.EGL_OPENGL_ES2_BIT] = "OPENGL_ES2",
                                           [egl.EGL_OPENVG_BIT] = "OPENVG" }),
      CONFORMANT = attr_type.bitmask(egl.EGL_CONFORMANT, "contexts created with this config are conformant",
                                    { [egl.EGL_OPENGL_BIT] = "OPENGL",
                                      [egl.EGL_OPENGL_ES_BIT] = "OPENGL_ES",
                                      [egl.EGL_OPENGL_ES2_BIT] = "OPENGL_ES2",
                                      [egl.EGL_OPENVG_BIT] = "OPENVG" }),
   },
   surface = {
      HEIGHT = attr_type.integer(egl.EGL_HEIGHT, "height of surface"),
      WIDTH = attr_type.integer(egl.EGL_WIDTH, "width of surface"),
      LARGEST_PBUFFER = attr_type.boolean(egl.EGL_LARGEST_PBUFFER, "create largest pbuffer possible"),
      TEXTURE_FORMAT = attr_type.enum(egl.EGL_TEXTURE_FORMAT, "format of texture",
                                     { [egl.EGL_NO_TEXTURE] = "NONE",
                                       [egl.EGL_TEXTURE_RGB] = "RGB",
                                       [egl.EGL_TEXTURE_RGBA] = "RGBA",
                                       [egl.EGL_TEXTURE_2D] = "2D" }),
      TEXTURE_TARGET = attr_type.enum(egl.EGL_TEXTURE_TARGET, "type of texture",
                                     { [egl.EGL_NO_TEXTURE] = "NONE",
                                       [egl.EGL_TEXTURE_2D] = "2D" }),
      MIPMAP_TEXTURE = attr_type.boolean(egl.EGL_MIPMAP_TEXTURE, "texture has mipmaps"),
      MIPMAP_LEVEL = attr_type.integer(egl.EGL_MIPMAP_LEVEL, "mipmap level to render to"),
      VG_COLORSPACE = attr_type.enum(egl.EGL_VG_COLORSPACE, "color space for OpenVG",
                                    { [egl.EGL_VG_COLORSPACE_sRGB] = "sRGB",
                                      [egl.EGL_VG_COLORSPACE_LINEAR] = "linear" }),
      VG_ALPHA_FORMAT = attr_type.enum(egl.EGL_VG_ALPHA_FORMAT, "alpha format for OpenVG",
                                      { [egl.EGL_VG_ALPHA_FORMAT_NONPRE] = "NONPRE",
                                        [egl.EGL_VG_ALPHA_FORMAT_PRE] = "PRE" }),
      HORIZONTAL_RESOLUTION = attr_type.integer(egl.EGL_HORIZONTAL_RESOLUTION, "horizontal dot pitch"),
      VERTICAL_RESOLUTION = attr_type.integer(egl.EGL_VERTICAL_RESOLUTION, "vertical dot pitch"),
      PIXEL_ASPECT_RATIO = attr_type.integer(egl.EGL_PIXEL_ASPECT_RATIO, "display aspect ratio"),
      SWAP_BEHAVIOR = attr_type.enum(egl.EGL_SWAP_BEHAVIOR, "buffer swap behavior",
                                    { [egl.EGL_BUFFER_PRESERVED] = "BUFFER_PRESERVED",
                                      [egl.EGL_BUFFER_DESTROYED] = "BUFFER_DESTROYED" }),
      MULTISAMPLE_RESOLVE = attr_type.enum(egl.EGL_MULTISAMPLE_RESOLVE, "multisample resolve behavior",
                                          { [egl.EGL_MULTISAMPLE_RESOLVE_DEFAULT] = "default",
                                            [egl.EGL_MULTISAMPLE_RESOLVE_BOX] = "box" }),
      CONFIG_ID = attr_type.integer(egl.EGL_CONFIG_ID, "unique EGLConfig identifier"),
      RENDER_BUFFER = attr_type.enum(egl.EGL_RENDER_BUFFER, "render buffer type",
                                    { [egl.EGL_BACK_BUFFER] = "BACK_BUFFER",
                                      [egl.EGL_SINGLE_BUFFER] = "SINGLE_BUFFER" }),
   },
   context = {
      CONTEXT_CLIENT_TYPE = attr_type.enum(egl.EGL_CONTEXT_CLIENT_TYPE, "type of client API supported by this context",
                                          { [egl.EGL_OPENGL_API] = "OPENGL",
                                            [egl.EGL_OPENGL_ES_API] = "OPENGL_ES",
                                            [egl.EGL_OPENVG_API] = "OPENVG" }),
      CONTEXT_CLIENT_VERSION = attr_type.integer(egl.EGL_CONTEXT_CLIENT_VERSION, "client API version"),
      CONFIG_ID = attr_type.integer(egl.EGL_CONFIG_ID, "unique EGLConfig identifier"),
      RENDER_BUFFER = attr_type.enum(egl.EGL_RENDER_BUFFER, "render buffer type",
                                    { [egl.EGL_BACK_BUFFER] = "BACK_BUFFER",
                                      [egl.EGL_SINGLE_BUFFER] = "SINGLE_BUFFER" }),
   }
}

local attribute_display = {
   config = {
      "BUFFER_SIZE",
      function(attrs)
         local rv
         if attrs.ALPHA_SIZE > 0 then
            rv = string.format("(RGBA%d%d%d%d)", attrs.RED_SIZE, attrs.GREEN_SIZE, attrs.BLUE_SIZE, attrs.ALPHA_SIZE)
         else
            rv = string.format("(RGB%d%d%d)", attrs.RED_SIZE, attrs.GREEN_SIZE, attrs.BLUE_SIZE)
         end
         return rv
      end,
      "DEPTH_SIZE",
      "STENCIL_SIZE",
      "CONFIG_CAVEAT",
      "CONFIG_ID",
      "LEVEL",
      "MAX_PBUFFER_WIDTH",
      "MAX_PBUFFER_HEIGHT",
      "MAX_PBUFFER_PIXELS",
      "NATIVE_RENDERABLE",
      "NATIVE_VISUAL_ID",
      "NATIVE_VISUAL_TYPE",
      "SAMPLES",
      "SAMPLE_BUFFERS",
      "SURFACE_TYPE",
      "TRANSPARENT_TYPE",
      function(attrs)
         return string.format("(RGB%d%d%d)", attrs.TRANSPARENT_RED_VALUE, attrs.TRANSPARENT_GREEN_VALUE, attrs.TRANSPARENT_BLUE_VALUE)
      end,
      "BIND_TO_TEXTURE_RGB",
      "BIND_TO_TEXTURE_RGBA",
      "MIN_SWAP_INTERVAL",
      "MAX_SWAP_INTERVAL",
      "LUMINANCE_SIZE",
      "ALPHA_MASK_SIZE",
      "COLOR_BUFFER_TYPE",
      "RENDERABLE_TYPE",
      "CONFORMANT",
   },
   surface = {
      function(attrs)
         return string.format("SIZE=%dx%d", attrs.WIDTH, attrs.HEIGHT)
      end,
      "CONFIG_ID",
      "HORIZONTAL_RESOLUTION",
      "VERTICAL_RESOLUTION",
      "PIXEL_ASPECT_RATIO",
      "SWAP_BEHAVIOR",
      "MULTISAMPLE_RESOLVE",
      "LARGEST_PBUFFER",
      "TEXTURE_FORMAT",
      "TEXTURE_TARGET",
      "MIPMAP_TEXTURE",
      "MIPMAP_LEVEL",
      "RENDER_BUFFER",
      "VG_COLORSPACE",
      "VG_ALPHA_FORMAT",
   },
   context = {
      "CONFIG_ID",
      "CONTEXT_CLIENT_TYPE",
      "CONTEXT_CLIENT_VERSION",
      "RENDER_BUFFER",
   },
}

local function make_tostring(display, descriptors)
   local function tostring(attrs)
      local rv = {}
      for _,name in pairs(display) do
         if type(name) == "function" then
            local display_func = name
            table.insert(rv, display_func(attrs))
         else
            local descriptor = descriptors[name]
            local value = attrs[name]
            local stringified_value = descriptor.stringify(value)
            table.insert(rv, name.."="..stringified_value)
         end
      end
      return table.concat(rv, " ")
   end
   return tostring
end

--- config ---

local function egl_name(s)
   if s:sub(1,4) ~= "EGL_" then
      s = "EGL_"..s
   end
   return s
end

ffi.cdef [[
typedef struct {
   EGLDisplay dpy;
   EGLConfig config;
} piper_egl_config;
]]

local piper_egl_config_mt = {
   __index = function(self,name)
      local v = ffi.new("EGLint[1]")
      egl.eglGetConfigAttrib(self.dpy, self.config, egl[egl_name(name)], v+0)
      return v[0]
   end,
   __eq = function(this,that)
      return this.dpy==that.dpy and this.config==that.config
   end,
   __tostring = make_tostring(attribute_display.config, attribute_descriptors.config),
}
ffi.metatype("piper_egl_config", piper_egl_config_mt)

function egl.getConfigs(dpy)
   local n = ffi.new("EGLint[1]")
   egl.eglGetConfigs(dpy, nil, 0, n)
   local nconfigs = n[0]
   local configs = ffi.new("EGLConfig[?]", nconfigs)
   egl.eglGetConfigs(dpy, configs, nconfigs, n)
   assert(nconfigs==n[0])
   local rv = {}
   for i=1,nconfigs do
      local c = ffi.new("piper_egl_config", dpy, configs[i-1])
      rv[c.CONFIG_ID] = c
   end
   return rv
end

local function table_size(t)
   local size = 0
   for _ in pairs(t) do size = size + 1 end
   return size
end

function egl.chooseConfig(dpy, limits)
   local nlimits = table_size(limits)
   local attrib_list = ffi.new("EGLint[?]", 2*nlimits+1)
   local i = 0
   for name,v in pairs(limits) do
      attrib_list[i+0] = attribute_descriptors.config[name].n
      attrib_list[i+1] = v
      i = i + 2
   end
   attrib_list[i] = egl.EGL_NONE
   local configs = ffi.new("EGLConfig[1]")
   local n = ffi.new("EGLint[1]")
   local rv = egl.eglChooseConfig(dpy, attrib_list, configs, 1, n)
   if rv ~= egl.EGL_TRUE then
      error("eglChooseConfig() failed")
   end
   if n[0] ~= 1 then
      error("eglChooseConfig(): no suitable configuration found")
   end
   return ffi.new("piper_egl_config", dpy, configs[0])
end

--- surface ---

ffi.cdef [[
typedef struct {
   EGLDisplay dpy;
   EGLSurface surface;
} piper_egl_surface;
]]

local piper_egl_surface_methods = {
   destroy = function(self)
      return egl.eglDestroySurface(self.dpy, self.surface)
   end,
}

local piper_egl_surface_mt = {
   __new = function(ct, type, dpy, config, win, attribs)
      attribs = attribs or {}
      local nattribs = table_size(attribs)
      local _attribs = nil
      if nattribs > 0 then
         _attribs = ffi.new("EGLint[?]", nattribs*2+1)
         local i = 0
         for k,v in pairs(attribs) do
            _attribs[i] = k
            _attribs[i+1] = v
            i=i+2
         end
         _attribs[i] = egl.EGL_NONE
      end
      local s
      if type == 'window' then
         s = egl.eglCreateWindowSurface(dpy, config.config, win, _attribs)
         assert(s, "eglCreateWindowSurface() failed")
      else
         error(string.format("egl.surface constructor called with invalid surface type: %s", type))
      end
      return ffi.new("piper_egl_surface", dpy, s)
   end,
   __index = function(self,name)
      local m = piper_egl_surface_methods[name]
      if m then return m end
      local v = ffi.new("EGLint[1]")
      egl.eglQuerySurface(self.dpy, self.surface, egl[egl_name(name)], v+0)
      return v[0]
   end,
   __eq = function(this,that)
      return this.dpy==that.dpy and this.surface==that.surface
   end,
   __tostring = make_tostring(attribute_display.surface, attribute_descriptors.surface),
}
ffi.metatype("piper_egl_surface", piper_egl_surface_mt)
egl.surface = ffi.typeof("piper_egl_surface")

function egl.window_surface(...)
   return egl.surface('window', ...)
end

--- api ---

egl.bindAPI = egl.eglBindAPI
egl.queryAPI = egl.eglQueryAPI

--- context ---

ffi.cdef [[
typedef struct {
   EGLDisplay dpy;
   EGLContext context;
} piper_egl_context;
]]

local piper_egl_context_methods = {
   destroy = function(self)
      return egl.eglDestroyContext(self.dpy, self.context)
   end,
   makeCurrent = function(self, draw, read)
      local rv = egl.eglMakeCurrent(self.dpy, draw.surface, read.surface, self.context)
      assert(rv == egl.EGL_TRUE, "eglMakeCurrent() failed")
      return rv
   end,
   release = function(self)
      local rv = egl.eglMakeCurrent(self.dpy, nil, nil, nil)
      assert(rv == egl.EGL_FALSE, "eglMakeCurrent() failed")
      return rv
   end,
}

local piper_egl_context_mt = {
   __new = function(ct, dpy, config, share_context)
      share_context = share_context and share_context.context
      local attrib_list = ffi.new("EGLint[3]")
      if egl.eglQueryAPI() == egl.EGL_OPENGL_ES_API then
         attrib_list[0] = egl.EGL_CONTEXT_CLIENT_VERSION
         attrib_list[1] = 2
         attrib_list[2] = egl.EGL_NONE
      else
         attrib_list[0] = egl.EGL_NONE
      end
      local ctx = egl.eglCreateContext(dpy, config.config, share_context, attrib_list)
      assert(ctx, "eglCreateContext() failed")
      return ffi.new("piper_egl_context", dpy, ctx)
   end,
   __index = function(self,name)
      local m = piper_egl_context_methods[name]
      if m then return m end
      local v = ffi.new("EGLint[1]")
      egl.eglQueryContext(self.dpy, self.context, egl[egl_name(name)], v+0)
      return v[0]
   end,
   __eq = function(this,that)
      return this.dpy==that.dpy and this.context==that.context
   end,
   __tostring = make_tostring(attribute_display.context, attribute_descriptors.context),
}
ffi.metatype("piper_egl_context", piper_egl_context_mt)
egl.context = ffi.typeof("piper_egl_context")

function egl.swapBuffers(dpy, surface)
   egl.eglSwapBuffers(dpy, surface.surface)
end

function egl.wrap(f)
   local w = function()
      local dpy = egl.eglGetDisplay(nil)
      local major = ffi.new("EGLint[1]")
      local minor = ffi.new("EGLint[1]")
      local rv = egl.eglInitialize(dpy, major, minor)
      assert(rv ~= egl.EGL_FALSE, "eglInitialize() failed")
      local rv,e = pcall(f, dpy, major[0], minor[0])
      egl.eglReleaseThread()
      egl.eglTerminate(dpy)
      if not rv then error(e,0) end
   end
   return w
end

return egl
