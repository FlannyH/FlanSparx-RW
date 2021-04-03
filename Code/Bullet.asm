include "constants.asm"
include "hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Bullet", ROM0
Object_Start_Bullet:
    ;HL = Object_TableStart + (slot_id * 16)
        ;high byte = high(Object_TableStart) + slot_id >> 4
        ld a, c ; retrieve current object slot id
        swap a
        and $0F
        add high(Object_TableStart)
        ld h, a

        ;low byte = slot_id << 4
        ld a, c ; retrieve current object slot id
        swap a
        and $F0
        ld l, a

    ;Reset state variable
        xor a ; ld a, 0
        ld [hl+], a

    ;Copy the player's position to this object
        ldh a, [iScrollX] ; scrollX is the player's scroll
        add 4
        ld [hl+], a
        ldh a, [bCameraX] ; cameraX is the player's tile position
        add 5
        ld [hl+], a

        ldh a, [iScrollY]
        add 4
        ld [hl+], a
        ldh a, [bCameraY]
        add 4
        ld [hl+], a


    ;Copy the player's rotation to this object
        ldh a, [bPlayerDirection]
        ld [hl+], a

    ;Convert rotation into speed
        or a
        jr z, .right
        dec a
        jr z, .upright
        dec a
        jr z, .up
        dec a
        jr z, .upleft
        dec a
        jr z, .left
        dec a 
        jr z, .downleft
        dec a
        jr z, .down
        dec a
        jr z, .downright

    ;If we get here, rotation is invalid, return
        ret

    .right
        ld a, SPEED_BULLET_STRAIGHT
        ld [hl+], a
        xor a ; ld a, 0
        ld [hl+], a
        jr .afterSettingVelocity

    .upright
        ld a, SPEED_BULLET_DIAGONAL
        ld [hl+], a
        ld a, -SPEED_BULLET_DIAGONAL
        ld [hl+], a
        jr .afterSettingVelocity

    .up
        xor a ; ld a, 0
        ld [hl+], a
        ld a, -SPEED_BULLET_STRAIGHT
        ld [hl+], a
        jr .afterSettingVelocity

    .upleft
        ld a, -SPEED_BULLET_DIAGONAL
        ld [hl+], a
        ld a, -SPEED_BULLET_DIAGONAL
        ld [hl+], a
        jr .afterSettingVelocity

    .left
        ld a, -SPEED_BULLET_STRAIGHT
        ld [hl+], a
        xor a ; ld a, 0
        ld [hl+], a
        jr .afterSettingVelocity

    .downleft
        ld a, -SPEED_BULLET_DIAGONAL
        ld [hl+], a
        ld a, SPEED_BULLET_DIAGONAL
        ld [hl+], a
        jr .afterSettingVelocity

    .down
        xor a ; ld a, 0
        ld [hl+], a
        ld a, SPEED_BULLET_STRAIGHT
        ld [hl+], a
        jr .afterSettingVelocity

    .downright
        ld a, SPEED_BULLET_DIAGONAL
        ld [hl+], a
        ld a, SPEED_BULLET_DIAGONAL
        ld [hl+], a
        jr .afterSettingVelocity

    .afterSettingVelocity
        ret

Object_Update_Bullet:
    ld l, c

    ;Get pointers to object data
    ;HL to position x, DE to velocity x
        ;H = $D0 + (id >> 4)
        ld a, c
        swap a 
        and $0F
        add high(Object_TableStart)
        ld h, a
        ld d, a

        ;L = (id << 4)
        ld a, c
        swap a 
        and $F0
        ld l, a
        add 6
        ld e, a

    ;Handle state
        bit OBJSTATE_OFFSCREEN, [hl]
        jr nz, .destroyBullet
        inc l

    ;Add x velocity to position
    .handleVelX
        ;HL = HL+DE
        ld a, [de]
        add [hl]

        ;Check if fine pos <= 0
            bit 7, a
            jr z, .xNegativeNoChange

            ;If so, add 16, and decrease the tile pos
            add 16
            ld [hl+], a
            dec [hl] ; increase tile pos
            inc l

            jr .handleVelY
        
        .xNegativeNoChange

        ;Otherwise, check if fine pos >= 16
            cp 16
            jr c, .endVelX

            ;If so, subtract 16, and increase the tile pos
            sub 16
            ld [hl+], a
            inc [hl] ; increase tile pos
            inc l

            jr .handleVelY

        .endVelX
            ld [hl+], a
            inc l

    .handleVelY
        inc e
        ;HL = HL+DE
        ld a, [de]
        add [hl]

        ;Check if fine pos <= 0
            bit 7, a
            jr z, .yNegativeNoChange

            ;If so, add 16, and decrease the tile pos
            add 16
            ld [hl+], a
            dec [hl] ; increase tile pos
            inc l

            jr .endOfSubroutine
        
        .yNegativeNoChange

        ;Otherwise, check if fine pos >= 16
            cp 16
            jr c, .endVelY

            ;If so, subtract 16, and increase the tile pos
            sub 16
            ld [hl+], a
            inc [hl] ; increase tile pos
            inc l

            jr .endOfSubroutine

        .endVelY
            ld [hl+], a
            inc l
    
    ;Get collision tile coordinates (B - pos x, C - pos y)
        dec l
        ld c, [hl]
        dec l
        dec l
        ld b, [hl]
        push hl
        call GetCollisionAtBC
        pop hl
        jr z, .endOfSubroutine

        .destroyBullet
        ;If that tile is solid, destroy the bullet
        ;low nibble
        ld a, l
        and $F0
        swap a
        ld b, a

        ;high nibble
        ld a, h
        and $0F
        swap a
        or b

        ;Destroy the object
        jp Object_DestroyCurrent

    .endOfSubroutine
        ret

;Input: DE - shadow OAM, HL - sprite order
Object_DrawSingle:
    ;Write Y
    ld a, b
    ld [de], a
    inc e
    
    ;Write X
    ld a, c
    ld [de], a
    inc e

    ;Write tile id and attributes
    ld a, [hl+]
    ld [de], a
    inc e

    ld a, [hl+]
    ld [de], a
    inc e

    ret


;Input: DE - shadow oam start entry, B - how many sprite slots left, C - current object slot
Object_Draw_Bullet:
    push bc
    call PrepareSpriteDraw
    
    ;Prepare pointer to sprite order entry
    ld hl, SprBullet
    call Object_DrawSingle
    pop bc

    dec b

    ret