---------------------------------------------------------------------------------
--                         DigDug - Tang Nano 20K
--                           Code from MiSTer-X
--
--                        Modified for Tang Nano 20K 
--                            by pinballwiz.org 
--                               29/11/2025
---------------------------------------------------------------------------------
-- Keyboard inputs :
--   5 : Add coin
--   2 : Start 2 players
--   1 : Start 1 player
--   LEFT Ctrl   : Fire
--   RIGHT arrow : Move Right
--   LEFT arrow  : Move Left
--   UP arrow    : Move Up
--   DOWN arrow  : Move Down
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity digdug_tn20k is
port(
	Clock_48    : in std_logic;
   	I_RESET     : in std_logic;
	O_VIDEO_R	: out std_logic_vector(2 downto 0); 
	O_VIDEO_G	: out std_logic_vector(2 downto 0);
	O_VIDEO_B	: out std_logic_vector(1 downto 0);
	O_HSYNC		: out std_logic;
	O_VSYNC		: out std_logic;
	O_AUDIO_L 	: out std_logic;
	O_AUDIO_R 	: out std_logic;
   	ps2_clk     : in std_logic;
	ps2_dat     : inout std_logic;
 	led         : out std_logic_vector(5 downto 0)
 );
end digdug_tn20k;
------------------------------------------------------------------------------
architecture struct of digdug_tn20k is

 signal clock_24 : std_logic;
 signal clock_12 : std_logic;
 --
 signal PCLK     : std_logic;
 signal HPOS     : std_logic_vector(8 downto 0);
 signal VPOS     : std_logic_vector(8 downto 0);
 signal oPIX     : std_logic_vector(7 downto 0);
 --
 signal video_r  : std_logic_vector(3 downto 0);
 signal video_g  : std_logic_vector(3 downto 0);
 signal video_b  : std_logic_vector(3 downto 0);
 --
 signal oRGB     : std_logic_vector(11 downto 0);
 --
 signal M_HSYNC  : std_logic;
 signal M_VSYNC	 : std_logic;
 --
 signal video_r_x2  : std_logic_vector(5 downto 0);
 signal video_g_x2  : std_logic_vector(5 downto 0);
 signal video_b_x2  : std_logic_vector(5 downto 0);
 signal hsync_x2    : std_logic;
 signal vsync_x2    : std_logic;
 --
 signal reset       : std_logic;
 --
 signal oSND        : std_logic_vector(7 downto 0);
 signal audio_pwm   : std_logic;
 --
 signal INP0        : std_logic_vector(7 downto 0);
 signal INP1        : std_logic_vector(7 downto 0);
 --
 signal kbd_intr        : std_logic;
 signal kbd_scancode    : std_logic_vector(7 downto 0);
 signal joy_BBBBFRLDU   : std_logic_vector(8 downto 0);
 --
 constant CLOCK_FREQ    : integer := 27E6;
 signal counter_clk     : std_logic_vector(25 downto 0);
 signal clock_4hz       : std_logic;
 signal AD              : std_logic_vector(15 downto 0);
---------------------------------------------------------------------------
begin

 reset <= I_RESET;
 INP0  <= "000" & joy_BBBBFRLDU(7) & not joy_BBBBFRLDU(6) & not joy_BBBBFRLDU(5) & joy_BBBBFRLDU(4) & joy_BBBBFRLDU(4);
 INP1  <= joy_BBBBFRLDU(2) & joy_BBBBFRLDU(1) & joy_BBBBFRLDU(3) & joy_BBBBFRLDU(0) & joy_BBBBFRLDU(2) & joy_BBBBFRLDU(1) & joy_BBBBFRLDU(3) & joy_BBBBFRLDU(0);
---------------------------------------------------------------------------
Clock48: entity work.Gowin_rPLL48
    port map (
        clkout => Clock_24,
        clkoutd => Clock_12,
        clkin => Clock_48
    );
---------------------------------------------------------------------------
-- Main

digdug : entity work.FPGA_DIGDUG
  port map (
 MCLK  => clock_48,
 RESET => reset,
 INP0  => INP0,
 INP1  => INP1,
 DSW0  => "10111001",
 DSW1  => "00111100",
 PH    => HPOS,
 PV    => VPOS,
 PCLK  => PCLK,
 POUT  => oPIX,
 SOUT  => oSND,
 AD    => AD
   );
------------------------------------------------------------------------------
-- Video Gen

hvgen : entity work.HVGEN
  port map (
 HPOS    => HPOS,
 VPOS    => VPOS,
 PCLK    => PCLK,
 iRGB    => oPIX(7 downto 6) & "00" & oPIX(5 downto 3) & '0' & oPIX(2 downto 0) & '0',
 oRGB    => oRGB, -- video_b & video_g & video_r,
 HBLK    => open,
 VBLK    => open,
 HSYN    => M_HSYNC,
 VSYN    => M_VSYNC
);
------------------------------------------------------------------------------
-- scan doubler

dblscan: entity work.scandoubler
	port map(
		clk_sys => clock_24,
		scanlines => "00",
		r_in   => oRGB(3 downto 0) & "00",
		g_in   => oRGB(7 downto 4) & "00",
		b_in   => oRGB(11 downto 8)& "00",
		hs_in  => M_HSYNC,
		vs_in  => M_VSYNC,
		r_out  => video_r_x2,
		g_out  => video_g_x2,
		b_out  => video_b_x2,
		hs_out => hsync_x2,
		vs_out => vsync_x2
	);
-------------------------------------------------------------------------
-- vga output

	O_VIDEO_R 	<= video_r_x2(5 downto 3);
	O_VIDEO_G 	<= video_g_x2(5 downto 3);
	O_VIDEO_B 	<= video_b_x2(5 downto 4);
	O_HSYNC     <= hsync_x2;
	O_VSYNC     <= vsync_x2;
------------------------------------------------------------------------------
-- get scancode from keyboard

keyboard : entity work.io_ps2_keyboard
port map (
  clk       => clock_12,
  kbd_clk   => ps2_clk,
  kbd_dat   => ps2_dat,
  interrupt => kbd_intr,
  scancode  => kbd_scancode
);
------------------------------------------------------------------------------
-- translate scancode to joystick

joystick : entity work.kbd_joystick
port map (
  clk         => clock_12,
  kbdint      => kbd_intr,
  kbdscancode => std_logic_vector(kbd_scancode), 
  joy_BBBBFRLDU  => joy_BBBBFRLDU 
);
---------------------------------------------------------------
 -- Audio DAC

u_dac : entity work.dac
  generic map(
    msbi_g => 7
  )
port  map(
    clk_i   => clock_12,
    res_n_i => '1',
    dac_i   => oSND,
    dac_o   => audio_pwm
);

 O_AUDIO_L <= audio_pwm; 
 O_AUDIO_R <= audio_pwm;

------------------------------------------------------------------------------
-- debug

process(reset, clock_24)
begin
  if reset = '1' then
    clock_4hz <= '0';
    counter_clk <= (others => '0');
  else
    if rising_edge(clock_24) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
        led(5 downto 0) <= not AD(9 downto 4);
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;
------------------------------------------------------------------------
end struct;