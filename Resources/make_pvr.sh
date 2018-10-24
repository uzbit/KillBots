#!/bin/bash

/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/texturetool -e PVRTC --channel-weighting-perceptual --bits-per-pixel-4 -m -f PVR -o $1.pvr $1.png
