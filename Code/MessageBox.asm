include "Code/constants.asm"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Message Box", ROM0

StateStart_MessageBox:
    ;Setup state variables
        ld a, b
        cp MSGBOX_INSTANT ; if not instant
        jr nz, .else_
            xor a
            ldh [bMsgBoxAnimTimer], a
            ldh [bMsgBoxAnimState], a
            jr .endIf
        .else_
            ld a, 40
            ldh [bMsgBoxAnimTimer], a
            xor a
            ldh [bMsgBoxAnimState], a
        .endIf

        ld a, STATE_MessageBox ; TODO - make this more flexible, return to previous state
        ldh [pCurrentState], a

    ret

StateUpdate_MessageBox:
    ldh a, [bMsgBoxAnimState]
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
        ldh a, [bMsgBoxAnimTimer]
        or a ; if bMsgBoxAnimTimer != 0
        jr z, .afterIf
            ;bMsgBoxAnimTimer -= 1
                dec a
                dec a
                ldh [bMsgBoxAnimTimer], a
                ret
        .afterIf
        ld a, 1
        ldh [bMsgBoxAnimState], a
        ret
    
    .StartDisplayText
        ld a, 2
        ldh [bMsgBoxAnimState], a

        ld a, [iErrorCode+0]
        ld d, a
        ld a, [iErrorCode+1]
        ld e, a
        call CopyTextBox

        ld a, 3
        ldh [bMsgBoxAnimState], a

    .Waiting
        ret

    .WaitForApress
        ;if A press
        call GetJoypadStatus
        ldh a, [bJoypadCurrent]
        or a ; cp 0
        jr z, .endIf
            ld hl, bMsgBoxAnimState
            inc [hl]
        .endIf
        ret

    .ClosingBox
        ;Clear message box data
            ;Set state to Waiting Message Box
            xor a ; ld a, o
            ldh [bMsgBoxAnimState], a

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

        ld a, STATE_GameLoop ; TODO - make this more flexible, return to previous state
        ldh [pCurrentState], a
        
        ret