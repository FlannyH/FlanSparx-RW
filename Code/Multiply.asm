Section "LUTs", ROM0, ALIGN[8]
Mul4LUT:
DEF NUM1 = 0
rept 16
DEF NUM2 = 0
    rept 16
        db (NUM1*NUM2) & $FF
DEF NUM2 = NUM2 + 1
    endr
DEF NUM1 = NUM1 + 1
endr

Section "Multiply", ROM0
;HL = B * C, reads from BC, writes to ADEHL
Mul8x8to16:
    ld d, high(Mul4LUT)
    ld h, 0

    ;LxR - A * D
        ;A = $0A
        ld a, b
        swap a
        and $0F
        ld e, a

        ;A |= $D0
        ld a, c
        and $0F
        swap a
        or e
        
        ;A = Mul4LUT[A]
        ld e, a
        ld a, [de]
        ld l, a

    ;RxL - B * C
        ;A = $0B
        ld a, b
        and $0F
        ld e, a

        ;A |= $C0
        ld a, c
        and $F0
        or e
        
        ;A = Mul4LUT[A]
        ld e, a
        ld a, [de]

        ;Add together and put into HL
        add l
        ld l, a
        adc h
        sub l
        ld h, a

    ;Multiply by $10
        add hl, hl
        add hl, hl
        add hl, hl
        add hl, hl

    ;RxR - B * D
        ;A = $0B
        ld a, b
        and $0F
        ld e, a

        ;A |= $D0
        ld a, c
        and $0F
        swap a
        or e
        
        ;A = Mul4LUT[A]
        ld e, a
        ld a, [de]

        ;Add to L
        add l
        ld l, a
        adc h
        sub l
        ld h, a

    ;LxL - A * C
        ;A = $0A
        ld a, b
        swap a
        and $0F
        ld e, a

        ;A |= $C0
        ld a, c
        and $F0
        or e
        
        ;A = Mul4LUT[A]
        ld e, a
        ld a, [de]

        ;Add to H
        add h
        ld h, a
    ret