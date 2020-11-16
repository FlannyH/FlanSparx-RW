Section "Title Screen", ROM0
StateStart_GameLoop:
    ;Wait for the current frame to finish and then turn off the display
    call waitVBlank
    LCDoffHL

    ;Load the scene
    call MapHandler_LoadStripX

    LCDonHL
    ret

StateUpdate_GameLoop:
    reti