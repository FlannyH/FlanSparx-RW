Section "Title Screen", ROM0
StateStart_TitleScreen:
    ;Wait for the current frame to finish and then turn off the display
    call waitVBlank
    LCDoffHL

    ;Load the scene
    Copy tileset_title_tiles, $8000
    LoadFont $8800
    LoadScreen screen_title

    ;Write text
    DisplayText Text_Title_PressStart, 4, 15

    ;Palette
    ld a, %00011011
    ld [rBGP], a

    ;Turn the screen back on
    LCDonHL
    ret

StateUpdate_TitleScreen:
    reti

newcharmap font_order
charmap "A", $C1
charmap "B", $C2
setcharmap font_order
Text_Title_PressStart: db "Press  Start", 0 
   