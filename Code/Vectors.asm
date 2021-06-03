include "Code/hardware.inc"

Section "WaitHBlank", ROM0[$00]
;Wait for the LCD to finish drawing the scanline
waitHBlank:
	.wait
		ld a, [rSTAT]
		and STATF_BUSY
    jr nz, .wait
	ret

Section "Erorr handler", ROM0[$38]
Error2:
    jp ErrorHandler ; restart the game