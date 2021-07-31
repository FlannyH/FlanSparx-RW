include "Code/constants.asm"
include "Code/Charmap.inc"
include "Code/Macros.asm"
include "Code/Types.asm"

Section "Object Arrays 1", WRAMX[$D000]
Object_Table:
	Object Obj
	ds $E000 - @


Section "Object Manager", ROM0
Object_SpawnObject:

    ;Go to object type array
    ld hl, Object_Types

    ;and start looking for an empty object slot
    ;(empty object slot has type $00 or type $FF)
    .findSlotloop
        ld a, [hl+]
        inc a
        jr z, .yesDoThisOne
        dec a
        jr z, .yesDoThisOne
        jr .findSlotloop

    .yesDoThisOne

    ;Loop takes us one too far, correct for that
    dec l

    ld h, high(Object_IDs)
    ldh a, [hRegStorage3]
    ld [hl], a
    ld h, high(Object_Types)

    ;Store L in C for later use
    ld c, l

    ;Place the object at the slot
    ld a, b
    ld [hl], a

    ;Get pointer to object start subroutine
    add a, a ; A *= 2
    ld l, a
    ld h, high(Object_StartRoutinePointers)

    ld a, [hl+]
    ld h, [hl]
    ld l, a

    rst RunSubroutine

    ret

Object_Update:
    ld hl, Object_Types
    
    .objectUpdateLoop ; 34 cycles per loop, which is 8704 cycles for a full array, not counting object update routine
        ;Check object type
        ld a, [hl]

        ;If object type is $FF, skip this entry
        inc a
        jr z, .continue

        ;If object type is $00, stop the loop
        dec a
        ret z

        ;Otherwise, turn the object type into an offset
        add a, a ; a *= 2

        ;Save l to c for later use
        ld c, l

        push hl 

        ;Get a pointer (HL = Object_UpdateRoutinePointers+2*Object_Type)
        ld h, high(Object_UpdateRoutinePointers)
        ld l, a

        ld a, [hl+]
        ld h, [hl]
        ld l, a

        rst RunSubroutine ; all subroutines should start with LD H, B\ LD L, C

        pop hl

        .continue
            inc l
            ld h, high(Object_Types)
            jr .objectUpdateLoop
    ret

Object_CheckOnScreen: 
    ;B = current check slot, (increment it after reading)
        ld hl, wCurrCheckOnScreenObj
        ld b, [hl]
        inc [hl]
    
    ;DE = object types + object slot
        ld d, high(Object_Types) ; object types
        ld e, b ; + object slot

    ;HL = object table + 16 * current slot
        ;prepare 16x
        swap b

        ;HL = object table
        ld h, high(Object_TableStart)

        ;HL += 16 * current slot (high byte)
        ld a, b
        and $0F
        or h
        ld h, a

        ;HL += 16 * current slot (low byte)
        ld a, b
        and $F0
        ld l, a

    ;Read object type
        ld a, [de]

    ;If removed slot $FF, return
        inc a
        ret z

    ;If end of array marker $00, reset counters and return
        dec a
        jr nz, .otherwise

        xor a ; ld a, 0
        ld [wCurrCheckOnScreenObj], a
        ld c, 1 ; loop counter in main game loop
        ret

    .otherwise

    ;Otherwise, check if off screen
        ;Skip state, velocity, and pixel x
            inc l
			inc l
			inc l

        ;X position
            ;Read player tile pos
            ld a, [wPlayerPos.x_metatile]
            ld b, a

            ;Read object tile pos
            ld a, [hl+]

            sub b
            ;if ((obj.x - player.x) > 11): yes it's off screen
            cp 12
            jr nc, .offScreen

            ;if ((obj.x - player.x) < -9): yes it's off screen
            cp -9
            jr nc, .offScreen

        ;Y position
            ;Read player tile pos
            ld a, [wPlayerPos.y_metatile]
            ld b, a

            ;Read object tile pos
            inc l ; move to tile pos y
			inc l
            ld a, [hl+] ; read it

            sub b
            ;if ((obj.y - player.y) > 9): yes it's off screen
            cp 10
            jr nc, .offScreen

            ;if ((obj.y - player.y) < -9): yes it's off screen
            cp -9
            jr nc, .offScreen

    .onScreen
        ld a, l
        and $F0
        ld l, a
        res OBJSTATE_OFFSCREEN, [hl]

        ret

    .offScreen
        ld a, l
        and $F0
        ld l, a
        set OBJSTATE_OFFSCREEN, [hl]

        ret
;Input: A - object id
Object_DestroyCurrent:
    push hl
    ;Go to
    ld l, a
    ld h, high(Object_Types)

    ld [hl], OBJTYPE_REMOVED
    ;call Object_CleanTypeArray
    pop hl
    ret 

;Uses ABHL
Object_CleanTypeArray:
    ;Start at the end
    ld hl, Object_Types

    ;Loop over Object_Types backwards
    .loop
        dec l
        ;Read type
        ld a, [hl]

        ;If $00, we're good
        or a
        jr z, .notWriteZero

        ;If $FF, write a 0
        inc a
        jr z, .writeZero

        ;Otherwise, we've encountered a valid object, which means we found the end of the array, so let's get outta here
        ret
    
        .writeZero
            ld [hl], 0
        .notWriteZero
            dec l
            inc l
            jr nz, .loop

    ret

Object_Start_None:
Object_Update_None:
Object_Draw_None:
Object_PlyColl_None:
    ld l, c
    ret

PrepareSpriteDraw:
    ;Get pointer to object table entry
    swap c

    ld a, c
    and $0F
    add high(Object_TableStart)
    ld h, a

    ld a, c
    and $F0
    ld l, a

    ;Check if off screen, and return if so
    bit 7, [hl]
    ret nz

	;Move to Y, and go through this object backwards
    ld a, l
	add 6
	ld l, a

	push de
	;GOAL
		;BC = XY
	;Get Y position
		;Get camera offset - save in C temporarily
			ld a, [wPlayerPos.y_metatile]
			dec a ; offset
			and $0F
			ld c, a
			ld a, [wPlayerPos.y_subpixel]
			and $F0
			add c
			swap a
			ld c, a
		;Get object coords - uses D temporarily
			ld a, [hl-]
			and $0F
			ld d, a
			ld a, [hl-]
			and $F0
			or d
			swap a
			sub c
		;Save result to C
			ld c, a
		dec l
	;Get X position
		;Get camera offset - save in B temporarily
			ld a, [wPlayerPos.x_metatile]
			and $0F
			ld b, a
			ld a, [wPlayerPos.x_subpixel]
			and $F0
			add b
			swap a
			ld b, a
		;Get object coords - uses D temporarily
			ld a, [hl-]
			and $0F
			ld d, a
			ld a, [hl-]
			and $F0
			or d
			swap a
			sub b
		;Save to B
			ld b, a
	pop de
	xor a ; make sure z flag is set - z flag is used earlier to signify whether or not to draw
	ret