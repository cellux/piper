require("rpilibs")
local ffi = require("ffi")
local bit = require("bit")

ffi.cdef [[
void bcm_host_init(void);
void bcm_host_deinit(void);

/*** vc_display_types.h ***/

//enums of display input format
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

// Enum determining how image data for 3D displays has to be supplied
typedef enum
{
   DISPLAY_3D_UNSUPPORTED = 0,   // default
   DISPLAY_3D_INTERLEAVED,       // For autosteroscopic displays
   DISPLAY_3D_SBS_FULL_AUTO,     // Side-By-Side, Full Width (also used by some autostereoscopic displays)
   DISPLAY_3D_SBS_HALF_HORIZ,    // Side-By-Side, Half Width, Horizontal Subsampling (see HDMI spec)
   DISPLAY_3D_TB_HALF,           // Top-bottom 3D
   DISPLAY_3D_FORMAT_MAX
} DISPLAY_3D_FORMAT_T;

//enums of display types
typedef enum
{
   DISPLAY_INTERFACE_MIN,
   DISPLAY_INTERFACE_SMI,
   DISPLAY_INTERFACE_DPI,
   DISPLAY_INTERFACE_DSI,
   DISPLAY_INTERFACE_LVDS,
   DISPLAY_INTERFACE_MAX

} DISPLAY_INTERFACE_T;

/* display dither setting, used on B0 */
typedef enum {
   DISPLAY_DITHER_NONE   = 0,   /* default if not set */
   DISPLAY_DITHER_RGB666 = 1,
   DISPLAY_DITHER_RGB565 = 2,
   DISPLAY_DITHER_RGB555 = 3,
   DISPLAY_DITHER_MAX
} DISPLAY_DITHER_T;

//info struct
typedef struct
{
   //type
   DISPLAY_INTERFACE_T type;
   //width / height
   uint32_t width;
   uint32_t height;
   //output format
   DISPLAY_INPUT_FORMAT_T input_format;
   //interlaced?
   uint32_t interlaced;
   /* output dither setting (if required) */
   DISPLAY_DITHER_T output_dither;
   /* Pixel frequency */
   uint32_t pixel_freq;
   /* Line rate in lines per second */
   uint32_t line_rate;
   // Format required for image data for 3D displays
   DISPLAY_3D_FORMAT_T format_3d;
   // If display requires PV1 (e.g. DSI1), special config is required in HVS
   uint32_t use_pixelvalve_1;
   // Set for DSI displays which use video mode.
   uint32_t dsi_video_mode;
   // Select HVS channel (usually 0).
   uint32_t hvs_channel;
} DISPLAY_INFO_T;

/*** vc_image_types.h ***/

typedef struct tag_VC_RECT_T {
   int32_t x;
   int32_t y;
   int32_t width;
   int32_t height;
} VC_RECT_T;

struct VC_IMAGE_T;
typedef struct VC_IMAGE_T VC_IMAGE_T;

typedef enum
{
   VC_IMAGE_MIN = 0, //bounds for error checking

   VC_IMAGE_RGB565 = 1,
   VC_IMAGE_1BPP,
   VC_IMAGE_YUV420,
   VC_IMAGE_48BPP,
   VC_IMAGE_RGB888,
   VC_IMAGE_8BPP,
   VC_IMAGE_4BPP,    // 4bpp palettised image
   VC_IMAGE_3D32,    /* A separated format of 16 colour/light shorts followed by 16 z values */
   VC_IMAGE_3D32B,   /* 16 colours followed by 16 z values */
   VC_IMAGE_3D32MAT, /* A separated format of 16 material/colour/light shorts followed by 16 z values */
   VC_IMAGE_RGB2X9,   /* 32 bit format containing 18 bits of 6.6.6 RGB, 9 bits per short */
   VC_IMAGE_RGB666,   /* 32-bit format holding 18 bits of 6.6.6 RGB */
   VC_IMAGE_PAL4_OBSOLETE,     // 4bpp palettised image with embedded palette
   VC_IMAGE_PAL8_OBSOLETE,     // 8bpp palettised image with embedded palette
   VC_IMAGE_RGBA32,   /* RGB888 with an alpha byte after each pixel */ /* xxx: isn't it BEFORE each pixel? */
   VC_IMAGE_YUV422,   /* a line of Y (32-byte padded), a line of U (16-byte padded), and a line of V (16-byte padded) */
   VC_IMAGE_RGBA565,  /* RGB565 with a transparent patch */
   VC_IMAGE_RGBA16,   /* Compressed (4444) version of RGBA32 */
   VC_IMAGE_YUV_UV,   /* VCIII codec format */
   VC_IMAGE_TF_RGBA32, /* VCIII T-format RGBA8888 */
   VC_IMAGE_TF_RGBX32,  /* VCIII T-format RGBx8888 */
   VC_IMAGE_TF_FLOAT, /* VCIII T-format float */
   VC_IMAGE_TF_RGBA16, /* VCIII T-format RGBA4444 */
   VC_IMAGE_TF_RGBA5551, /* VCIII T-format RGB5551 */
   VC_IMAGE_TF_RGB565, /* VCIII T-format RGB565 */
   VC_IMAGE_TF_YA88, /* VCIII T-format 8-bit luma and 8-bit alpha */
   VC_IMAGE_TF_BYTE, /* VCIII T-format 8 bit generic sample */
   VC_IMAGE_TF_PAL8, /* VCIII T-format 8-bit palette */
   VC_IMAGE_TF_PAL4, /* VCIII T-format 4-bit palette */
   VC_IMAGE_TF_ETC1, /* VCIII T-format Ericsson Texture Compressed */
   VC_IMAGE_BGR888,  /* RGB888 with R & B swapped */
   VC_IMAGE_BGR888_NP,  /* RGB888 with R & B swapped, but with no pitch, i.e. no padding after each row of pixels */
   VC_IMAGE_BAYER,  /* Bayer image, extra defines which variant is being used */
   VC_IMAGE_CODEC,  /* General wrapper for codec images e.g. JPEG from camera */
   VC_IMAGE_YUV_UV32,   /* VCIII codec format */
   VC_IMAGE_TF_Y8,   /* VCIII T-format 8-bit luma */
   VC_IMAGE_TF_A8,   /* VCIII T-format 8-bit alpha */
   VC_IMAGE_TF_SHORT,/* VCIII T-format 16-bit generic sample */
   VC_IMAGE_TF_1BPP, /* VCIII T-format 1bpp black/white */
   VC_IMAGE_OPENGL,
   VC_IMAGE_YUV444I, /* VCIII-B0 HVS YUV 4:4:4 interleaved samples */
   VC_IMAGE_YUV422PLANAR,  /* Y, U, & V planes separately (VC_IMAGE_YUV422 has them interleaved on a per line basis) */
   VC_IMAGE_ARGB8888,   /* 32bpp with 8bit alpha at MS byte, with R, G, B (LS byte) */
   VC_IMAGE_XRGB8888,   /* 32bpp with 8bit unused at MS byte, with R, G, B (LS byte) */

   VC_IMAGE_YUV422YUYV,  /* interleaved 8 bit samples of Y, U, Y, V */
   VC_IMAGE_YUV422YVYU,  /* interleaved 8 bit samples of Y, V, Y, U */
   VC_IMAGE_YUV422UYVY,  /* interleaved 8 bit samples of U, Y, V, Y */
   VC_IMAGE_YUV422VYUY,  /* interleaved 8 bit samples of V, Y, U, Y */

   VC_IMAGE_RGBX32,      /* 32bpp like RGBA32 but with unused alpha */
   VC_IMAGE_RGBX8888,    /* 32bpp, corresponding to RGBA with unused alpha */
   VC_IMAGE_BGRX8888,    /* 32bpp, corresponding to BGRA with unused alpha */

   VC_IMAGE_YUV420SP,    /* Y as a plane, then UV byte interleaved in plane with with same pitch, half height */
   
   VC_IMAGE_YUV444PLANAR,  /* Y, U, & V planes separately 4:4:4 */
   
   VC_IMAGE_MAX,     //bounds for error checking
   VC_IMAGE_FORCE_ENUM_16BIT = 0xffff,
} VC_IMAGE_TYPE_T;

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
{ //defined to be identical to register bits
   VC_IMAGE_BAYER_RGGB     = 0,
   VC_IMAGE_BAYER_GBRG     = 1,
   VC_IMAGE_BAYER_BGGR     = 2,
   VC_IMAGE_BAYER_GRBG     = 3
} VC_IMAGE_BAYER_ORDER_T;

typedef enum
{ //defined to be identical to register bits
   VC_IMAGE_BAYER_RAW6     = 0,
   VC_IMAGE_BAYER_RAW7     = 1,
   VC_IMAGE_BAYER_RAW8     = 2,
   VC_IMAGE_BAYER_RAW10    = 3,
   VC_IMAGE_BAYER_RAW12    = 4,
   VC_IMAGE_BAYER_RAW14    = 5,
   VC_IMAGE_BAYER_RAW16    = 6,
   VC_IMAGE_BAYER_RAW10_8  = 7,
   VC_IMAGE_BAYER_RAW12_8  = 8,
   VC_IMAGE_BAYER_RAW14_8  = 9,
   VC_IMAGE_BAYER_RAW10L   = 11,
   VC_IMAGE_BAYER_RAW12L   = 12,
   VC_IMAGE_BAYER_RAW14L   = 13,
   VC_IMAGE_BAYER_RAW16_BIG_ENDIAN = 14, 
   VC_IMAGE_BAYER_RAW4    = 15,
} VC_IMAGE_BAYER_FORMAT_T;

/*** vc_dispmanx_types.h ***/

static const int VC_DISPMANX_VERSION = 1;

// Opaque handles
typedef uint32_t DISPMANX_DISPLAY_HANDLE_T;
typedef uint32_t DISPMANX_UPDATE_HANDLE_T;
typedef uint32_t DISPMANX_ELEMENT_HANDLE_T;
typedef uint32_t DISPMANX_RESOURCE_HANDLE_T;

typedef uint32_t DISPMANX_PROTECTION_T;

static const uint32_t DISPMANX_NO_HANDLE = 0;

static const uint32_t DISPMANX_PROTECTION_MAX   = 0x0f;
static const uint32_t DISPMANX_PROTECTION_NONE  = 0;

// Derived from the WM DRM levels, 101-300
static const uint32_t DISPMANX_PROTECTION_HDCP  = 11;

/* Default display IDs.
   Note: if you overwrite with you own dispmanx_platfrom_init function, you
   should use IDs you provided during dispmanx_display_attach.
*/
static const int DISPMANX_ID_MAIN_LCD  = 0;
static const int DISPMANX_ID_AUX_LCD   = 1;
static const int DISPMANX_ID_HDMI      = 2;
static const int DISPMANX_ID_SDTV      = 3;

// Return codes. Nonzero ones indicate failure.
typedef enum {
  DISPMANX_SUCCESS      = 0,
  DISPMANX_INVALID      = -1
} DISPMANX_STATUS_T;

typedef enum {
  /* Bottom 2 bits sets the orientation */
  DISPMANX_NO_ROTATE = 0,
  DISPMANX_ROTATE_90 = 1,
  DISPMANX_ROTATE_180 = 2,
  DISPMANX_ROTATE_270 = 3,

  DISPMANX_FLIP_HRIZ = 1 << 16,
  DISPMANX_FLIP_VERT = 1 << 17
} DISPMANX_TRANSFORM_T;

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
  VC_IMAGE_T *mask;
} DISPMANX_ALPHA_T;

typedef struct {
  DISPMANX_FLAGS_ALPHA_T flags;
  uint32_t opacity;
  DISPMANX_RESOURCE_HANDLE_T mask;
} VC_DISPMANX_ALPHA_T;  /* for use with vmcs_host */

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

typedef struct {
  int32_t width;
  int32_t height;
  VC_IMAGE_TRANSFORM_T transform;
  DISPLAY_INPUT_FORMAT_T input_format;
} DISPMANX_MODEINFO_T;

// Update callback.
typedef void (*DISPMANX_CALLBACK_FUNC_T)(DISPMANX_UPDATE_HANDLE_T u, void * arg);

// Progress callback
typedef void (*DISPMANX_PROGRESS_CALLBACK_FUNC_T)(DISPMANX_UPDATE_HANDLE_T u,
                                                  uint32_t line,
                                                  void * arg);

// Pluggable display interface

typedef struct tag_DISPMANX_DISPLAY_FUNCS_T {
   // Get essential HVS configuration to be passed to the HVS driver. Options
   // is any combination of the following flags: HVS_ONESHOT, HVS_FIFOREG,
   // HVS_FIFO32, HVS_AUTOHSTART, HVS_INTLACE; and if HVS_FIFOREG, one of;
   // { HVS_FMT_RGB888, HVS_FMT_RGB565, HVS_FMT_RGB666, HVS_FMT_YUV }.
   int32_t (*get_hvs_config)(void *instance, uint32_t *pchan,
                             uint32_t *poptions, DISPLAY_INFO_T *info,
                             uint32_t *bg_colour, uint32_t *test_mode);
   
   // Get optional HVS configuration for gamma tables, OLED matrix and dither controls.
   // Set these function pointers to NULL if the relevant features are not required.
   int32_t (*get_gamma_params)(void * instance,
                               int32_t gain[3], int32_t offset[3], int32_t gamma[3]);
   int32_t (*get_oled_params)(void * instance, uint32_t * poffsets,
                              uint32_t coeffs[3]);
   int32_t (*get_dither)(void * instance, uint32_t * dither_depth, uint32_t * dither_type);
   
   // Get mode information, which may be returned to the applications as a courtesy.
   // Transform should be set to 0, and {width,height} should be final dimensions.
   int32_t (*get_info)(void * instance, DISPMANX_MODEINFO_T * info);
   
   // Inform driver that the application refcount has become nonzero / zero
   // These callbacks might perhaps be used for backlight and power management.
   int32_t (*open)(void * instance);
   int32_t (*close)(void * instance);
   
   // Display list updated callback. Primarily of use to a "one-shot" display.
   // For convenience of the driver, we pass the register address of the HVS FIFO.
   void (*dlist_updated)(void * instance, volatile uint32_t * fifo_reg);
   
   // End-of-field callback. This may occur in an interrupt context.
   void (*eof_callback)(void * instance);

   // Return screen resolution format
   DISPLAY_INPUT_FORMAT_T (*get_input_format)(void * instance);

   int32_t (*suspend_resume)(void *instance, int up);

   DISPLAY_3D_FORMAT_T (*get_3d_format)(void * instance);
} DISPMANX_DISPLAY_FUNCS_T;

/*** vchi_mh.h ***/

typedef int32_t VCHI_MEM_HANDLE_T;
static const int VCHI_MEM_HANDLE_INVALID = 0;

/*** vc_dispmanx.h ***/

/* Resources */

DISPMANX_RESOURCE_HANDLE_T vc_dispmanx_resource_create( VC_IMAGE_TYPE_T type,
                                                        uint32_t width,
                                                        uint32_t height,
                                                        uint32_t *native_image_handle );

int vc_dispmanx_resource_write_data( DISPMANX_RESOURCE_HANDLE_T res,
                                     VC_IMAGE_TYPE_T src_type,
                                     int src_pitch,
                                     void * src_address,
                                     const VC_RECT_T * rect );

int vc_dispmanx_resource_write_data_handle( DISPMANX_RESOURCE_HANDLE_T res,
                                            VC_IMAGE_TYPE_T src_type,
                                            int src_pitch,
                                            VCHI_MEM_HANDLE_T handle,
                                            uint32_t offset,
                                            const VC_RECT_T * rect );

int vc_dispmanx_resource_read_data( DISPMANX_RESOURCE_HANDLE_T handle,
                                    const VC_RECT_T* p_rect,
                                    void *   dst_address,
                                    uint32_t dst_pitch );

int vc_dispmanx_resource_delete( DISPMANX_RESOURCE_HANDLE_T res );

//xxx hack to get the image pointer from a resource handle, will be obsolete real soon
uint32_t vc_dispmanx_resource_get_image_handle( DISPMANX_RESOURCE_HANDLE_T res);

/* Displays */

DISPMANX_DISPLAY_HANDLE_T vc_dispmanx_display_open( uint32_t device );

DISPMANX_DISPLAY_HANDLE_T vc_dispmanx_display_open_mode( uint32_t device,
                                                         uint32_t mode );

DISPMANX_DISPLAY_HANDLE_T vc_dispmanx_display_open_offscreen( DISPMANX_RESOURCE_HANDLE_T dest,
                                                              VC_IMAGE_TRANSFORM_T orientation );

int vc_dispmanx_display_reconfigure( DISPMANX_DISPLAY_HANDLE_T display, uint32_t mode );

int vc_dispmanx_display_set_destination( DISPMANX_DISPLAY_HANDLE_T display,
                                         DISPMANX_RESOURCE_HANDLE_T dest );

int vc_dispmanx_display_set_background( DISPMANX_UPDATE_HANDLE_T update,
                                        DISPMANX_DISPLAY_HANDLE_T display,
                                        uint8_t red, uint8_t green, uint8_t blue );

int vc_dispmanx_display_get_info( DISPMANX_DISPLAY_HANDLE_T display,
                                  DISPMANX_MODEINFO_T * pinfo );

int vc_dispmanx_display_close( DISPMANX_DISPLAY_HANDLE_T display );

/* Updates */

// Start a new update, DISPMANX_NO_HANDLE on error
DISPMANX_UPDATE_HANDLE_T vc_dispmanx_update_start( int32_t priority );

// Add an elment to a display as part of an update
DISPMANX_ELEMENT_HANDLE_T vc_dispmanx_element_add ( DISPMANX_UPDATE_HANDLE_T update,
                                                    DISPMANX_DISPLAY_HANDLE_T display,
                                                    int32_t layer,
                                                    const VC_RECT_T *dest_rect,
                                                    DISPMANX_RESOURCE_HANDLE_T src,
                                                    const VC_RECT_T *src_rect,
                                                    DISPMANX_PROTECTION_T protection, 
                                                    VC_DISPMANX_ALPHA_T *alpha,
                                                    DISPMANX_CLAMP_T *clamp,
                                                    DISPMANX_TRANSFORM_T transform );

// Change the source image of a display element
int vc_dispmanx_element_change_source( DISPMANX_UPDATE_HANDLE_T update,
                                       DISPMANX_ELEMENT_HANDLE_T element,
                                       DISPMANX_RESOURCE_HANDLE_T src );

// Change the layer number of a display element
int vc_dispmanx_element_change_layer ( DISPMANX_UPDATE_HANDLE_T update,
                                       DISPMANX_ELEMENT_HANDLE_T element,
                                       int32_t layer );

// Signal that a region of the bitmap has been modified
int vc_dispmanx_element_modified( DISPMANX_UPDATE_HANDLE_T update,
                                  DISPMANX_ELEMENT_HANDLE_T element,
                                  const VC_RECT_T * rect );

// Remove a display element from its display
int vc_dispmanx_element_remove( DISPMANX_UPDATE_HANDLE_T update,
                                DISPMANX_ELEMENT_HANDLE_T element );

// Ends an update
int vc_dispmanx_update_submit( DISPMANX_UPDATE_HANDLE_T update,
                               DISPMANX_CALLBACK_FUNC_T cb_func,
                               void *cb_arg );

// End an update and wait for it to complete
int vc_dispmanx_update_submit_sync( DISPMANX_UPDATE_HANDLE_T update );

//New function added to VCHI to change attributes, set_opacity does not work there.
int vc_dispmanx_element_change_attributes( DISPMANX_UPDATE_HANDLE_T update, 
                                           DISPMANX_ELEMENT_HANDLE_T element,
                                           uint32_t change_flags,
                                           int32_t layer,
                                           uint8_t opacity,
                                           const VC_RECT_T *dest_rect,
                                           const VC_RECT_T *src_rect,
                                           DISPMANX_RESOURCE_HANDLE_T mask,
                                           VC_IMAGE_TRANSFORM_T transform );

/* Helper functions */

int vc_dispmanx_rect_set( VC_RECT_T *rect,
                          uint32_t x_offset,
                          uint32_t y_offset,
                          uint32_t width,
                          uint32_t height );

// Query the image formats supported in the VMCS build
int vc_dispmanx_query_image_formats( uint32_t *supported_formats );

// Take a snapshot of a display in its current state.
// This call may block for a time; when it completes, the snapshot is ready.
int vc_dispmanx_snapshot( DISPMANX_DISPLAY_HANDLE_T display, 
                          DISPMANX_RESOURCE_HANDLE_T snapshot_resource, 
                          VC_IMAGE_TRANSFORM_T transform );

/*** egl_platform.h ***/

typedef struct {
   DISPMANX_ELEMENT_HANDLE_T element;
   int width;
   int height;
} EGL_DISPMANX_WINDOW_T;

]]

-- bcm_host depends on vcos
require("lib.vcos")
local lib_bcm_host = require("lib.bcm_host")
local bcm_host = setmetatable({ _NAME = "bcm_host" },
                              { __index = lib_bcm_host })

function bcm_host.wrap(f)
   local w = function()
      bcm_host.bcm_host_init()
      local rv,e = pcall(f)
      bcm_host.bcm_host_deinit()
      if not rv then error(e,0) end
   end
   return w
end

return bcm_host
