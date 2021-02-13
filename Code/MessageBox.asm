Section "Message Box", ROM0
StateStart_MessageBox:
    ld a, b
    cp MSGBOX_INSTANT
    jr nz, .endif
        ld a, 40
        ld [bMsgBoxSCY], a
        xor a
        ld [bMsgBoxAnimTimer], a
        inc a
        ld [bMsgBoxAnimState], a
        ret
    .endif

        ld a, 40
        ld [bMsgBoxAnimTimer], a
        xor a
        ld [bMsgBoxSCY], a
        ld [bMsgBoxAnimState], a
        ret

StateUpdate_MessageBox:
    ld a, [bMsgBoxAnimState]
    or a
    jr z, .OpeningBox
    dec a
    jr z, .StartDisplayText
    dec a
    jr z, .DisplayingText
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
            ;bMsgBoxSCY += 1
                ld hl, bMsgBoxSCY
                inc [hl]
                inc [hl]
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

        ret

    .DisplayingText
        ret

    .ClosingBox
        ret