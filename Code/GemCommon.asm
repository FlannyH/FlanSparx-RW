include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Common Gem Code", ROM0
Object_Start_GemCommon:
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
        ldh a, [hRegStorage1]
        and $7F
        ld [hl+], a

        ;PosYfine = 0
        xor a
        ld [hl+], a

        ;PosY = current tile Y
        ldh a, [hRegStorage2]
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

Object_Update_GemCommon:
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

;Input: E - amount (BCD) to add to the gem count
Obj_PlyColl_GemCommon:
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
    jr nc, .noCollision
        ;Add gems to gem count
        ld a, [wCurrGemDec2]
        add e
        daa
        ld [wCurrGemDec2], a
        ld a, [wCurrGemDec1]
        adc 0
        daa
        ld [wCurrGemDec1], a

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