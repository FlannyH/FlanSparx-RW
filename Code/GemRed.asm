include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Red Gem", ROM0
Object_Start_RedGem:
	jp Object_Start_GemCommon

Object_Update_RedGem:
    jp Object_Update_GemCommon

Object_Draw_RedGem:
    push hl
    push bc
    call PrepareSpriteDraw

    ;Prepare pointer to sprite order entry
    ld hl, SprRedGem
    call Object_DrawSingle
    ld a, b
    add 8
    ld b, a
    call Object_DrawSingle
    
    pop bc
    pop hl
    
    dec b

    ret

Object_PlyColl_RedGem:
	ld e, $01 ; gems to add on collision
	jp Obj_PlyColl_GemCommon