;Objects are saved in RAM
;The array is separated so every byte is a separate array
;This way, if you use HL as a pointer, you can change H to
;determine what you're loading, and then use L to determine
;which object slot you're loading from

    IF !DEF(OBJECT_VARIABLES)
OBJECT_VARIABLES SET 1

Object_TableStart equ $D000

;16 bytes per entry
Object_State            equ $00
Object_PositionXfine    equ $01
Object_PositionX        equ $02
Object_PositionYfine    equ $03
Object_PositionY        equ $04  
Object_Rotation         equ $05  
Object_Bullet_VelX      equ $06    
Object_Bullet_VelY      equ $07      

ENDC


Section "Object Arrays 1", WRAMX[$D000]
Object_Table: ds $1000

Section "Object Arrays 2", WRAM0[$C800]
Object_IDs: ds $100
Object_Types: ds $100

Section "Object Manager", ROM0
Object_SpawnBullet:
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

    ;Store L in C for later use
    ld c, l

    ;Place the object at the slot
    ld a, OBJTYPE_BULLET
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
        ld [bCurrCheckOnScreenObj], a
        ld c, 1 ; loop counter in main game loop
        ret

    .otherwise

    ;Otherwise, check if off screen
        ;Skip state
            inc l

        ;X position
            ;Read player tile pos
            ld a, [bCameraX]
            ld b, a

            ;Read object tile pos
            inc l ; move to tile pos x
            ld a, [hl+] ; read it

            sub b
            ;if ((obj.x - player.x) > 8): yes it's off screen
            cp 9
            jr nc, .offScreen

            ;if ((obj.x - player.x) < -8): yes it's off screen
            cp -8
            jr nc, .offScreen

        ;X position
            ;Read player tile pos
            ld a, [bCameraY]
            ld b, a

            ;Read object tile pos
            inc l ; move to tile pos y
            ld a, [hl+] ; read it

            sub b
            ;if ((obj.y - player.y) > 8): yes it's off screen
            cp 9
            jr nc, .offScreen

            ;if ((obj.y - player.y) < -8): yes it's off screen
            cp -8
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
    ;Go to
    ld l, a
    ld h, high(Object_Types)

    ld [hl], OBJTYPE_REMOVED
    jp Object_CleanTypeArray
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

Object_Start_None:
Object_Update_None:
Object_Draw_None:
    ld l, c
    ret

Section "Update Routine Pointers", ROM0, ALIGN[8]
Object_UpdateRoutinePointers:
    dw Object_Update_None
    dw Object_Update_Bullet

Section "Start Routine Pointers", ROM0, ALIGN[8]
Object_StartRoutinePointers:
    dw Object_Start_None
    dw Object_Start_Bullet

Section "Draw Routine Pointers", ROM0, ALIGN[8]
Object_DrawRoutinePointers:
    dw Object_Draw_None
    dw Object_Draw_Bullet