;Copy [source], [destination]
;Example: Copy font_tiles, $8000
Copy: macro
    ld de, \1 ;source
    ld hl, \2 ;destination
    ld bc, \1_end - \1 ;copy size
    call memcpy ;copy hte data
endm

;CopyTileBlock [source], [destination], [start offset]
;Example: CopyTileBlock tileset_crawdad_tiles, $8800, $800
CopyTileBlock: macro
    ld de, \1+\3 ;source
    ld hl, \2 ;destination
    ld bc, $800
    call memcpy ;copy hte data
endm

;Load the font tiles - usage: LoadFont destination - example: LoadFont $8800
LoadFont: macro
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

memcpy:
    .mc
    ;Copy 1 byte from [de] to [hl]
    ld a, [de]
    ld [hl+], a
    inc de
    ;Count timer
    dec bc
    ld a, b
    or c
    or a ; cp 0
    jr nz, memcpy
    ret

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

;Wait for the LCD to finish drawing the screen
waitVBlank:
	ei
.wait
	halt
	ld a, [rLY]
	cp 144 ; Check if past VBlank
	jr c, .wait ; Keep waiting until VBlank is done
	ret

;Changes the game state
;Usage: ChangeState statename
;Example: ChangeState TitleScreen
ChangeState: macro
    ld a, STATE_\1
    ld [pCurrentState], a
    call StateStart_\1
endm

;Run subroutine at HL
RunSubroutine:
    jp hl
    
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
    ld a, [\1 + 1]
    add low(\2)
    ld [\1 + 1], a
	;coarse
    ld a, [\1]
    adc high(\2)
    ld [\1], a
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
SubConstInt16: MACRO
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
.waitForMode
	bit 1, [hl]
	jr nz, .waitForMode
	pop hl
endm
    
ClearRAM: macro
	;Clear WRAM
	ld hl, $DFFF ; set pointer to the end of RAM
	xor a ; ld a, 0 ; the value we're gonna fill the ram with
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

;Input: HL - source, DE, screen
CopyScreen:
    ld de, $9800
    ld c, 144/8
    ;Copy a row
    .ver_loop
        ld b, 160/8
        .hor_loop:
            ;Copy one tile
            ld a, [hl+]
            ld [de], a
            inc e

            ;Countdown
            dec b
            jr nz, .hor_loop

        ;Go back to the left
        ld a, e
        and %11100000

        ;Go down 1 line
        add $20
        ld e, a
        ld a, d
        adc 0
        ld d, a

        ;Counter
        dec c
        jr nz, .ver_loop

    ret

;Print text at a specific location
;Usage: DisplayText text, x, y
;Example: DisplayText Text_Title_PressStart, 4, 15
DisplayText: macro
    ld hl, \1
    ld de, $9800 + \2 + $20 * \3
    call CopyText
endm

CopyText:
    ;Read byte
    ld a, [hl+]

    ;Exit if null (end)
    or a ; cp 0
    ret z

    ;Write byte
    ld [de], a
    inc e

    jr CopyText

;Load a constant 16 bit value into a 16 variable.
;Usage: ld16 variableName, value
; - Example: ld16 bCurrMoveSpeed, $0280
ld16const: macro
    ld a, high(\2)
    ld [\1+0], a
    ld a, low(\2)
    ld [\1+1], a
endm