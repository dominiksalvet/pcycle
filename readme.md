# pCycle

<p align="center">
    <img src="doc/img/pipeline.png" alt="pCycle pipeline" width="470">
</p>

pCycle (pronounced "pico cycle") processor was created in 2015 after building a [redstone processor in Minecraft](https://www.planetminecraft.com/project/redstone-computer-5684172). The main purpose of pCycle was to apply knowledge gained from that game into real RTL design. As pCycle was my first custom VHDL processor, it was designed in a simple manner and contains a lot of beginner mistakes. Nevertheless, its code was tested on a Cyclone II FPGA at the time.

The processor itself is 4-bit and uses the accumulator architecture. Some of its highlights:

* Harvard architecture
* All instructions are 8 bits wide
* All data are 4 bits wide
* Simple I/O ports

## Useful Resources

* [support.md](support.md) – questions, answers, help
* [contributing.md](contributing.md) – how to get involve
* [license](license) – author and license
