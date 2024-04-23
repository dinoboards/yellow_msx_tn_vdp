# V9958 - Super

This repo contains the Verilog code to emulate Yamaha's V9958 Video Display Processor.  Its was forked from the project [tn_vdp](https://github.com/lfantoniosi/tn_vdp) (derived from V3).

Its designed specifically for a [Yellow MSX System](https://www.tindie.com/stores/dinotron/) kit, based on the Tang Nano 20K FPGA module.  (Board is still under development)

## Objective

1. To provide the RC2014 (specifically the Yellow MSX series) to have HDMI output of an emulated Yamaha V9958 Graphic Video Display Processor
2. Provide enhanced graphics modes with more colours and resolution that the original V9958 supported.

## Key Features

* Compatible with RC2014 (enhanced bus required)
* HDMI output
* Onboard ADC for HDMI audio delivery
* Extended Video modes (supported by a patched MSX-BASIC ROM for the Yellow MSX platform)
* WS2812 RGB LEDs

<img src="./docs/pcb-render.png" width="50%"/>

## Schematic

The current version of the schematic can be found here

* [Schematic](./docs/SCHEMATIC.pdf)
* [PCB IMAGE](./docs/PCB-IMAGE.pdf)

### New Graphics Modes

New 'Super' Display modes -- New hardware registers available for applications to enable higher (super) resolution and colour modes.

A MSX-BASIC patches and extensions are available for the Embedded ROM of the [Yellow MSX System](https://github.com/vipoo/yellow-msx-series-for-rc2014) (Work in progress 2024-04-21).

The new Resolutions under development are:

* 24 bit RGB colour - 3 bytes per pixel - resolution of 50Hz:180x144 (77760/103680 Bytes), 60Hz:180x120 (64800/86400 bytes)
* 16 bit RGB colour - 2 bytes per pixel - resolution of 50Hz:360x288 (207360 Bytes), 60Hz:360x240 (172800 bytes)
* 8 bit RGB colour - 1 byte per pixel - resolution of 50Hz:720x576 (414720 Bytes), 60Hz:720x480 (345600 bytes)

See [docs/vdp_super_res.md](./docs/vdp_super_res.md) for more details.

## Building using the Command Line

There is a TCL script that contains the required configuration to build the file stream (fs) for the Tang Nano.

Current scripts assume a specific install path for Gowin and only supports running under windows

Make sure you have Gowin IDE install to `C:\Gowin64`.  This should include the cli tool at: `C:\Gowin64\Gowin_V1.9.9.01_x64\IDE\bin\gw_sh.exe`

If in WSL , you can use the build.sh script to shell to windows to build:

```
build.sh
```

In in windows, run the BAT file:

```
build.bat
```

> The project may also be built using Gowin GUI IDE, by opening the file `tn_vdp.gprj`.  But please note that the GUI project may not be kept in sync with the tcl file and may be missing files or attempts to included files since deleted.
