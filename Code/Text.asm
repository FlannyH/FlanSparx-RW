include "constants.asm"
include "hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Text Handler", ROM0
StateStart_DebugWarning:
    ;Wait for the current frame to finish and then turn off the display
    call waitVBlank
    LCDoffHL

    ;Clear tilemap and set $00 to be white
    ld hl, $8000
    ld a, $ff
    ld b, 16
    .whiteTileLoop
        ld [hl+], a
        dec b
        jr nz, .whiteTileLoop

    ClearTilemap

    ;Font
    LoadFont $8800

    ;Palette - GB
    ld a, %00011011
    ld [rBGP], a
    ld [rOBP0], a

    ;Palettes - GBC
    LoadPalettes tileset_crawdad_palette

    ;Text
    DisplayText Text_Debug_Warning, 0, 0

    ;Turn screen on
    LCDonHL
    ret
StateUpdate_DebugWarning:
    ;Get joypad
    call GetJoypadStatus
    
    ;Check if any of the joypad buttons are pressed
    ld a, [bJoypadPressed]

    ;If not, do nothing
    or a
    jr nz, .goToTitleScreen
    reti

    .goToTitleScreen
    ;Otherwise, go to title screen
    ChangeState TitleScreen
    reti


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