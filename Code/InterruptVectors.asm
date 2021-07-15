include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Vblank Vector", ROM0[$40]
;    jp Vblank
;
;Section "Vblank Handler", ROM0
Vblank:
	push af
    call HandleSprites
	pop af
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