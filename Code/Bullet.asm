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

    ;Copy the player's position to this object
        ld a, [iScrollX] ; scrollX is the player's scroll
        add 8
        ld [hl+], a
        ld a, [bCameraX] ; cameraX is the player's tile position
        add 4
        ld [hl+], a

        ld a, [iScrollY]
        ld [hl+], a
        ld a, [bCameraY]
        add 4
        ld [hl+], a


    ;Copy the player's rotation to this object
        ld a, [bPlayerDirection]
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
        add 5
        ld e, a

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

        ld l, a
        ld h, high(Object_Types)

        ld [hl], OBJTYPE_REMOVED

    .endOfSubroutine
        ret