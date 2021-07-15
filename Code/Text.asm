include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Text Handler", ROM0
StateStart_DebugWarning:
    ;Wait for the current frame to finish and then turn off the display
    call waitVBlank
    ld hl, rLCDC
    res 7, [hl]

    ;Clear tilemap and set $00 to be white
    ld hl, $8000
    ld a, $ff
    ld b, 16
    .whiteTileLoop
        ld [hl+], a
        dec b
        jr nz, .whiteTileLoop

    call ClearTilemap

	;lmao test
	ld a, 42
	ld [$9FFF], a

    ;Font
	ld hl, $8800
    call LoadFont

    ;Palette - GB
    ld a, %00011011
    ldh [rBGP], a
    ldh [rOBP0], a

    ;Palettes - GBC
	LoadPalettes tileset_crawdad_palette, 0, 8

    ;Text
    DisplayText Text_Debug_Warning, 0, 0

    ;Turn screen on
    ld hl, rLCDC
    set 7, [hl]

    ret

StateUpdate_DebugWarning:
    ;Get joypad
    call GetJoypadStatus
    
    ;Check if any of the joypad buttons are pressed
    ldh a, [hJoypadPressed]

    ;If not, do nothing
    or a
    jr nz, .goToTitleScreen
    ret

    .goToTitleScreen
    ;Otherwise, go to title screen
    ChangeState TitleScreen
    ret


Section "Text Data", ROM0
Text_Title_PressStart: 
    db "Press  Start"
    db 0

Text_Debug_Warning: 
    db "\n"
    db " Note:\n"
    db "\n"
    db " This game is \n"
    db " currently in \n"
    db " development. \n"
    db "\n"
    db " There will be bugs \n"
    db " and missing\n"
    db " features.\n"
    db "\n"
    db " ~Flanny\n"
    db "\n"
    db "\n"
    db "\n"
    db " Press any button.\n"
    db 0

Text_Debug_Error:
    db "An error has      "
    db "occured.          "
    db 0