;Objects are saved in RAM
;The array is separated so every byte is a separate array
;This way, if you use HL as a pointer, you can change H to
;determine what you're loading, and then use L to determine
;which object slot you're loading from

    IF !DEF(OBJECT_VARIABLES)
OBJECT_VARIABLES SET 1

Object_TableStart equ $D000

;16 bytes per entry
Object_PositionXfine    equ $00
Object_PositionX        equ $01
Object_PositionYfine    equ $02
Object_PositionY        equ $03  
Object_Rotation         equ $04  
Object_Bullet_VelX      equ $05    
Object_Bullet_VelY      equ $06      
Object_State            equ $07    

ENDC


Section "Object Arrays 1", WRAMX[$D000]
Object_Table: ds $1000

Section "Object Arrays 2", WRAM0[$CD00]
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

        ;Save hl to bc for later use
        ld b, h
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

Object_Start_None:
Object_Update_None:
    ld h, b
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