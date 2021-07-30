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

;Wait for VRAM to unlock using A, stays unlocked for 16+ cycles
waitUnlockVRAM_A: macro
	.wait\@
		ld a, [rSTAT]
		and STATF_BUSY
		jr nz, .wait\@
	endm
	
;Wait for VRAM to unlock using HL, stays unlocked for 16+ cycles
waitUnlockVRAM_HL: macro
	ld hl, rSTAT
	.wait\@
        bit 1, [hl]
		jr nz, .wait\@
endm

;Print text at a specific location
;Usage: DisplayText text, x, y
;Example: DisplayText Text_Title_PressStart, 4, 15
DisplayText: macro
    ld de, \1
    ld hl, $9800 + \2 + $20 * \3
    call CopyText
endm

lb: MACRO ; r, hi, lo
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