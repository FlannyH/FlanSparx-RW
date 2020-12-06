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
    ld [rOBP0], a

    ;Turn the screen back on
    LCDonHL
    ret

StateUpdate_TitleScreen:
    ;Get input
    call GetJoypadStatus

    ;Check if start button pressed
    ld hl, bJoypadPressed
    bit J_START, [hl]
    jr nz, .startPressed

    ;If not pressed, return
    reti

    .startPressed
    ;Change state if start button was pressed
    ChangeState GameLoop
    reti

Text_Title_PressStart: 
db "Press  Start", 0 

