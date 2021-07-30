include "Code/hardware.inc"

Section "WaitHBlank but reg B is free", ROM0[$00]
;Run subroutine at HL
RunSubroutine:
    jp hl

Section "Erorr handler", ROM0[$38]
Error2:
    jp ErrorHandler ; restart the game