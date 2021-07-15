include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Title Screen", ROM0
StateStart_TitleScreen:
    ;Wait for the current frame to finish and then turn off the display
    call waitVBlank
    di
    ld hl, rLCDC
    res 7, [hl]

    ;Load the scene
    Copy tileset_title_tiles, $8000
	ld hl, $8800
    call LoadFont
    ld hl, screen_title
	call CopyScreen

    ;Write text
    DisplayText Text_Title_PressStart, 4, 15

    ;Palette - GB
    ld a, %00_01_10_11
    ldh [rBGP], a
	ld a, %00_01_11_11
    ldh [rOBP0], a

    ;Palettes - GBC
	LoadPalettes tileset_crawdad_palette, 0, 8
	LoadPalettes sprites_crawdad_CGB_palette, 8, 8

    ;Turn the screen back on
    ld hl, rLCDC
    set 7, [hl]

    ei
    ret

StateUpdate_TitleScreen:
    ;Get input
    call GetJoypadStatus

    ;Check if start button pressed
    ld hl, hJoypadPressed
    bit J_START, [hl]
    jr nz, .startPressed

    ;If not pressed, return
    ret

    .startPressed
    ;Change state if start button was pressed
    ChangeState GameLoop
    ret

