include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Purple Gem", ROM0
Object_Start_PurpleGem:
	jp Object_Start_GemCommon

Object_Update_PurpleGem:
    jp Object_Update_GemCommon

Object_Draw_PurpleGem:
    push hl
    push bc
    call PrepareSpriteDraw

    ;Prepare pointer to sprite order entry
    ld hl, SprPurpleGem
    call Object_DrawSingle
    ld a, b
    add 8
    ld b, a
    call Object_DrawSingle
    
    pop bc
    pop hl
    
    dec b

    ret

Object_PlyColl_PurpleGem:
	ld e, $25 ; gems to add on collision
	jp Obj_PlyColl_GemCommon