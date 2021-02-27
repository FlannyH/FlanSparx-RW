Section "Red Gem", ROM0
Object_Start_RedGem:
    ;HL = Object_TableStart + (slot_id * 16)
        ;high byte = high(Object_TableStart) + slot_id >> 4
        ld a, l ; retrieve current object slot id
        swap a
        and $0F
        add high(Object_TableStart)
        ld h, a

        ;low byte = slot_id << 4
        ld a, c ; retrieve current object slot id
        swap a
        and $F0
        ld l, a

    ;Populate object slot
        xor a

        ;State = 0
        ld [hl+], a

        ;PosXfine = 0
        ld [hl+], a

        ;PosX = current tile X
        ld a, [bRegStorage1]
        and $7F
        ld [hl+], a

        ;PosYfine = 0
        xor a
        ld [hl+], a

        ;PosY = current tile Y
        ld a, [bRegStorage2]
        and $7F

        ld [hl+], a

        ;Fill the rest of the object slot with zeros
        xor a
        ld b, 12
        .loop
            ld [hl+], a
            dec b
            jr nz, .loop

    ret

Object_Update_RedGem:
    ld l, c

    ;Get pointers to object data
        ;H = $D0 + (id >> 4)
        ld a, c
        swap a 
        and $0F
        add high(Object_TableStart)
        ld h, a

        ;L = (id << 4)
        ld a, c
        swap a 
        and $F0
        ld l, a

    ;Handle state
        bit OBJSTATE_OFFSCREEN, [hl]
        jr nz, .unloadGem
        inc l

    ret

    .unloadGem
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
        jp Object_DestroyCurrent

Object_Draw_RedGem:
    push hl
    push bc
    call PrepareSpriteDraw

    ;Prepare pointer to sprite order entry
    ld hl, SprRedGem
    call Object_DrawSingle
    ld a, c
    add 8
    ld c, a
    call Object_DrawSingle
    
    pop bc
    pop hl
    
    dec b

    ret

Object_PlyColl_RedGem:
    ;Get pointer to table entry
        swap b
        ld a, b
        and $F0
        ld l, a

        ld a, b
        and $0F
        or high(Object_TableStart)
        ld h, a

    ;Get X coordinate
        inc l
        ;A = PositionX * 16 + PositionXfine
            ld a, [hl+]
            ld b, a ; PositionXfine
            ld a, [hl+] ; PositionX
            swap a ; PositionX * 16
            and $F0
            add b ; +
        ld c, a

    ;Get player X
        inc l
        ;A = PositionX * 16 + PositionXfine
            ld a, [iScrollX]
            ld b, a ; PositionXfine
            ld a, [bCameraX] ; PositionX
            swap a ; PositionX * 16
            and $F0
            add b ; +
    
    ;If abs(playerX - objectX) > 8
        sub c ; playerX - objectX
        bit 7, a ; abs
        jr z, .notNegativex
            cpl
            dec a
        .notNegativex
        cp 9
    ret nc ; do nothing if X is not in range
    
    ;Get Y coordinate
        inc l
        ;A = PositionY * 16 + PositionYfine
            ld a, [hl+]
            ld b, a ; PositionYfine
            ld a, [hl+] ; PositionY
            swap a ; PositionY * 16
            and $F0
            add b ; +
        ld c, a

    ;Get player Y
        inc l
        ;A = PositionY * 16 + PositionYfine
            ld a, [iScrollY]
            ld b, a ; PositionYfine
            ld a, [bCameraY] ; PositionY
            swap a ; PositionY * 16
            and $F0
            add b ; +
    
    ;If abs(playerY - objectY) > 8
        sub c ; playerY - objectY
        bit 7, a ; abs
        jr z, .notNegativey
            cpl
            dec a
        .notNegativey
        cp 9
    ret nc ; do nothing if X is not in range

    ;If we get here, there is collision. For now, trigger an error
    call ErrorHandler
    ret