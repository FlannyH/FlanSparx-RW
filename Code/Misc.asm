include "Code/hardware.inc"

Section "Misc", ROM0
;Copy BC bytes from DE to HL
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

;Copy C bytes from HL to DE
PopSlideCopy:
	;Save SP in WRAM and load HL into SP
	ld [hSPstorage], sp
	ld sp, hl
	ld h, d
	ld l, e

	inc b
	
	.loop
		rept 4
			;Load 2 bytes at once, and write them to the destination
			pop de
			ld a, e
			ld [hl+], a
			ld a, d
			ld [hl+], a
		endr
		;Count down byte counter
		dec c
		jr nz, .loop
		dec b
		jr nz, .loop

	;Get SP back
	ldh a, [hSPstorage]
	ld l, a
	ldh a, [hSPstorage+1]
	ld h, a
	ld sp, hl
	ret

;Wait for the LCD to finish drawing the screen
waitVBlank:
.wait
    halt
    ldh a, [rLY]
    cp 144 ; Check if past VBlank
    jr c, .wait ; Keep waiting until VBlank is done
    ret

;Wait for the LCD to finish drawing the scanline
waitHBlank: macro
    ld a, [rSTAT]
    and STATF_BUSY
    jr nz, waitHBlank
endm
    ;ret
        
;Run subroutine at HL
RunSubroutine:
    jp hl
    
;Input: HL - source, DE, screen
CopyScreen:
    ;Colors
    push hl
    ld a, 1
    ldh [rVBK], a
    ld de, $9800
    ld c, 144/8
    ;Copy a row
    .ver_loopc
        ld b, 160/8
        .hor_loopc:
            ;Get tile ID
            ld a, [hl+]
            push hl
            ld hl, tileset_title_palassign
            add l
            ld l, a
            ld a, [hl]
            pop hl
            ld [de], a
            inc e

            ;Countdown
            dec b
            jr nz, .hor_loopc

        ;Go back to the left
        ld a, e
        and %11100000

        ;Go down 1 line
        add $20
        ld e, a
        adc d
        sub e
        ld d, a

        ;Counter
        dec c
        jr nz, .ver_loopc

    ;Tiles
    pop hl
    xor a ; ld a, 0
    ldh [rVBK], a
    ld de, $9800
    ld c, 144/8
    ;Copy a row
    .ver_loop
        ld b, 160/8
        .hor_loop:
            ;Put tile
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
        adc d
        sub e
        ld d, a

        ;Counter
        dec c
        jr nz, .ver_loop

    ret

CopyText:
    ;Read byte
    ld a, [de]
    inc de

    ;Exit if null (end)
    or a ; cp 0
    ret z

    ;Go to next line if \n found
    cp "\n"
    jr z, .line

    ;Write byte
    ld [hl+], a

    jr CopyText

    .line

    ld a, l
    and ~($1F) ;return to start of line
    add $20 ;go to next line
    ld l, a
    adc h ;handle 16 bit addition
    sub l
    ld h, a

    jr CopyText

CopyTextBox:
    ld hl, $8460
    ld b, 36
    .loop
        ;Wait for vblank
            push hl
            call waitVBlank
            pop hl
        ;Read byte
            ld a, [de]
            and $7F
            inc de

        ;Copy font character
            push de
            ld d, 0
            or a

        ;id x 3
            rla
            rl d
            rla
            rl d
            rla
            rl d
            ld e, a
            ld a, d
            add high(font_tiles)
            ld d, a

        ;Load character
            ld c, 8
            .loop2
                ld a, [de]
                ld [hl+], a
                ld [hl+], a
                inc e
                dec c
                jr nz, .loop2

        ;Handle loop
            pop de
            dec b
            jr nz, .loop
    ret

;Sets a flag that prevents an object from spawning again.
;Input: A - object ID to flag, uses B
SetCollectableFlag:
    ;Save A in B for later use
    ld b, a

    ;Get object flags pointer - HL = ObjectF
    ld hl, Object_Flags
    rra
    rra
    rra
    and %00011111
    add l
    ld l, a

    ;Get bit
    ld a, b
    and %111
    inc a
    ld b, a

    ;Set that bit to 1
    xor a ;ld a, 0
    scf
    .loop
        rra
        dec b
        jr nz, .loop

    or [hl]
    ld [hl], a

    ret

;Checks ifflag that prevents an object from spawning again is set
;Input: A - object ID to flag, uses B
GetCollectableFlag:
    push hl

    ;Save A in B for later use
    ld b, a

    ;Get object flags pointer - HL = ObjectF
    ld hl, Object_Flags
    rra
    rra
    rra
    and %00011111
    add l
    ld l, a

    ;Get bit
    ld a, b
    and %111
    inc a
    ld b, a

    ;Set that bit to 1
    xor a ; ld a, 0
    scf
    .loop
        rra
        dec b
        jr nz, .loop

    and [hl]
    pop hl

    ret

;Input: A = value to clear with, B = amount of bytes to clear (0 = 256), HL = starting point
_clear8:
    ld [hl+], a
    dec b
    jr nz, _clear8
    ret

;Input: A
;Usage: Clear8 start, length
Clear8: macro
    ld hl, \1
    ld b, ((\2) & $ff)
    call _clear8
endm

InitVariables:
    ;Clear A
    xor a

    ;Clear HRAM variables
    Clear8 HRAMvariables, HRAMvariablesEnd-HRAMvariables

    ;Clear tables
    Clear8 wShadowOAM, wShadowOAMend - wShadowOAM
    Clear8 Object_IDs, Object_IDsEnd - Object_IDs
    Clear8 Object_Types, Object_TypesEnd - Object_Types
    Clear8 Object_Flags, Object_FlagsEnd - Object_Flags
    Clear8 TextBuffer, TextBufferEnd - TextBuffer


    ret