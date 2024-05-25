if !DEF(VARIABLES)
DEF VARIABLES EQU 1
include "Code/variables.asm"
endc
;Copy [source], [destination]
;Example: Copy font_tiles, $8000
/*
MACRO Copy
    ld a, bank(\1) ;get bank number
    ld [set_bank], a ;switch to that bank
    ld de, \1 ;source
    ld hl, \2 ;destination
    ld bc, \1_end - \1 ;copy size
    call memcpy ;copy the data
ENDM*/
MACRO Copy
    ld a, bank(\1) ;get bank number
    ld [set_bank], a ;switch to that bank
    ld hl, \1 ;source
    ld de, \2 ;destination
    ld bc, (\1_end - \1) >> 3 ;copy size
    call PopSlideCopy ;copy the data
ENDM

;CopyTileBlock [source], [destination], [start offset]
;Example: CopyTileBlock tileset_crawdad_tiles, $8800, $800
MACRO CopyTileBlock
    ld a, bank(\1) ;get bank number
    ld [set_bank], a ;switch to that bank
    ld de, \1+\3 ;source
    ld hl, \2 ;destination
    ld bc, $800
    call memcpy ;copy the data
ENDM

;Changes the game state
;Usage: ChangeState statename
;Example: ChangeState TitleScreen
MACRO ChangeState
    di
    call StateStart_\1
    ld a, STATE_\1
    ldh [hCurrentState], a
    ei
ENDM

;Wait for VRAM to unlock using A, stays unlocked for 16+ cycles
MACRO waitUnlockVRAM_A
	.wait\@
		ld a, [rSTAT]
		and STATF_BUSY
		jr nz, .wait\@
ENDM
	
;Wait for VRAM to unlock using HL, stays unlocked for 16+ cycles
MACRO waitUnlockVRAM_HL
	ld hl, rSTAT
	.wait\@
        bit 1, [hl]
		jr nz, .wait\@
ENDM

;Print text at a specific location
;Usage: DisplayText text, x, y
;Example: DisplayText Text_Title_PressStart, 4, 15
MACRO DisplayText
    ld de, \1
    ld hl, $9800 + \2 + $20 * \3
    call CopyText
ENDM

MACRO lb ; r, hi, lo
	ld \1, ((\2) & $ff) << 8 | ((\3) & $ff)
ENDM

;LoadPalettes <source> <palette index offset> <amount of palettes>
MACRO LoadPalettes
	if (\2) < 8
		ld a, $80 | (\2)*8
		ld [rBCPS], a
		ld c, low(rBCPD)
	else
		ld a, $80 | (\2-8)*8
		ld [rOCPS], a
		ld c, low(rOCPD)
	endc
	ld b, (\3) * 8
	ld hl, \1
	.loop\@
		ld a, [hl+]
		ld [c], a
		dec b
		jr nz, .loop\@
ENDM