COPY /B dd1a.1 + dd1a.2 + dd1a.3 + dd1a.4 cpu0_rom
COPY /B dd1.15 + dd1.14 + dd1.13 + dd1.12 spchip_rom
COPY /B dd1a.5 + dd1a.6 cpu1_rom
COPY /B dd1.7 cpu2_rom
COPY /B dd1.10b bgscrn_rom
COPY /B dd1.11 bgchip_rom
COPY /B dd1.9 fgchip_rom  
COPY /B 136007.110 wave_rom 
COPY /B 136007.111 spclut_rom
COPY /B 136007.112 bgclut_rom
COPY /B 136007.113 palette_rom

make_vhdl_prom cpu0_rom cpu0_rom.vhd
make_vhdl_prom spchip_rom spchip_rom.vhd
make_vhdl_prom cpu1_rom cpu1_rom.vhd
make_vhdl_prom cpu2_rom cpu2_rom.vhd
make_vhdl_prom bgscrn_rom bgscrn_rom.vhd
make_vhdl_prom bgchip_rom bgchip_rom.vhd
make_vhdl_prom fgchip_rom fgchip_rom.vhd
make_vhdl_prom wave_rom wave_rom.vhd
make_vhdl_prom spclut_rom spclut_rom.vhd
make_vhdl_prom bgclut_rom bgclut_rom.vhd
make_vhdl_prom palette_rom palette_rom.vhd

REM cpu0_rom     0x0000 - 4000h
REM spchip_rom   0x4000 - 4000h
REM cpu1_rom     0x8000 - 2000h
REM cpu2_rom     0xA000 - 1000h 
REM bgscrn_rom   0xB000 - 1000h
REM bgchip_rom   0xC000 - 1000h
REM fgchip_rom   0xD000 - 800h
REM wave_rom     0xD800 - 100h 
REM spclut_rom   0xD900 - 100h
REM bgclut_rom   0xDA00 - 100h
REM palette_rom  0xDB00 - 10h



