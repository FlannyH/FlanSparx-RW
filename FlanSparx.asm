include "hardware.inc"
include "variables.asm"

Section "Jumpstart Code", ROM0[$100]
Jumpstart:
    di
    jp Start

REPT $150 - $104
    db 0
ENDR

Section "Init", ROM0
Start:
    ;Insert code

    .halt
        halt
        jr .halt