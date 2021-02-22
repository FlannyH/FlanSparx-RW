MAPDATA equ $4000
OBJDATA equ $7FF0

Section "map_tutorial", ROMX[$4000], BANK[1]
map_tutorial: incbin "./Maps/map_tutorial.bin"

Section "map_tutorial objects", ROMX[$7F00], BANK[1]
map_tutorial_obj: incbin "./Maps/map_tutorial_obj.bin"

