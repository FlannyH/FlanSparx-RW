include "constants.asm"
include "hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

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

        ;PosX = current tile X
        ldh a, [bRegStorage1]
        and $7F
        ld [hl+], a

        ;PosYfine = 0
        xor a
        ld [hl+], a

        ;PosY = current tile Y
        ldh a, [bRegStorage2]
        and $7F

        ld [hl+], a

        ;Fill the rest of the object slot with zeros
        xor a
        ld b, 11
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
    ld a, 1
    ldh [$FFFE], a
    ;Get pointer to table entry
        swap b
        ld a, b
        and $F0
        ld l, a

        ld a, b
        and $0F
        or high(Object_TableStart)
        ld h, a

    call GetObjPlyColl
        
    ;If collision
    dec d
    jr nz, .noCollision
        ;Add gems to gem count
        ldh a, [bCurrGemDec2]
        add $01
        daa
        ldh [bCurrGemDec2], a
        ldh a, [bCurrGemDec1]
        adc 0
        daa
        ldh [bCurrGemDec1], a

        ;Get object ID
        ld a, h
        swap a
        and $F0
        ld b, a
        ld a, l
        swap a
        and $0F
        or b

        ;Mark gem as collected
        ld c, a

        ;Get object ID
        ld h, high(Object_IDs)
        ld l, a
        ld a, [hl]
    
        push hl
        call SetCollectableFlag
        pop hl
        ld a, c

        ;Destroy object
        jp Object_DestroyCurrent
    .noCollision
    ret