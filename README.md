# Piper - a demo framework for the Raspberry Pi

(warning this is highly experimental stuff - at this point, there is no guarantee that it will work)

The idea is to create a framework which lets me play with OpenGL ES, OpenVG and OpenMAX IL from LuaJIT.

I want a system which can render programmable, real-time video effects with a speed of 50 frames/second (the screen refresh rate of the Commodore 64).

If it can also do audio, that's great.

# Features

The following stuff seems to work, more or less:

* fairly complete LuaJIT bindings for:
** bcm_host (dispmanx)
** EGL
** OpenGL ES
** OpenVG
** OpenWFC (unfortunately not properly supported yet by the RPi firmware)
** libuv
** libjpeg
* an `image` library for loading images (currently jpeg only, loads into a dispmanx resource)
* beginnings of a high-level `avloop` framework
** takes care of display setup, EGL initialization, OpenGL ES/OpenVG context creation
** the user can specify a video callback which is called in each cycle of the rendering loop (50 fps)
** possibility to schedule Lua coroutines which are resumed once in every cycle of the rendering loop
* a simple OpenVG test app (`star.lua`)
