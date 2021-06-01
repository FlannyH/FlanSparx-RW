include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Green Gem", ROM0
Object_Start_GreenGem:
	jp Object_Start_GemCommon

Object_Update_GreenGem:
    jp Object_Update_GemCommon

Object_Draw_GreenGem:
    push hl
    push bc
    call PrepareSpriteDraw

    ;Prepare pointer to sprite order entry
    ld hl, SprGreenGem
    call Object_DrawSingle
    ld a, c
    add 8
    ld c, a
    call Object_DrawSingle
    
    pop bc
    pop hl
    
    dec b

    ret

Object_PlyColl_GreenGem:
	ld e, $02 ; gems to add on collision
	jp Obj_PlyColl_GemCommon