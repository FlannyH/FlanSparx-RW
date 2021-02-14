Section "Message Box", ROM0

StateStart_MessageBox:
    ;Setup state variables
        ld a, b
        cp MSGBOX_INSTANT
        jr nz, .else_
            xor a
            ld [bMsgBoxAnimTimer], a
            jr .endIf
        .else_
            ld a, 40
            ld [bMsgBoxAnimTimer], a
        .endIf

    ;Clear message box data
        ;Set state to Waiting Message Box
        ld a, STATE_MessageBox
        ld [pCurrentState], a
        ld a, 2
        ld [bMsgBoxAnimState], a

        ;Wait for VBlank and clear textbox
        call waitVBlank

        ld hl, $8460
        ld c, 72
        ld a, $FF
        .loop
            ld [hl+], a
            ld [hl+], a
            ld [hl+], a
            ld [hl+], a
            ld [hl+], a
            ld [hl+], a
            ld [hl+], a
            ld [hl+], a
            dec c
            jr nz, .loop

        xor a ; ld a, o
        ld [bMsgBoxAnimState], a

    ret

StateUpdate_MessageBox:
    ld a, [bMsgBoxAnimState]
    or a
    jr z, .OpeningBox
    dec a
    jr z, .StartDisplayText
    dec a
    jr z, .Waiting
    dec a
    jr z, .WaitForApress
    dec a
    jr z, .ClosingBox

    .OpeningBox
        ld a, [bMsgBoxAnimTimer]
        or a ; if bMsgBoxAnimTimer != 0
        jr z, .afterIf
            ;bMsgBoxAnimTimer -= 1
                dec a
                dec a
                ld [bMsgBoxAnimTimer], a
                ret
        .afterIf
        ld a, 1
        ld [bMsgBoxAnimState], a
        ret
    
    .StartDisplayText
        ld a, 2
        ld [bMsgBoxAnimState], a

        DisplayBoxText Text_Debug_Error, 1, 2

        ld a, 3
        ld [bMsgBoxAnimState], a

    .Waiting
        ret

    .WaitForApress
        ;if A press
        call GetJoypadStatus
        ld a, [bJoypadCurrent]
        or a ; cp 0
        jr z, .endIf
            ld hl, bMsgBoxAnimState
            inc [hl]
        .endIf
        ret

    .ClosingBox
        ld a, STATE_GameLoop ; TODO - make this more flexible, return to previous state
        ld [pCurrentState], a
        ret