require("rpilibs")
local ffi = require("ffi")
local bit = require("bit")

ffi.cdef [[

static const int WFC_DEFAULT_SCREEN_NUMBER = 0;

typedef enum {
   WFC_FALSE               = 0,
   WFC_TRUE                = 1,
   WFC_BOOLEAN_FORCE_32BIT = 0x7FFFFFFF
} WFCboolean;

typedef int32_t   WFCint;
typedef float     WFCfloat;
typedef uint32_t  WFCbitfield;
typedef uint32_t  WFCHandle;

typedef void     *WFCEGLDisplay;
typedef void     *WFCEGLSync;  /* An opaque handle to an EGLSyncKHR */
typedef WFCHandle WFCNativeStreamType;

static const int OPENWFC_VERSION_1_0   = 1;

static const int WFC_NONE              = 0;
static const int WFC_INVALID_HANDLE    = 0;
static const int WFC_DEFAULT_DEVICE_ID = 0;

static const int WFC_MAX_INT   = (WFCint)   16777216;
static const int WFC_MAX_FLOAT = (WFCfloat) 16777216;

typedef WFCHandle WFCDevice;
typedef WFCHandle WFCContext;
typedef WFCHandle WFCSource;
typedef WFCHandle WFCMask;
typedef WFCHandle WFCElement;

typedef enum {
    WFC_ERROR_NONE                          = 0,
    WFC_ERROR_OUT_OF_MEMORY                 = 0x7001,
    WFC_ERROR_ILLEGAL_ARGUMENT              = 0x7002,
    WFC_ERROR_UNSUPPORTED                   = 0x7003,
    WFC_ERROR_BAD_ATTRIBUTE                 = 0x7004,
    WFC_ERROR_IN_USE                        = 0x7005,
    WFC_ERROR_BUSY                          = 0x7006,
    WFC_ERROR_BAD_DEVICE                    = 0x7007,
    WFC_ERROR_BAD_HANDLE                    = 0x7008,
    WFC_ERROR_INCONSISTENCY                 = 0x7009,
    WFC_ERROR_FORCE_32BIT                   = 0x7FFFFFFF
} WFCErrorCode;

typedef enum {
    WFC_DEVICE_FILTER_SCREEN_NUMBER         = 0x7020,
    WFC_DEVICE_FILTER_FORCE_32BIT           = 0x7FFFFFFF
} WFCDeviceFilter;

typedef enum {
    /* Read-only */
    WFC_DEVICE_CLASS                        = 0x7030,
    WFC_DEVICE_ID                           = 0x7031,
    WFC_DEVICE_FORCE_32BIT                  = 0x7FFFFFFF
} WFCDeviceAttrib;

typedef enum {
    WFC_DEVICE_CLASS_FULLY_CAPABLE          = 0x7040,
    WFC_DEVICE_CLASS_OFF_SCREEN_ONLY        = 0x7041,
    WFC_DEVICE_CLASS_FORCE_32BIT            = 0x7FFFFFFF
} WFCDeviceClass;

typedef enum {
    /* Read-only */
    WFC_CONTEXT_TYPE                        = 0x7051,
    WFC_CONTEXT_TARGET_HEIGHT               = 0x7052,
    WFC_CONTEXT_TARGET_WIDTH                = 0x7053,
    WFC_CONTEXT_LOWEST_ELEMENT              = 0x7054,

    /* Read-write */
    WFC_CONTEXT_ROTATION                    = 0x7061,
    WFC_CONTEXT_BG_COLOR                    = 0x7062,
    WFC_CONTEXT_FORCE_32BIT                 = 0x7FFFFFFF
} WFCContextAttrib;

typedef enum {
    WFC_CONTEXT_TYPE_ON_SCREEN              = 0x7071,
    WFC_CONTEXT_TYPE_OFF_SCREEN             = 0x7072,
    WFC_CONTEXT_TYPE_FORCE_32BIT            = 0x7FFFFFFF
} WFCContextType;

typedef enum {
    /* Clockwise rotation */
    WFC_ROTATION_0                          = 0x7081,  /* default */
    WFC_ROTATION_90                         = 0x7082,
    WFC_ROTATION_180                        = 0x7083,
    WFC_ROTATION_270                        = 0x7084,
    WFC_ROTATION_FORCE_32BIT                = 0x7FFFFFFF
} WFCRotation;

typedef enum {
    WFC_ELEMENT_DESTINATION_RECTANGLE       = 0x7101,
    WFC_ELEMENT_SOURCE                      = 0x7102,
    WFC_ELEMENT_SOURCE_RECTANGLE            = 0x7103,
    WFC_ELEMENT_SOURCE_FLIP                 = 0x7104,
    WFC_ELEMENT_SOURCE_ROTATION             = 0x7105,
    WFC_ELEMENT_SOURCE_SCALE_FILTER         = 0x7106,
    WFC_ELEMENT_TRANSPARENCY_TYPES          = 0x7107,
    WFC_ELEMENT_GLOBAL_ALPHA                = 0x7108,
    WFC_ELEMENT_MASK                        = 0x7109,
    WFC_ELEMENT_FORCE_32BIT                 = 0x7FFFFFFF
} WFCElementAttrib;

typedef enum {
    WFC_SCALE_FILTER_NONE                   = 0x7151,  /* default */
    WFC_SCALE_FILTER_FASTER                 = 0x7152,
    WFC_SCALE_FILTER_BETTER                 = 0x7153,
    WFC_SCALE_FILTER_FORCE_32BIT            = 0x7FFFFFFF
} WFCScaleFilter;

typedef enum {
    WFC_TRANSPARENCY_NONE                   = 0,       /* default */
    WFC_TRANSPARENCY_ELEMENT_GLOBAL_ALPHA   = (1 << 0),
    WFC_TRANSPARENCY_SOURCE                 = (1 << 1),
    WFC_TRANSPARENCY_MASK                   = (1 << 2),
    WFC_TRANSPARENCY_FORCE_32BIT            = 0x7FFFFFFF
} WFCTransparencyType;

typedef enum {
    WFC_VENDOR                              = 0x7200,
    WFC_RENDERER                            = 0x7201,
    WFC_VERSION                             = 0x7202,
    WFC_EXTENSIONS                          = 0x7203,
    WFC_STRINGID_FORCE_32BIT                = 0x7FFFFFFF
} WFCStringID;


/* Function Prototypes */

/* Device */
WFCint      wfcEnumerateDevices(WFCint *deviceIds, WFCint deviceIdsCount,
                                const WFCint *filterList);
WFCDevice    wfcCreateDevice(WFCint deviceId, const WFCint *attribList);
WFCErrorCode wfcGetError(WFCDevice dev);
WFCint       wfcGetDeviceAttribi(WFCDevice dev, WFCDeviceAttrib attrib);
WFCErrorCode wfcDestroyDevice(WFCDevice dev);

/* Context */
WFCContext wfcCreateOnScreenContext(WFCDevice dev,
                                    WFCint screenNumber,
                                    const WFCint *attribList);
WFCContext wfcCreateOffScreenContext(WFCDevice dev,
                                     WFCNativeStreamType stream,
                                     const WFCint *attribList);
void       wfcCommit(WFCDevice dev, WFCContext ctx, WFCboolean wait);
WFCint     wfcGetContextAttribi(WFCDevice dev, WFCContext ctx,
                                WFCContextAttrib attrib);
void       wfcGetContextAttribfv(WFCDevice dev, WFCContext ctx,
                                 WFCContextAttrib attrib, WFCint count,
                                 WFCfloat *values);
void       wfcSetContextAttribi(WFCDevice dev, WFCContext ctx,
                                WFCContextAttrib attrib, WFCint value);
void       wfcSetContextAttribfv(WFCDevice dev, WFCContext ctx,
                                 WFCContextAttrib attrib,
                                 WFCint count, const WFCfloat *values);
void       wfcDestroyContext(WFCDevice dev, WFCContext ctx);

/* Source */
WFCSource  wfcCreateSourceFromStream(WFCDevice dev, WFCContext ctx,
                                     WFCNativeStreamType stream,
                                     const WFCint *attribList);
void       wfcDestroySource(WFCDevice dev, WFCSource src);

/* Mask */
WFCMask    wfcCreateMaskFromStream(WFCDevice dev, WFCContext ctx,
                                   WFCNativeStreamType stream,
                                   const WFCint *attribList);
void       wfcDestroyMask(WFCDevice dev, WFCMask mask);

/* Element */
WFCElement wfcCreateElement(WFCDevice dev, WFCContext ctx,
                            const WFCint *attribList);
WFCint     wfcGetElementAttribi(WFCDevice dev, WFCElement element,
                                WFCElementAttrib attrib);
WFCfloat   wfcGetElementAttribf(WFCDevice dev, WFCElement element,
                                WFCElementAttrib attrib);
void       wfcGetElementAttribiv(WFCDevice dev, WFCElement element,
                                 WFCElementAttrib attrib, WFCint count,
                                 WFCint *values);
void       wfcGetElementAttribfv(WFCDevice dev, WFCElement element,
                                 WFCElementAttrib attrib, WFCint count,
                                 WFCfloat *values);
void       wfcSetElementAttribi(WFCDevice dev, WFCElement element,
                                WFCElementAttrib attrib, WFCint value);
void       wfcSetElementAttribf(WFCDevice dev, WFCElement element,
                                WFCElementAttrib attrib, WFCfloat value);
void       wfcSetElementAttribiv(WFCDevice dev, WFCElement element,
                                 WFCElementAttrib attrib,
                                 WFCint count, const WFCint *values);
void       wfcSetElementAttribfv(WFCDevice dev, WFCElement element,
                                 WFCElementAttrib attrib,
                                 WFCint count, const WFCfloat *values);
void       wfcInsertElement(WFCDevice dev, WFCElement element,
                            WFCElement subordinate);
void       wfcRemoveElement(WFCDevice dev, WFCElement element);
WFCElement wfcGetElementAbove(WFCDevice dev, WFCElement element);
WFCElement wfcGetElementBelow(WFCDevice dev, WFCElement element);
void       wfcDestroyElement(WFCDevice dev, WFCElement element);

/* Rendering */
void       wfcActivate(WFCDevice dev, WFCContext ctx);
void       wfcDeactivate(WFCDevice dev, WFCContext ctx);
void       wfcCompose(WFCDevice dev, WFCContext ctx, WFCboolean wait);
void       wfcFence(WFCDevice dev, WFCContext ctx, WFCEGLDisplay dpy,
                    WFCEGLSync sync);

/* Renderer and extension information */
WFCint     wfcGetStrings(WFCDevice dev,
                         WFCStringID name,
                         const char **strings,
                         WFCint stringsCount);
WFCboolean wfcIsExtensionSupported(WFCDevice dev, const char *string);

typedef enum
{  
   VCOS_SUCCESS,
   VCOS_EAGAIN,
   VCOS_ENOENT,
   VCOS_ENOSPC,
   VCOS_EINVAL,
   VCOS_EACCESS,
   VCOS_ENOMEM,
   VCOS_ENOSYS,
   VCOS_EEXIST,
   VCOS_ENXIO,
   VCOS_EINTR
} VCOS_STATUS_T;

VCOS_STATUS_T wfc_client_ipc_init(void);
bool wfc_client_ipc_deinit(void);

]]

require("lib.vchiq_arm")
local wfc = setmetatable({_NAME="wfc"},
                         { __index = require("lib.WFC") })

return wfc
