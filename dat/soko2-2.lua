-- NetHack sokoban soko2-2.lua	$NHDT-Date: 1652196035 2022/05/10 15:20:35 $  $NHDT-Branch: NetHack-3.7 $:$NHDT-Revision: 1.1 $
--	Copyright (c) 1998-1999 by Kevin Hugo
-- NetHack may be freely redistributed.  See license for details.
--
des.level_init({ style = "solidfill", fg = " " });

des.level_flags("mazelevel", "noteleport", "premapped", "sokoban", "solidify");

des.map([[
  --------            
--|.|....|            
|........|----------  
|.-...-..|.|.......|  
|...-......|.......|  
|.-....|...|.......|  
|....-.--.-|.......|  
|..........|.......|  
|.--...|...|.......---
|....-.|---|.......+.|
--|....|------------.|
  |................+.|
  --------------------
]]);
des.stair("down", 06,11)
des.stair("up", 15,06)
des.door("locked",19,09)
des.door("locked",19,11)
des.region(selection.area(00,00,21,12), "lit");
des.non_diggable(selection.area(00,00,21,12));
des.non_passwall(selection.area(00,00,21,12));

-- Boulders
des.object("boulder",04,02)
des.object("boulder",04,03)
des.object("boulder",05,03)
des.object("boulder",07,03)
des.object("boulder",08,03)
des.object("boulder",02,04)
des.object("boulder",03,04)
des.object("boulder",05,05)
des.object("boulder",06,06)
des.object("boulder",09,06)
des.object("boulder",03,07)
des.object("boulder",04,07)
des.object("boulder",07,07)
des.object("boulder",06,09)
des.object("boulder",05,10)
des.object("boulder",05,11)

-- prevent monster generation over the (filled) holes
des.exclusion({ type = "monster-generation", region = { 06,11, 18,11 } });
-- Traps
des.trap("rolling boulder",07,11)

-- Random objects
des.object({ class = "%" });
des.object({ class = "%" });
des.object({ class = "%" });
des.object({ class = "%" });
des.object({ class = "=" });
des.object({ class = "/" });
