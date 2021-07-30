include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Blue Gem", ROM0
Object_Start_BlueGem:
	jp Object_Start_GemCommon

Object_Update_BlueGem:
    jp Object_Update_GemCommon

Object_Draw_BlueGem:
    push hl
    push bc
    call PrepareSpriteDraw

    ;Prepare pointer to sprite order entry
    ld hl, SprBlueGem
    call Object_DrawSingle
    ld a, b
    add 8
    ld b, a
    call Object_DrawSingle
    
    pop bc
    pop hl
    
    dec b

    ret

Object_PlyColl_BlueGem:
	ld e, $05 ; gems to add on collision
	jp Obj_PlyColl_GemCommon