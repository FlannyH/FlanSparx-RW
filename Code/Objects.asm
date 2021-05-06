include "Code/constants.asm"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Object Arrays 1", WRAMX[$D000]
Object_Table: ds $1000


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
    ldh a, [bRegStorage3]
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

    call RunSubroutine

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

        call RunSubroutine ; all subroutines should start with LD H, B\ LD L, C

        pop hl

        .continue
            inc l
            ld h, high(Object_Types)
            jr .objectUpdateLoop
    ret

Object_CheckOnScreen: 
    ;B = current check slot, (increment it after reading)
        ld hl, bCurrCheckOnScreenObj
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
        ldh [bCurrCheckOnScreenObj], a
        ld c, 1 ; loop counter in main game loop
        ret

    .otherwise

    ;Otherwise, check if off screen
        ;Skip state
            inc l

        ;X position
            ;Read player tile pos
            ldh a, [bCameraX]
            ld b, a

            ;Read object tile pos
            inc l ; move to tile pos x
            ld a, [hl+] ; read it

            sub b
            ;if ((obj.x - player.x) > 11): yes it's off screen
            cp 12
            jr nc, .offScreen

            ;if ((obj.x - player.x) < -9): yes it's off screen
            cp -9
            jr nc, .offScreen

        ;X position
            ;Read player tile pos
            ldh a, [bCameraY]
            ld b, a

            ;Read object tile pos
            inc l ; move to tile pos y
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
    or high(Object_TableStart)
    ld h, a

    ld a, c
    and $F0
    ld l, a

    ;Check if off screen, and return if so
    bit 7, [hl]
    ret nz
    inc l

    ;Get X position = PosXfine + (PosX << 4) - (bCameraX << 4 + high(iScroll))
    ;Get camera offset
    ;tiles
    ldh a, [bCameraX]
    swap a
    and $F0
    ld c, a

    ;pixels
    ldh a, [iScrollX]
    add c
    ld c, a

    ;handle actual object coordinates
    ld a, [hl+]
    sub c
    ld c, a
    ld a, [hl+]
    swap a
    and $F0
    add c
    ld c, a

    ;Get X position = PosXfine + (PosX << 4) - (bCameraX << 4 + high(iScroll))
    ;Get camera offset
    ;tiles
    ldh a, [bCameraY]
    swap a
    and $F0
    ld b, a

    ;pixels
    ldh a, [iScrollY]
    add b
    sub 16
    ld b, a

    ;handle actual object coordinates
    ld a, [hl+]
    sub b
    ld b, a
    ld a, [hl+]
    swap a
    and $F0
    add b
    ld b, a

    ret