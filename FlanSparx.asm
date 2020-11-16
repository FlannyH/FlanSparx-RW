include "hardware.inc"
include "variables.asm"
include "Graphics/Graphics.inc"
include "Screens/Screens.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"
include "Code/Controls.asm"
include "Code/TitleScreen.asm"
include "Code/InterruptVectors.asm"

Section "Jumpstart Code", ROM0[$100]
Jumpstart:
    di
    jp Start

REPT $150 - $104
    db 0
ENDR

Section "Init", ROM0
Start:
    ;Move stack pointer
    ld sp, $D000

    ;Clear RAM
    ClearRAM

    ;Setup interrupts
    ld a, IEF_VBLANK
    ld [rIE], a
    ld [rIF], a

    ;Go to title screen
    ChangeState TitleScreen

    ei

    .halt
        halt
        jr .halt