local ffi = require("ffi")
local bit = require("bit")
local bcm_host = require("bcm_host")
local jpeg = require("jpeg")

ffi.cdef [[
typedef struct {
  uint32_t width;
  uint32_t height;
  VC_IMAGE_TYPE_T type;
} piper_image_ImageInfo;
]]

local loaders = {}

function loaders.jpeg(path)
   local cinfo = ffi.new("struct jpeg_decompress_struct")
   local jerr = ffi.new("struct jpeg_error_mgr")
   cinfo.err = jpeg.jpeg_std_error(jerr)
   jpeg.jpeg_create_decompress(cinfo)
   local f = io.open(path, "rb")
   jpeg.jpeg_stdio_src(cinfo, f)
   local loader = {}
   function loader.read_image_info()
      jpeg.jpeg_read_header(cinfo, true)
      local image_info = ffi.new("piper_image_ImageInfo")
      image_info.width = cinfo.image_width
      image_info.height = cinfo.image_height
      if cinfo.num_components == 1 then
         image_info.type = bcm_host.VC_IMAGE_TF_Y8
      elseif cinfo.num_components == 3 then
         image_info.type = bcm_host.VC_IMAGE_RGB888
      else
         error("can't determine image_info.type")
      end
      return image_info
   end
   function loader.read_image(target)
      print("jpeg_start_decompress")
      jpeg.jpeg_start_decompress(cinfo)
      print(string.format("allocating jsamprow: output_width=%d, output_components=%d", cinfo.output_width, cinfo.output_components))
      local jsamprow = ffi.new("JSAMPLE[?]", cinfo.output_width * cinfo.output_components)
      local jsamparray = ffi.new("JSAMPROW[1]", jsamprow)
      assert(tonumber(jsamparray[0]) == tonumber(jsamprow))
      local lines_read = 0
      repeat
         --print("read scanline #"..tostring(lines_read))
         local n = jpeg.jpeg_read_scanlines(cinfo, jsamparray, 1)
         --print(string.format("read %d lines", n))
         lines_read = lines_read + n
         --print("process scanline")
         target.process_scanline(jsamprow)
      until lines_read == cinfo.output_height
      print("jpeg_finish_decompress")
      jpeg.jpeg_finish_decompress(cinfo)
   end
   function loader.free()
      f.close()
      jpeg.jpeg_destroy_decompress(cinfo)
   end
   return loader
end

local function build_loader(path)
   if string.sub(path,-4)=='.jpg' then
      return loaders.jpeg(path)
   else
      error('cannot find loader for '..path)
   end
end

local targets = {}

local image_type_to_component_size_map = {
   [tonumber(bcm_host.VC_IMAGE_TF_Y8)] = 1,
   [tonumber(bcm_host.VC_IMAGE_RGB888)] = 3,
}

local function image_type_to_component_size(type)
   local component_size = image_type_to_component_size_map[tonumber(type)]
   if not component_size then
      error("image_type_to_component_size() failed for type="..tostring(type))
   end
   return component_size
end

function targets.dispmanx_resource(image_info)
   local native_image_handle = ffi.new("uint32_t[1]")
   print(string.format("vc_dispmanx_resource_create(%d,%d,%d)",
                       tonumber(image_info.type),
                       image_info.width,
                       image_info.height))
   local res = bcm_host.vc_dispmanx_resource_create(image_info.type,
                                                    image_info.width,
                                                    image_info.height,
                                                    native_image_handle)
   assert(res ~= bcm_host.DISPMANX_NO_HANDLE)
   local src_type = image_info.type
   local src_pitch = image_info.width * image_type_to_component_size(image_info.type)
   local copy_rect = ffi.new("VC_RECT_T", 0, 0, image_info.width, 1)
   local target = {}
   function target.process_scanline(line)
      local src_address = line - src_pitch*copy_rect.y
      assert(src_address + src_pitch*copy_rect.y == line)
      --print(string.format("target.process_scanline: src_type=%s,src_pitch=%s,dst_rect=(%d,%d,%d,%d)", src_type, src_pitch, copy_rect.x, copy_rect.y, copy_rect.width, copy_rect.height))
      local rv = bcm_host.vc_dispmanx_resource_write_data(res,
                                                          src_type,
                                                          src_pitch,
                                                          src_address,
                                                          copy_rect)
      assert(rv==0)
      copy_rect.y = copy_rect.y + 1
   end
   function target.data()
      local rect = ffi.new("VC_RECT_T",
                           0,
                           0,
                           bit.lshift(image_info.width,16),
                           bit.lshift(image_info.height,16))
      return res, rect
   end
   return target
end

local function build_target(target_type, image_info)
   local builder = targets[target_type]
   if not builder then
      error("invalid target type: "..target_type, 2)
   end
   return builder(image_info)
end

local image = {}

function image.load(path, target_type)
   print("build_loader("..path..")")
   local loader = build_loader(path)
   print("loader.read_image_info()")
   local image_info = loader.read_image_info()
   print("image_info.width = "..tostring(image_info.width))
   print("image_info.height = "..tostring(image_info.height))
   print("image_info.type = "..tonumber(image_info.type))
   print("build_target("..target_type..",image_info")
   local target = build_target(target_type, image_info)
   print("read_image(target)")
   loader.read_image(target)
   print("loader.free()")
   loader.free()
   print("returning target.data()")
   return target.data()
end

return image
