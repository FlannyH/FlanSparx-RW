include "constants.asm"
include "hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Vblank Vector", ROM0[$40]
    ei
    jp Vblank

Section "Vblank Handler", ROM0
Vblank:
    ld a, [bHandlingUpdateMethod]
    or a
    ret nz

    ld hl, rIE
    ld a, 1
    ld [bHandlingUpdateMethod], a
    ;Get current state index - multiply state index by 2
    ld a, [pCurrentState]
    add a, a

    ;Get state subroutine pointer pointer
    ld h, high(States)
    ld l, a

    ;Get state subroutine pointer
    ld a, [hl+]
    ld h, [hl]
    ld l, a

    call RunSubroutine

    ld a, 0
    ld [bHandlingUpdateMethod], a
    reti

Section "StateUpdate", ROM0, Align[8]
States:
    dw StateUpdate_None
    dw StateUpdate_TitleScreen
    dw StateUpdate_GameLoop
    dw StateUpdate_DebugWarning
    dw StateUpdate_MessageBox

StateStart_None:
StateUpdate_None:
    reti