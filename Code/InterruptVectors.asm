Section "Vblank Vector", ROM0[$40]
    jp Vblank

Section "Vblank Handler", ROM0
Vblank:
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

    jp RunSubroutine

Section "StateUpdate", ROM0, Align[8]
States:
    dw StateUpdate_None
    dw StateUpdate_TitleScreen
    dw StateUpdate_GameLoop
    dw StateUpdate_DebugWarning

StateStart_None:
StateUpdate_None:
    reti