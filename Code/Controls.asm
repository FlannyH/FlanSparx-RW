include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

SECTION "Controls", ROM0
;Gets the current joypad status, compares it to the last joypad status, and writes the press, hold and release states to RAM
GetJoypadStatus:
	push hl
	push bc
	ld hl, rP1
	ld b, %00000000
	
	;Get previous state
	ldh a, [hJoypadCurrent]
	ldh [hJoypadLast], a
	
	ld [hl], P1F_GET_BTN ; Tell the Game Boy that we want the buttons
	;Get the joypad value, and waste some time so the Game Boy can get the data properly
	call .knownRet
	ld a, [hl]
	ld a, [hl]
	ld a, [hl]
	ld a, [hl]
	and %00001111 ; Only take the lower 4 bits
	swap a ; swap them with the higher 4 bits
	ld b, a ; then store the result in B
	
	ld [hl], P1F_GET_DPAD ; Tell the Game Boy that we want the DPAD now
	;Get the joypad value, and waste some time so the Game Boy can get the data properly
	call .knownRet
	ld a, [hl]
	ld a, [hl]
	ld a, [hl]
	ld a, [hl]
	and %00001111 ; Only take the lower 4 bits
	or b ;combine the results together
	cpl ; xor $FF ; flip all bits (normally 1 means idle and 0 means pressed, I want it the other way around)
	ldh [hJoypadCurrent], a
	
	;Get pressed buttons
	
	; hJoyPressed:  (hJoyLast ^ hJoyInput) & hJoyInput
	ldh a, [hJoypadLast]
	ld b, a
	ldh a, [hJoypadCurrent]
	xor b
	ld c, a ; store result in c
	ldh a, [hJoypadCurrent]
	and c
	ldh [hJoypadPressed], a
	
	; hJoyReleased: (hJoyLast ^ hJoyInput) & hJoyLast
	ldh a, [hJoypadLast]
	ld b, a
	ldh a, [hJoypadCurrent]
	xor b
	ld c, a ; store result in c
	ldh a, [hJoypadLast]
	and c
	ldh [hJoypadReleased], a
	
	pop bc
	pop hl
.knownRet
	ret