include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Yellow Gem", ROM0
Object_Start_YellowGem:
	jp Object_Start_GemCommon

Object_Update_YellowGem:
    jp Object_Update_GemCommon

Object_Draw_YellowGem:
    push hl
    push bc
    call PrepareSpriteDraw

    ;Prepare pointer to sprite order entry
    ld hl, SprYellowGem
    call Object_DrawSingle
    ld a, c
    add 8
    ld c, a
    call Object_DrawSingle
    
    pop bc
    pop hl
    
    dec b

    ret

Object_PlyColl_YellowGem:
	ld e, $10 ; gems to add on collision
	jp Obj_PlyColl_GemCommon