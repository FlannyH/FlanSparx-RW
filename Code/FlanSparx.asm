include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"


Section "Jumpstart Code", ROM0[$100]
Jumpstart:
    di
    jp Start

REPT $150 - $104
    db 0
ENDR

Section "Init", ROM0
Start:
    ;Temporarily store the Game Boy type
    ld d, a

    ;Move stack pointer
    ld sp, $D000

    ;Clear RAM
    call InitVariables

    ;Save Game Boy Type
    ld a, d
    ld [hGameboyType], a

    ;Setup interrupts
    ld a, IEF_VBLANK
    ldh [rIE], a
	xor a
    ldh [rIF], a

    ;Prepare sprite routine
    call CopyDMARoutine

    ;Go to title screen
    ;ChangeState TitleScreen
    ChangeState DebugWarning

    ei

    .halt
        halt
		ld a, [rLY]
		cp 144
		jr c, .halt
			
		;Get current state index - multiply state index by 2
		ldh a, [hCurrentState]
		add a, a

		;Get state subroutine pointer pointer
		ld h, high(States)
		ld l, a

		;Get state subroutine pointer
		ld a, [hl+]
		ld h, [hl]
		ld l, a

		rst RunSubroutine
        jr .halt