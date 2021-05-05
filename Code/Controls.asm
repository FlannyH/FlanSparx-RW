include "constants.asm"
include "hardware.inc"
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
	ldh a, [bJoypadCurrent]
	ldh [bJoypadLast], a
	
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
	ldh [bJoypadCurrent], a
	
	;Get pressed buttons
	
	; hJoyPressed:  (hJoyLast ^ hJoyInput) & hJoyInput
	ldh a, [bJoypadLast]
	ld b, a
	ldh a, [bJoypadCurrent]
	xor b
	ld c, a ; store result in c
	ldh a, [bJoypadCurrent]
	and c
	ldh [bJoypadPressed], a
	
	; hJoyReleased: (hJoyLast ^ hJoyInput) & hJoyLast
	ldh a, [bJoypadLast]
	ld b, a
	ldh a, [bJoypadCurrent]
	xor b
	ld c, a ; store result in c
	ldh a, [bJoypadLast]
	and c
	ldh [bJoypadReleased], a
	
	pop bc
	pop hl
.knownRet
	ret