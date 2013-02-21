#!/usr/bin/luajit

local ffi = require("ffi")
local bit = require("bit")

local function log(msg, ...)
   print(string.format(msg, ...))
end

local function loadlib(name, global)
   local l = ffi.load(name, global or false)
   log('ffi.load(%s)', name)
   return l
end

loadlib('vcos', true)
local bcm_host = loadlib('bcm_host')
loadlib('GLESv2', true)
local egl = loadlib('EGL')
local vg = loadlib('OpenVG')

ffi.cdef [[
void bcm_host_init(void);
]]

bcm_host.bcm_host_init()
log('bcm_host_init()')

ffi.cdef [[
typedef void *EGLDisplay;
typedef void *EGLNativeDisplayType;

EGLDisplay eglGetDisplay(EGLNativeDisplayType display_id);
]]

local dpy = egl.eglGetDisplay(nil)
log('eglGetDisplay() -> %s', dpy)

ffi.cdef [[
typedef unsigned int EGLBoolean;
static const int EGL_FALSE = 0;
static const int EGL_TRUE  = 1;

typedef int32_t EGLint;

EGLBoolean eglInitialize(EGLDisplay dpy,
                         EGLint *major,
                         EGLint *minor);
]]

local major = ffi.new("EGLint[1]")
local minor = ffi.new("EGLint[1]")
local rv = egl.eglInitialize(dpy, major, minor)
assert(rv ~= egl.EGL_FALSE, "eglInitialize() failed")
log('eglInitialize() -> major=%d,minor=%d', major[0], minor[0])

ffi.cdef [[
const char * eglQueryString(EGLDisplay dpy, EGLint name);

/* QueryString targets */
static const int EGL_VENDOR      = 0x3053;
static const int EGL_VERSION     = 0x3054;
static const int EGL_EXTENSIONS  = 0x3055;
static const int EGL_CLIENT_APIS = 0x308D;
]]

for _,name in ipairs({"VENDOR","VERSION","EXTENSIONS","CLIENT_APIS"}) do
   local value = egl.eglQueryString(dpy, egl["EGL_"..name])
   log('eglQueryString(%s) -> %s', name, ffi.string(value))
end

local dmx = {}

ffi.cdef [[
typedef uint32_t DISPMANX_DISPLAY_HANDLE_T;

DISPMANX_DISPLAY_HANDLE_T vc_dispmanx_display_open( uint32_t device );

static const uint32_t DISPMANX_NO_HANDLE = 0;
]]

dmx.dpy = bcm_host.vc_dispmanx_display_open(0)
assert(dmx.dpy ~= bcm_host.DISPMANX_NO_HANDLE, "vc_dispmanx_display_open() failed")
log('vc_dispmanx_display_open(0) -> 0x%x', dmx.dpy)

ffi.cdef [[
static const int TRANSFORM_HFLIP     = 1<<0;
static const int TRANSFORM_VFLIP     = 1<<1;
static const int TRANSFORM_TRANSPOSE = 1<<2;

typedef enum {
   VC_IMAGE_ROT0           = 0,
   VC_IMAGE_MIRROR_ROT0    = TRANSFORM_HFLIP,
   VC_IMAGE_MIRROR_ROT180  = TRANSFORM_VFLIP,
   VC_IMAGE_ROT180         = TRANSFORM_HFLIP|TRANSFORM_VFLIP,
   VC_IMAGE_MIRROR_ROT90   = TRANSFORM_TRANSPOSE,
   VC_IMAGE_ROT270         = TRANSFORM_TRANSPOSE|TRANSFORM_HFLIP,
   VC_IMAGE_ROT90          = TRANSFORM_TRANSPOSE|TRANSFORM_VFLIP,
   VC_IMAGE_MIRROR_ROT270  = TRANSFORM_TRANSPOSE|TRANSFORM_HFLIP|TRANSFORM_VFLIP,
} VC_IMAGE_TRANSFORM_T;

typedef enum
{
   VCOS_DISPLAY_INPUT_FORMAT_INVALID = 0,
   VCOS_DISPLAY_INPUT_FORMAT_RGB888,
   VCOS_DISPLAY_INPUT_FORMAT_RGB565
}
VCOS_DISPLAY_INPUT_FORMAT_T;

/** For backward compatibility */
static const int DISPLAY_INPUT_FORMAT_INVALID = VCOS_DISPLAY_INPUT_FORMAT_INVALID;
static const int DISPLAY_INPUT_FORMAT_RGB888  = VCOS_DISPLAY_INPUT_FORMAT_RGB888;
static const int DISPLAY_INPUT_FORMAT_RGB565  = VCOS_DISPLAY_INPUT_FORMAT_RGB565;
typedef VCOS_DISPLAY_INPUT_FORMAT_T DISPLAY_INPUT_FORMAT_T;

typedef struct {
  int32_t width;
  int32_t height;
  VC_IMAGE_TRANSFORM_T transform;
  DISPLAY_INPUT_FORMAT_T input_format;
} DISPMANX_MODEINFO_T;

int vc_dispmanx_display_get_info( DISPMANX_DISPLAY_HANDLE_T display,
                                  DISPMANX_MODEINFO_T * pinfo );
]]

dmx.info = ffi.new("DISPMANX_MODEINFO_T")
local rv = bcm_host.vc_dispmanx_display_get_info(dmx.dpy, dmx.info)
assert(rv==0, "vc_dispmanx_display_get_info() failed")
log('vc_dispmanx_display_get_info() -> width=%d, height=%d', dmx.info.width, dmx.info.height)

ffi.cdef [[
typedef uint32_t DISPMANX_UPDATE_HANDLE_T;

DISPMANX_UPDATE_HANDLE_T vc_dispmanx_update_start( int32_t priority );
]]

local u = bcm_host.vc_dispmanx_update_start(0)
assert(u ~= bcm_host.DISPMANX_NO_HANDLE, "vc_dispmanx_update_start() failed")
log('vc_dispmanx_update_start(0) -> 0x%x', u)

ffi.cdef [[
typedef struct tag_VC_RECT_T {
   int32_t x;
   int32_t y;
   int32_t width;
   int32_t height;
} VC_RECT_T;

int vc_dispmanx_rect_set( VC_RECT_T *rect,
                          uint32_t x_offset,
                          uint32_t y_offset,
                          uint32_t width,
                          uint32_t height );
]]

dmx.src_rect = ffi.new("VC_RECT_T")
bcm_host.vc_dispmanx_rect_set(dmx.src_rect,
                              0,
                              0,
                              bit.lshift(dmx.info.width,16),
                              bit.lshift(dmx.info.height,16))
dmx.dest_rect = ffi.new("VC_RECT_T")
bcm_host.vc_dispmanx_rect_set(dmx.dest_rect,
                              0,
                              0,
                              dmx.info.width,
                              dmx.info.height)

ffi.cdef [[
typedef uint32_t DISPMANX_ELEMENT_HANDLE_T;
typedef uint32_t DISPMANX_RESOURCE_HANDLE_T;
typedef uint32_t DISPMANX_PROTECTION_T;

static const uint32_t DISPMANX_PROTECTION_NONE  = 0;

typedef enum {
  /* Bottom 2 bits sets the alpha mode */
  DISPMANX_FLAGS_ALPHA_FROM_SOURCE = 0,
  DISPMANX_FLAGS_ALPHA_FIXED_ALL_PIXELS = 1,
  DISPMANX_FLAGS_ALPHA_FIXED_NON_ZERO = 2,
  DISPMANX_FLAGS_ALPHA_FIXED_EXCEED_0X07 = 3,

  DISPMANX_FLAGS_ALPHA_PREMULT = 1 << 16,
  DISPMANX_FLAGS_ALPHA_MIX = 1 << 17
} DISPMANX_FLAGS_ALPHA_T;

typedef struct {
  DISPMANX_FLAGS_ALPHA_T flags;
  uint32_t opacity;
  DISPMANX_RESOURCE_HANDLE_T mask;
} VC_DISPMANX_ALPHA_T;

typedef enum {
  DISPMANX_FLAGS_CLAMP_NONE = 0,
  DISPMANX_FLAGS_CLAMP_LUMA_TRANSPARENT = 1,
  DISPMANX_FLAGS_CLAMP_TRANSPARENT = 2,
  DISPMANX_FLAGS_CLAMP_REPLACE = 3
} DISPMANX_FLAGS_CLAMP_T;

typedef enum {
  DISPMANX_FLAGS_KEYMASK_OVERRIDE = 1,
  DISPMANX_FLAGS_KEYMASK_SMOOTH = 1 << 1,
  DISPMANX_FLAGS_KEYMASK_CR_INV = 1 << 2,
  DISPMANX_FLAGS_KEYMASK_CB_INV = 1 << 3,
  DISPMANX_FLAGS_KEYMASK_YY_INV = 1 << 4
} DISPMANX_FLAGS_KEYMASK_T;

typedef union {
  struct {
    uint8_t yy_upper;
    uint8_t yy_lower;
    uint8_t cr_upper;
    uint8_t cr_lower;
    uint8_t cb_upper;
    uint8_t cb_lower;
  } yuv;
  struct {
    uint8_t red_upper;
    uint8_t red_lower;
    uint8_t blue_upper;
    uint8_t blue_lower;
    uint8_t green_upper;
    uint8_t green_lower;
  } rgb;
} DISPMANX_CLAMP_KEYS_T;

typedef struct {
  DISPMANX_FLAGS_CLAMP_T mode;
  DISPMANX_FLAGS_KEYMASK_T key_mask;
  DISPMANX_CLAMP_KEYS_T key_value;
  uint32_t replace_value;
} DISPMANX_CLAMP_T;

typedef enum {
  /* Bottom 2 bits sets the orientation */
  DISPMANX_NO_ROTATE = 0,
  DISPMANX_ROTATE_90 = 1,
  DISPMANX_ROTATE_180 = 2,
  DISPMANX_ROTATE_270 = 3,

  DISPMANX_FLIP_HRIZ = 1 << 16,
  DISPMANX_FLIP_VERT = 1 << 17
} DISPMANX_TRANSFORM_T;

DISPMANX_ELEMENT_HANDLE_T
vc_dispmanx_element_add ( DISPMANX_UPDATE_HANDLE_T update,
                          DISPMANX_DISPLAY_HANDLE_T display,
                          int32_t layer,
                          const VC_RECT_T *dest_rect,
                          DISPMANX_RESOURCE_HANDLE_T src,
                          const VC_RECT_T *src_rect,
                          DISPMANX_PROTECTION_T protection, 
                          VC_DISPMANX_ALPHA_T *alpha,
                          DISPMANX_CLAMP_T *clamp,
                          DISPMANX_TRANSFORM_T transform );
]]

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
log('vc_dispmanx_element_add(...) -> 0x%x', dmx.element)

ffi.cdef [[
int vc_dispmanx_update_submit_sync( DISPMANX_UPDATE_HANDLE_T update );
]]

local rv = bcm_host.vc_dispmanx_update_submit_sync(u)
assert(rv==0, "vc_dispmanx_update_submit_sync() failed")
log('vc_dispmanx_update_submit_sync(0x%x) -> %d', u, rv)

ffi.cdef [[
typedef void *EGLConfig;

EGLBoolean eglChooseConfig(EGLDisplay dpy,
                           const EGLint *attrib_list,
                           EGLConfig *configs,
                           EGLint config_size,
                           EGLint *num_config);

/* Config attributes */
static const int EGL_ALPHA_SIZE              = 0x3021;
static const int EGL_BLUE_SIZE               = 0x3022;
static const int EGL_GREEN_SIZE              = 0x3023;
static const int EGL_RED_SIZE                = 0x3024;
static const int EGL_SURFACE_TYPE            = 0x3033;
static const int EGL_RENDERABLE_TYPE         = 0x3040;

static const int EGL_NONE                    = 0x3038;

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
]]

local function table_size(t)
   local size = 0
   for _ in pairs(t) do size = size + 1 end
   return size
end

local function build_attrib_list(attribs)
   local nattribs = table_size(attribs)
   local attrib_list = ffi.new("EGLint[?]", 2*nattribs+1)
   local i = 0
   for n,v in pairs(attribs) do
      attrib_list[i+0] = egl["EGL_"..n]
      attrib_list[i+1] = v
      i = i + 2
   end
   attrib_list[i] = egl.EGL_NONE
   return attrib_list
end

local limits = {
   RED_SIZE = 8,
   GREEN_SIZE = 8,
   BLUE_SIZE = 8,
   ALPHA_SIZE = 8,
   SURFACE_TYPE = egl.EGL_WINDOW_BIT,
   RENDERABLE_TYPE = egl.EGL_OPENVG_BIT,
}

local attrib_list = build_attrib_list(limits)
local configs = ffi.new("EGLConfig[1]")
local num_config = ffi.new("EGLint[1]")
local rv = egl.eglChooseConfig(dpy, attrib_list, configs, 1, num_config)
assert(rv==egl.EGL_TRUE, "eglChooseConfig() failed")
if num_config[0] ~= 1 then
   error("eglChooseConfig(): no suitable configuration found")
end
local config = configs[0]

ffi.cdef [[
typedef unsigned int EGLenum;

EGLBoolean eglBindAPI(EGLenum api);
EGLenum eglQueryAPI(void);

/* BindAPI/QueryAPI targets */
static const int EGL_OPENGL_ES_API = 0x30A0;
static const int EGL_OPENVG_API    = 0x30A1;
static const int EGL_OPENGL_API    = 0x30A2;
]]

egl.eglBindAPI(egl.EGL_OPENVG_API)
log('eglBindAPI(EGL_OPENVG_API)')
assert(egl.eglQueryAPI() == egl.EGL_OPENVG_API)
log('eglQueryApi() -> EGL_OPENVG_API')

ffi.cdef [[
typedef void *EGLContext;

EGLContext eglCreateContext(EGLDisplay dpy,
                            EGLConfig config,
                            EGLContext share_context,
                            const EGLint *attrib_list);
]]

local ctx = egl.eglCreateContext(dpy, config, nil, nil)
assert(ctx, "eglCreateContext() failed")
log('eglCreateContext() -> %s', ctx)

ffi.cdef [[
typedef struct {
   DISPMANX_ELEMENT_HANDLE_T element;
   int width;
   int height;
} EGL_DISPMANX_WINDOW_T;

typedef void *EGLSurface;
typedef void *EGLNativeWindowType;

/* actually:
typedef EGL_DISPMANX_WINDOW_T *EGLNativeWindowType;
*/

EGLSurface eglCreateWindowSurface(EGLDisplay dpy,
                                  EGLConfig config,
                                  EGLNativeWindowType win,
                                  const EGLint *attrib_list);
]]

dmx.egl_window = ffi.new("EGL_DISPMANX_WINDOW_T", 
                         dmx.element,
                         dmx.info.width,
                         dmx.info.height)
log('created EGL_DISPMANX_WINDOW_T (EGLNativeWindowType for eglCreateWindowSurface)')

local surface = egl.eglCreateWindowSurface(dpy,
                                           config,
                                           dmx.egl_window,
                                           nil)
assert(surface, "eglCreateWindowSurface() failed")
log('eglCreateWindowSurface() -> %s', surface)

ffi.cdef [[
EGLBoolean eglMakeCurrent(EGLDisplay dpy,
                          EGLSurface draw,
                          EGLSurface read,
                          EGLContext ctx);
]]

local rv = egl.eglMakeCurrent(dpy, surface, surface, ctx)
assert(rv == egl.EGL_TRUE, "eglMakeCurrent() failed")
log('eglMakeCurrent(dpy, surface, surface, ctx) -> %d', rv)

ffi.cdef [[
typedef int32_t  VGint;
typedef uint32_t VGuint;
typedef float    VGfloat;

static const int VG_MAX_ENUM = 0x7FFFFFFF;

typedef enum {
  /* Mode settings */
  VG_MATRIX_MODE                              = 0x1100,
  VG_FILL_RULE                                = 0x1101,
  VG_IMAGE_QUALITY                            = 0x1102,
  VG_RENDERING_QUALITY                        = 0x1103,
  VG_BLEND_MODE                               = 0x1104,
  VG_IMAGE_MODE                               = 0x1105,

  /* Scissoring rectangles */
  VG_SCISSOR_RECTS                            = 0x1106,

  /* Color Transformation */
  VG_COLOR_TRANSFORM                          = 0x1170,
  VG_COLOR_TRANSFORM_VALUES                   = 0x1171,

  /* Stroke parameters */
  VG_STROKE_LINE_WIDTH                        = 0x1110,
  VG_STROKE_CAP_STYLE                         = 0x1111,
  VG_STROKE_JOIN_STYLE                        = 0x1112,
  VG_STROKE_MITER_LIMIT                       = 0x1113,
  VG_STROKE_DASH_PATTERN                      = 0x1114,
  VG_STROKE_DASH_PHASE                        = 0x1115,
  VG_STROKE_DASH_PHASE_RESET                  = 0x1116,

  /* Edge fill color for VG_TILE_FILL tiling mode */
  VG_TILE_FILL_COLOR                          = 0x1120,

  /* Color for vgClear */
  VG_CLEAR_COLOR                              = 0x1121,

  /* Glyph origin */
  VG_GLYPH_ORIGIN                             = 0x1122,

  /* Enable/disable alpha masking and scissoring */
  VG_MASKING                                  = 0x1130,
  VG_SCISSORING                               = 0x1131,

  /* Pixel layout information */
  VG_PIXEL_LAYOUT                             = 0x1140,
  VG_SCREEN_LAYOUT                            = 0x1141,

  /* Source format selection for image filters */
  VG_FILTER_FORMAT_LINEAR                     = 0x1150,
  VG_FILTER_FORMAT_PREMULTIPLIED              = 0x1151,

  /* Destination write enable mask for image filters */
  VG_FILTER_CHANNEL_MASK                      = 0x1152,

  /* Implementation limits (read-only) */
  VG_MAX_SCISSOR_RECTS                        = 0x1160,
  VG_MAX_DASH_COUNT                           = 0x1161,
  VG_MAX_KERNEL_SIZE                          = 0x1162,
  VG_MAX_SEPARABLE_KERNEL_SIZE                = 0x1163,
  VG_MAX_COLOR_RAMP_STOPS                     = 0x1164,
  VG_MAX_IMAGE_WIDTH                          = 0x1165,
  VG_MAX_IMAGE_HEIGHT                         = 0x1166,
  VG_MAX_IMAGE_PIXELS                         = 0x1167,
  VG_MAX_IMAGE_BYTES                          = 0x1168,
  VG_MAX_FLOAT                                = 0x1169,
  VG_MAX_GAUSSIAN_STD_DEVIATION               = 0x116A,

  VG_PARAM_TYPE_FORCE_SIZE                    = VG_MAX_ENUM
} VGParamType;

/* Getters and Setters */
void vgSetf (VGParamType type, VGfloat value);
void vgSeti (VGParamType type, VGint value);
void vgSetfv(VGParamType type, VGint count,
                         const VGfloat * values);
void vgSetiv(VGParamType type, VGint count,
                         const VGint * values);

VGfloat vgGetf(VGParamType type);
VGint vgGeti(VGParamType type);
VGint vgGetVectorSize(VGParamType type);
void vgGetfv(VGParamType type, VGint count, VGfloat * values);
void vgGetiv(VGParamType type, VGint count, VGint * values);
]]

vg.vgSetfv(vg.VG_CLEAR_COLOR, 4, ffi.new("VGfloat[4]", 0,0,0,1))
local clearColor = ffi.new("VGfloat[4]")
vg.vgGetfv(vg.VG_CLEAR_COLOR, 4, clearColor)
log("vgSetfv(VG_CLEAR_COLOR, 4, (%g,%g,%g,%g))",
    clearColor[0],
    clearColor[1],
    clearColor[2],
    clearColor[3])

ffi.cdef [[
void vgClear(VGint x, VGint y, VGint width, VGint height);
]]

vg.vgClear(0,0,dmx.info.width,dmx.info.height)
log('vgClear(%d,%d,%d,%d)', 0, 0, dmx.info.width, dmx.info.height)

ffi.cdef [[
typedef VGuint VGHandle;
typedef VGHandle VGPaint;

VGPaint vgCreatePaint(void);
]]

local paint = vg.vgCreatePaint()
log('vgCreatePaint() -> 0x%x', paint)

ffi.cdef [[
typedef enum {
  VG_NO_ERROR                                 = 0,
  VG_BAD_HANDLE_ERROR                         = 0x1000,
  VG_ILLEGAL_ARGUMENT_ERROR                   = 0x1001,
  VG_OUT_OF_MEMORY_ERROR                      = 0x1002,
  VG_PATH_CAPABILITY_ERROR                    = 0x1003,
  VG_UNSUPPORTED_IMAGE_FORMAT_ERROR           = 0x1004,
  VG_UNSUPPORTED_PATH_FORMAT_ERROR            = 0x1005,
  VG_IMAGE_IN_USE_ERROR                       = 0x1006,
  VG_NO_CONTEXT_ERROR                         = 0x1007,

  VG_ERROR_CODE_FORCE_SIZE                    = VG_MAX_ENUM
} VGErrorCode;

VGErrorCode vgGetError(void);
]]

assert(vg.vgGetError()==vg.VG_NO_ERROR,"vgCreatePaint() failed")

ffi.cdef [[
void vgSetParameterf(VGHandle object,
                     VGint paramType,
                     VGfloat value);
void vgSetParameteri(VGHandle object,
                     VGint paramType,
                     VGint value);
void vgSetParameterfv(VGHandle object,
                      VGint paramType,
                      VGint count, const VGfloat * values);
void vgSetParameteriv(VGHandle object,
                      VGint paramType,
                      VGint count, const VGint * values);

VGfloat vgGetParameterf(VGHandle object,
                        VGint paramType);
VGint vgGetParameteri(VGHandle object,
                      VGint paramType);
VGint vgGetParameterVectorSize(VGHandle object,
                               VGint paramType);
void vgGetParameterfv(VGHandle object,
                      VGint paramType,
                      VGint count, VGfloat * values);
void vgGetParameteriv(VGHandle object,
                      VGint paramType,
                      VGint count, VGint * values);

typedef enum {
  /* Color paint parameters */
  VG_PAINT_TYPE                               = 0x1A00,
  VG_PAINT_COLOR                              = 0x1A01,
  VG_PAINT_COLOR_RAMP_SPREAD_MODE             = 0x1A02,
  VG_PAINT_COLOR_RAMP_PREMULTIPLIED           = 0x1A07,
  VG_PAINT_COLOR_RAMP_STOPS                   = 0x1A03,

  /* Linear gradient paint parameters */
  VG_PAINT_LINEAR_GRADIENT                    = 0x1A04,

  /* Radial gradient paint parameters */
  VG_PAINT_RADIAL_GRADIENT                    = 0x1A05,

  /* Pattern paint parameters */
  VG_PAINT_PATTERN_TILING_MODE                = 0x1A06,

  VG_PAINT_PARAM_TYPE_FORCE_SIZE              = VG_MAX_ENUM
} VGPaintParamType;

typedef enum {
  VG_PAINT_TYPE_COLOR                         = 0x1B00,
  VG_PAINT_TYPE_LINEAR_GRADIENT               = 0x1B01,
  VG_PAINT_TYPE_RADIAL_GRADIENT               = 0x1B02,
  VG_PAINT_TYPE_PATTERN                       = 0x1B03,

  VG_PAINT_TYPE_FORCE_SIZE                    = VG_MAX_ENUM
} VGPaintType;
]]

vg.vgSetParameteri(paint,
                   vg.VG_PAINT_TYPE,
                   vg.VG_PAINT_TYPE_COLOR)
log('vgSetParameteri(0x%x, VG_PAINT_TYPE, VG_PAINT_TYPE_COLOR)', paint)

vg.vgSetParameterfv(paint,
                    vg.VG_PAINT_COLOR,
                    4,
                    ffi.new("VGfloat[4]",1,1,1,1))
log('vgSetParameterfv(0x%x, VG_PAINT_COLOR, 4, (1,1,1,1))', paint)

ffi.cdef [[
void vgSetColor(VGPaint paint, VGuint rgba);
VGuint vgGetColor(VGPaint paint);
]]

assert(vg.vgGetColor(paint) == 0xffffffff)
log('vgGetColor(0x%x) -> 0x%x', paint, vg.vgGetColor(paint))

ffi.cdef [[
typedef uint32_t VGbitfield;

typedef enum {
  VG_STROKE_PATH                              = (1 << 0),
  VG_FILL_PATH                                = (1 << 1),

  VG_PAINT_MODE_FORCE_SIZE                    = VG_MAX_ENUM
} VGPaintMode;

void vgSetPaint(VGPaint paint, VGbitfield paintModes);
VGPaint vgGetPaint(VGPaintMode paintMode);
]]

vg.vgSetPaint(paint, vg.VG_STROKE_PATH)
assert(vg.vgGetPaint(vg.VG_STROKE_PATH) == paint)
log('vgSetPaint(0x%x, VG_STROKE_PATH)', paint)

ffi.cdef [[
void vgDestroyPaint(VGPaint paint);
]]

vg.vgDestroyPaint(paint)
log('vgDestroyPaint(0x%x)', paint)

vg.vgSetf(vg.VG_STROKE_LINE_WIDTH, 1)
log('vgSetf(VG_STROKE_LINE_WIDTH, 1)')

ffi.cdef [[
typedef VGHandle VGPath;
static const VGHandle VG_INVALID_HANDLE = 0;

static const VGint VG_PATH_FORMAT_STANDARD = 0;

typedef enum {
  VG_PATH_DATATYPE_S_8                        =  0,
  VG_PATH_DATATYPE_S_16                       =  1,
  VG_PATH_DATATYPE_S_32                       =  2,
  VG_PATH_DATATYPE_F                          =  3,

  VG_PATH_DATATYPE_FORCE_SIZE                 = VG_MAX_ENUM
} VGPathDatatype;

typedef enum {
  VG_PATH_CAPABILITY_APPEND_FROM              = (1 <<  0),
  VG_PATH_CAPABILITY_APPEND_TO                = (1 <<  1),
  VG_PATH_CAPABILITY_MODIFY                   = (1 <<  2),
  VG_PATH_CAPABILITY_TRANSFORM_FROM           = (1 <<  3),
  VG_PATH_CAPABILITY_TRANSFORM_TO             = (1 <<  4),
  VG_PATH_CAPABILITY_INTERPOLATE_FROM         = (1 <<  5),
  VG_PATH_CAPABILITY_INTERPOLATE_TO           = (1 <<  6),
  VG_PATH_CAPABILITY_PATH_LENGTH              = (1 <<  7),
  VG_PATH_CAPABILITY_POINT_ALONG_PATH         = (1 <<  8),
  VG_PATH_CAPABILITY_TANGENT_ALONG_PATH       = (1 <<  9),
  VG_PATH_CAPABILITY_PATH_BOUNDS              = (1 << 10),
  VG_PATH_CAPABILITY_PATH_TRANSFORMED_BOUNDS  = (1 << 11),
  VG_PATH_CAPABILITY_ALL                      = (1 << 12) - 1,

  VG_PATH_CAPABILITIES_FORCE_SIZE             = VG_MAX_ENUM
} VGPathCapabilities;

VGPath vgCreatePath(VGint pathFormat,
                    VGPathDatatype datatype,
                    VGfloat scale, VGfloat bias,
                    VGint segmentCapacityHint,
                    VGint coordCapacityHint,
                    VGbitfield capabilities);
]]

local path = vg.vgCreatePath(vg.VG_PATH_FORMAT_STANDARD,
                             vg.VG_PATH_DATATYPE_F,
                             1.0, 0.0,
                             0, 0,
                             vg.VG_PATH_CAPABILITY_ALL)
assert(path ~= vg.VG_INVALID_HANDLE, "vgCreatePath() failed")
log('vgCreatePath(...) -> 0x%x', path)

ffi.cdef [[
typedef enum {
  VGU_NO_ERROR                                 = 0,
  VGU_BAD_HANDLE_ERROR                         = 0xF000,
  VGU_ILLEGAL_ARGUMENT_ERROR                   = 0xF001,
  VGU_OUT_OF_MEMORY_ERROR                      = 0xF002,
  VGU_PATH_CAPABILITY_ERROR                    = 0xF003,
  VGU_BAD_WARP_ERROR                           = 0xF004,

  VGU_ERROR_CODE_FORCE_SIZE                    = VG_MAX_ENUM
} VGUErrorCode;

VGUErrorCode vguLine(VGPath path,
                     VGfloat x0, VGfloat y0,
                     VGfloat x1, VGfloat y1);
]]

log('vguLine(0x%x, ...)+', path)

local unit = 32
local cx = dmx.info.width/2
local cy = dmx.info.height/2
local steps = math.floor(cy/unit)
for i=0,steps do
   vg.vguLine(path, cx, cy+((steps-i)*unit), cx+i*unit, cy)
   vg.vguLine(path, cx, cy-((steps-i)*unit), cx+i*unit, cy)
   vg.vguLine(path, cx, cy+((steps-i)*unit), cx-i*unit, cy)
   vg.vguLine(path, cx, cy-((steps-i)*unit), cx-i*unit, cy)
end

ffi.cdef [[
void vgDrawPath(VGPath path, VGbitfield paintModes);
]]

vg.vgDrawPath(path, vg.VG_STROKE_PATH)
log('vgDrawPath(0x%x, VG_STROKE_PATH)', path)

ffi.cdef [[
void vgDestroyPath(VGPath path);
]]

vg.vgDestroyPath(path)
log('vgDestroyPath(0x%x)', path)

ffi.cdef [[
EGLBoolean eglSwapBuffers(EGLDisplay dpy, EGLSurface surface);
]]

egl.eglSwapBuffers(dpy, surface)
log('eglSwapBuffers()')

ffi.cdef [[
int getchar();
]]

log('waiting for input with getchar(): press Enter to continue')
ffi.C.getchar()

ffi.cdef [[
EGLBoolean eglDestroyContext(EGLDisplay dpy, EGLContext ctx);
]]

egl.eglDestroyContext(dpy, ctx)
log('eglDestroyContext()')

ffi.cdef [[
EGLBoolean eglDestroySurface(EGLDisplay dpy, EGLSurface surface);
]]

egl.eglDestroySurface(dpy, surface)
log('eglDestroySurface()')

ffi.cdef [[
int vc_dispmanx_display_close( DISPMANX_DISPLAY_HANDLE_T display );
]]

bcm_host.vc_dispmanx_display_close(dmx.dpy)
log('vc_dispmanx_display_close()')

ffi.cdef [[
EGLBoolean eglReleaseThread(void);
EGLBoolean eglTerminate(EGLDisplay dpy);
]]

egl.eglReleaseThread()
log('eglReleaseThread()')
egl.eglTerminate(dpy)
log('eglTerminate()')

ffi.cdef [[
void bcm_host_deinit(void);
]]

bcm_host.bcm_host_deinit()
log('bcm_host_deinit()')
