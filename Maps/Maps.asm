include "Code/constants.asm"

Section "map_tutorial", ROMX[MAPDATA], BANK[1]
map_tutorial: incbin "./Maps/map_tutorial.bin"

Section "map_tutorial metadata", ROMX[MAPMETA], BANK[1]
map_tutorial_meta: incbin "./Maps/map_tutorial_meta.bin"

Section "map_tutorial objects", ROMX[OBJDATA], BANK[1]
map_tutorial_obj: incbin "./Maps/map_tutorial_obj.bin"