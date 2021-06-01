if !DEF(VARIABLES)
VARIABLES SET 1
include "Code/variables.asm"
endc
;Copy [source], [destination]
;Example: Copy font_tiles, $8000
/*
Copy: macro
    ld a, bank(\1) ;get bank number
    ld [set_bank], a ;switch to that bank
    ld de, \1 ;source
    ld hl, \2 ;destination
    ld bc, \1_end - \1 ;copy size
    call memcpy ;copy the data
endm*/
Copy: macro
    ld a, bank(\1) ;get bank number
    ld [set_bank], a ;switch to that bank
    ld hl, \1 ;source
    ld de, \2 ;destination
    ld bc, (\1_end - \1) >> 3 ;copy size
    call PopSlideCopy ;copy the data
endm

;CopyTileBlock [source], [destination], [start offset]
;Example: CopyTileBlock tileset_crawdad_tiles, $8800, $800
CopyTileBlock: macro
    ld a, bank(\1) ;get bank number
    ld [set_bank], a ;switch to that bank
    ld de, \1+\3 ;source
    ld hl, \2 ;destination
    ld bc, $800
    call memcpy ;copy the data
endm

;Changes the game state
;Usage: ChangeState statename
;Example: ChangeState TitleScreen
ChangeState: macro
    di
    call StateStart_\1
    ld a, STATE_\1
    ldh [hCurrentState], a
    ei
endm

;arg1 += arg2 where arg2 is a variable
;ex: AddInt16 player_x, player_velx
AddInt16: MACRO
	;fine
    ld a, [\1 + 1]
    ld b, a
    ld a, [\2 + 1]
    add b
    ld [\1 + 1], a
	;coarse
    ld a, [\1]
    ld b, a
    ld a, [\2]
    adc b
    ld [\1], a
ENDM

;arg1 -= arg2 where arg2 is a constant
;ex: AddInt16 player_x, c_player_speed
AddConstInt16: MACRO
	;fine
    ldh a, [\1 + 1]
    add low(\2)
    ldh [\1 + 1], a
	;coarse
    ldh a, [\1]
    adc high(\2)
    ldh [\1], a
ENDM

;arg1 -= arg2 where arg2 is a variable
;ex: AddInt16 player_x, player_velx
SubInt16: MACRO
	;fine
    ld a, [\2 + 1]
    ld b, a
    ld a, [\1 + 1]
    sub b
    ld [\1 + 1], a
	;coarse
    ld a, [\2]
    ld b, a
    ld a, [\1]
    sbc b
    ld [\1], a
ENDM

;Adds a constant int to an int variable, and stores the result in the variable
;ex: AddInt16 player_x, c_player_speed
SuwConstInt16: MACRO
	;fine
    ld a, [\1 + 1]
    sub low(\2)
    ld [\1 + 1], a
	;coarse
    ld a, [\1]
    sbc high(\2)
    ld [\1], a
ENDM

;Wait for VRAM to unlock.
;15 or more cycles
waitForRightVRAMmode: macro
	push hl
	ld hl, rSTAT
    .waitForMode\@
        bit 1, [hl]
        jr nz, .waitForMode\@
        pop hl
endm

;Print text at a specific location
;Usage: DisplayText text, x, y
;Example: DisplayText Text_Title_PressStart, 4, 15
DisplayText: macro
    ld de, \1
    ld hl, $9800 + \2 + $20 * \3
    call CopyText
endm

;Load a constant 16 bit value into a 16 variable.
;Usage: ld16 variableName, value
; - Example: ld16 wCurrMoveSpeed, $0280
ld16const: macro
    ld a, high(\2)
    ld [\1+0], a
    ld a, low(\2)
    ld [\1+1], a
endm

AddConst8toR16: macro
    ld a, \2
    add \3
    ld \2, a
    adc \1
    sub \2
    ld \1, a
endm

SubConst8fromR16: macro
    ld a, \2 ; lower
    sub \3
    ld \2, a
    jr nc, .no_carry\@
    dec \1
    .no_carry\@
endm

lb: MACRO ; r, hi, lo
	ld \1, ((\2) & $ff) << 8 | ((\3) & $ff)
ENDM

;Loads a horizontal strip of tiles at an offset. Uses all registers
;Usage: MapHandler_LoadStripX x, y
MapHandler_LoadStripX: macro
    lb bc, \1, \2
    call m_MapHandler_LoadStripX
endm

;Usage: MapHandler_PrepareLoad <0 - horizontal, 1 - vertical> <x offset> <y offset>
MapHandler_PrepareLoad: macro
    ;Store loop counter
    if ((\1) == 0)
        xor a ; ld a, 0
        ldh [hMapLoaderMode], a
        ld a, 13
    else
        ld a, 1
        ldh [hMapLoaderMode], a
        ld a, 11
    endc
    ldh [hMapLoaderLoopCounter], a

    ;Store camera position + offset in temporary ram location
    ld a, [wCameraX]
    add \2
    ldh [hRegStorage1], a
    
    ld a, [wCameraY]
    add \3
    ldh [hRegStorage2], a

    call m_MapHandler_PrepareLoad
endm