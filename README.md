# Piper - a demo framework for the Raspberry Pi

(warning this is highly experimental stuff - at its present stage, there is no guarantee that it will work)

The idea is to create a framework which lets me play with OpenGL ES, OpenVG and OpenMAX IL from LuaJIT.

I want a system which can render programmable, real-time video effects with 50 fps (the screen refresh rate of the Commodore 64).

If it can also do audio, that's great.

## Features

The following stuff seems to work, more or less:

* fairly complete LuaJIT bindings for:
  * bcm_host (dispmanx)
  * EGL
  * OpenGL ES
  * OpenVG
  * OpenWFC (unfortunately not properly supported yet by the RPi firmware)
  * libuv
  * libjpeg
* an `image` library for loading images (currently jpeg only, loads into a dispmanx resource)
* beginnings of a high-level `avloop` framework
  * takes care of display setup, EGL initialization, OpenGL ES/OpenVG context creation
  * the user can specify a video callback which gets called in each cycle of the rendering loop
  * the user can schedule Lua coroutines which are resumed ("stepped") once in every cycle of the rendering loop

To use this stuff, you will need a system with LuaJIT 2.0.0+, libuv, libjpeg and the Raspberry Pi userland libraries installed.

(You may use my [rpi-buildroot][] project to build such a system for yourself.)

[rpi-buildroot]: https://github.com/cellux/rpi-buildroot
