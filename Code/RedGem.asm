Section "Red Gem", ROM0
Object_Start_RedGem:
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

    ;Populate object slot
        xor a

        ;State = 0
        ld [hl+], a

        ;PosXfine = 0
        ld [hl+], a

        ;PosX = map data pointer % 0x80 - maps are 128 tiles wide
        ld a, e
        and $7F
        ld [hl+], a

        ;PosYfine = 0
        xor a
        ld [hl+], a

        ;PosY = (map data pointer  - 0x4000) >> 7
        ld a, d ; a = high(map pointer)
        add a ; a *= 2
        and $7F
        
        ;still PosY - if bit 7 of e is 8, add 1 to PosY
        bit 7, e
        jr z, .noInc
            inc a
        .noInc

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