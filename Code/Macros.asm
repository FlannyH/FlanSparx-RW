if !DEF(VARIABLES)
VARIABLES SET 1
include "Code/variables.asm"
endc
;Copy [source], [destination]
;Example: Copy font_tiles, $8000
Copy: macro
    ld a, bank(\1) ;get bank number
    ld [set_bank], a ;switch to that bank
    ld de, \1 ;source
    ld hl, \2 ;destination
    ld bc, \1_end - \1 ;copy size
    call memcpy ;copy the data
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

;Wait for the LCD to finish drawing the scanline
waitHBlank: macro
	.wait\@
    ld a, [rSTAT]
    and STATF_BUSY
    jr nz, .wait\@
endm

;Load the font tiles - usage: LoadFont destination - example: LoadFont $8800
LoadFont: macro
    ld a, bank(font_tiles) ;get bank number
    ld [set_bank], a ;switch to that bank
    ld de, font_tiles
    ld hl, \1
    ld b, 0
    .copyFontLoop:
        ld a, [de]
        ld [hl+], a
        ld [hl+], a
        inc e
        ld a, [de]
        ld [hl+], a
        ld [hl+], a
        inc e
        ld a, [de]
        ld [hl+], a
        ld [hl+], a
        inc e
        ld a, [de]
        ld [hl+], a
        ld [hl+], a
        inc de
        dec b
        jr nz, .copyFontLoop
endm

ClearTilemap: macro
    ld hl, $9BFF ; last visible tile on the screen
    xor a ; ld a, 0
    .loop\@
        ld [hl-], a
        bit 3, h
        jr nz, .loop\@
endm


;Turn off the LCD, not using HL (slower)
LCDoffA: macro
    ldh a, [rLCDC]
    res 7, a
    ldh [rLCDC], a
endm

;Turn off the LCD, using HL register (faster)
LCDoffHL: macro
    ld hl, rLCDC
    res 7, [hl]
endm

;Turn on the LCD, not using HL (slower)
LCDonA: macro
    ldh a, [rLCDC]
    set 7, a
    ldh [rLCDC], a
endm

;Turn on the LCD, using HL register (faster)
LCDonHL: macro
    ld hl, rLCDC
    set 7, [hl]
endm


;Changes the game state
;Usage: ChangeState statename
;Example: ChangeState TitleScreen
ChangeState: macro
    di
    call StateStart_\1
    ld a, STATE_\1
    ldh [pCurrentState], a
    ei
endm

    
;arg1 += arg2 where arg2 is a variable
;ex: AddInt16 player_x, player_velx
AddInt16: MACRO
	;fine
    ldh a, [\1 + 1]
    ld b, a
    ldh a, [\2 + 1]
    add b
    ldh [\1 + 1], a
	;coarse
    ldh a, [\1]
    ld b, a
    ldh a, [\2]
    adc b
    ldh [\1], a
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
    ldh a, [\2 + 1]
    ld b, a
    ldh a, [\1 + 1]
    sub b
    ldh [\1 + 1], a
	;coarse
    ldh a, [\2]
    ld b, a
    ldh a, [\1]
    sbc b
    ldh [\1], a
ENDM
;Adds a constant int to an int variable, and stores the result in the variable
;ex: AddInt16 player_x, c_player_speed
SubConstInt16: MACRO
	;fine
    ldh a, [\1 + 1]
    sub low(\2)
    ldh [\1 + 1], a
	;coarse
    ldh a, [\1]
    sbc high(\2)
    ldh [\1], a
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
    
ClearRAM: macro
	;Clear WRAM
	ld hl, $DFFF ; set pointer to almost the end of RAM
    ;Don't clear $DFFF, that's where the gameboy type is stored for now
	xor a ; ld a, 0
    .fillWRAMwithZeros
        ld [hl-], a ; write a zero
        bit 6, h
        jr nz, .fillWRAMwithZeros
	
	;Clear HRAM
	ld hl, $FFFE ; set pointer to HRAM
	xor a ; ld a, $00 ; the value we're gonna fill the ram with
    .fillHRAMwithZeros
        ld [hl-], a ; write a zero
        bit 7, l
        jr nz, .fillHRAMwithZeros ; keep going until we reach $FF80
endm

;LoadScreen [source];
;Example: LoadScreen screen_title
LoadScreen: macro
    ld hl, \1
    call CopyScreen
endm


;Print text at a specific location
;Usage: DisplayText text, x, y
;Example: DisplayText Text_Title_PressStart, 4, 15
DisplayText: macro
    ld de, \1
    ld hl, $9800 + \2 + $20 * \3
    call CopyText
endm
DisplayBoxText: macro
    ld de, \1
    call CopyTextBox
endm

;Load a constant 16 bit value into a 16 variable.
;Usage: ld16 variableName, value
; - Example: ld16 iCurrMoveSpeed, $0280
ld16const: macro
    ld a, high(\2)
    ldh [\1+0], a
    ld a, low(\2)
    ldh [\1+1], a
endm

LoadPalettes: macro
    ;BG PALETTES
	ld hl, rBCPS ; Palette select register
	ld a, %10000000
	ld [hl+], a

	ld b, 8*8 ; 8 bytes for 1 palettes
	ld de, \1
    .paletteLoopBG
    	ld a, [de]
    	ld [hl], a
    	inc e
    	dec b
    	jr nz, .paletteLoopBG

    ;OBJ PALETTES
	ld hl, rOCPS ; Palette select register
	ld a, %10000000
	ld [hl+], a

	ld b, 8*8 ; 8 bytes for 1 palette
	;ld de, \1 + 64
    .paletteLoopOBJ
    	ld a, [de]
    	ld [hl], a
    	inc de
    	dec b
    	jr nz, .paletteLoopOBJ
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

;Get map data pointer from camera position
;Usage: coordinates in BC, macro will put pointer in DE
MapHandler_GetMapDataPointer: macro
    ;Handle Y coordinate
        push bc ; push BC, we'll need B later
        ldh a, [bMapWidth]
        ld b, a ; Map width
        call Mul8x8to16 ; HL = y * map width
        pop bc

    ;Handle X coordinate and store result in DE
        ;HL += B (x coordinate)
        ld a, l
        add b
        ld e, a
        adc h
        sub e

        ;HL |= $4000, to get it in map data range
        or $40
        ld d, a
endm

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
        ldh [bMapLoaderMode], a
        ld a, 13
    else
        ld a, 1
        ldh [bMapLoaderMode], a
        ld a, 11
    endc
    ldh [bMapLoaderLoopCounter], a

    ;Store camera position + offset in temporary ram location
    ldh a, [bCameraX]
    add \2
    ldh [bRegStorage1], a
    
    ldh a, [bCameraY]
    add \3
    ldh [bRegStorage2], a

    call m_MapHandler_PrepareLoad
endm