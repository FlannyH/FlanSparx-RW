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
            ld [wMsgBoxAnimTimer], a
            ld [wMsgBoxAnimState], a
            jr .endIf
        .else_
            ld a, 40
            ld [wMsgBoxAnimTimer], a
            xor a
            ld [wMsgBoxAnimState], a
        .endIf

        ld a, STATE_MessageBox ; TODO - make this more flexible, return to previous state
        ldh [hCurrentState], a

    ret

StateUpdate_MessageBox:
    ld a, [wMsgBoxAnimState]
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
        ld a, [wMsgBoxAnimTimer]
        or a ; if wMsgBoxAnimTimer != 0
        jr z, .afterIf
            ;wMsgBoxAnimTimer -= 1
                dec a
                dec a
                ld [wMsgBoxAnimTimer], a
                ret
        .afterIf
        ld a, 1
        ld [wMsgBoxAnimState], a
        ret
    
    .StartDisplayText
        ld a, 2
        ld [wMsgBoxAnimState], a

        ld a, [iErrorCode.high]
        ld d, a
        ld a, [iErrorCode.low]
        ld e, a
        call CopyTextBox

        ld a, 3
        ld [wMsgBoxAnimState], a

    .Waiting
        ret

    .WaitForApress
        ;if A press
        call GetJoypadStatus
        ldh a, [hJoypadCurrent]
        or a ; cp 0
        jr z, .endIf
            ld hl, wMsgBoxAnimState
            inc [hl]
        .endIf
        ret

    .ClosingBox
        ;Clear message box data
            ;Set state to Waiting Message Box
            xor a ; ld a, o
            ld [wMsgBoxAnimState], a

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
        ldh [hCurrentState], a
        
        ret