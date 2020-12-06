Section "Map Handler", ROM0
;Usage - MapHandler_GetPointers x_offset, y_offset.
;Takes the current camera position, and turns it into map (DE) and VRAM (HL) pointers.
;Thrashes ABC, stores result in DEHL.
;Takes 47 cycles
MapHandler_GetPointers: macro
;Load the variables into BC for efficiency
; 12 cycles
    ld a, [bCameraX]
    add \1 ; x offset
    ld b, a
    ld a, [bCameraY]
    add \2 ; y offset
    ld c, a

;Get map data pointer from camera position - writes HL - reads ABC
; 11 cycles
    ;Note - map data is always 128 wide, so it's more efficient to calculate offsets
    
    ;Target state of HL: %01yyyyyy yxxxxxxx - the 01 at the start will be done at the end
    ;Handle D - Y coordinate
    ;ld a, c ; ld a, [bCameraY] - bCameraY is still in A
    ld d, a
    xor a ; ld a, 0 - clear A for use later
    srl d

    ;Handle E - Y coordinate
    rra
    ld e, a

    ;Handle E - X coordinate
    ld a, b

    ;Combine the 2 steps for E
    or e
    ld e, a

    ;Convert from an offset to a pointer by adding 0x4000 to the offset
    ;This can be done by simply setting bit 6 of register D, since maps can't be bigger than 128x128,
    ;meaning the max offset is $3FFF. This means the 2 most significant bits are unused anyway
    set 6, d

;Get VRAM destination pointer from camera position - writes BCHL - uses ADE
;VRAM uses 8x8 tiles, map data uses 16x16 tiles, convert from 16 space to 8 space first (mul by 2)
; 24 cycles
    sla b
    sla c

    ;Target state of DE: %100110yy yyyxxxxx
    ;Handle Y coordinate
    ld a, c ; ld a, [bCameraY]
    ld l, 0

    ;Shift through to L
    rra
    rr l
    rra
    rr l
    rra 
    rr l

    and %00000011 ; Stay inside the bounds
    or $98 ; Make it point to the tilemap

    ld h, a

    ;Handle X coordinate
    ld a, b
    and $1F
    or l
    ld l, a
endm

m_MapHandler_LoadStripX:
    MapHandler_GetPointers b, c ; 47 cycles
   
    ld b, 13
    .copyLoop ; One loop is 31 cycles
        ;Read metatile index
        ld a, [de]
        inc e

        ;If it's an object
        cp $40 ; Compare the metatile index with $40 - there are 64 different tiles, everything beyond that is objects
        jr c, .noObject

        ;If the metatile index is an object
        ;TODO object loading

        ;Set the tile below the enemy to be a ground tile
        ld a, $01
        
        .noObject
        ;Multiply by 4 - one metatile has 4 tiles, and they're aligned in memory
        add a, a
        add a, a

        ;Make sure VRAM is accessible
        waitForRightVRAMmode

        ;Write top 2 tiles
        ld [hl+], a
        inc a
        ld [hl+], a
        inc a

        ;Move to bottom - preserve A by storing it in C
        ld c, a

        ld a, l
        add $1E
        ld l, a

        ld a, c

        ;Write bottom 2 tiles
        ld [hl+], a
        inc a
        ld [hl+], a

        ;Move to top of next tile
        ld a, l ;lower
        sub $20
        ld l, a
        ld a, h ;upper
        sbc 0
        ld h, a

        ;Wrap fix - basically make sure the pointer is aligned to a 16x16 grid by setting bit 1 of the Y coordinate to 0
        res 5, l

        ;Counter
        dec b
        jr nz, .copyLoop

    ret

;Loads a horizontal strip of tiles at an offset. Uses all registers
;Usage: MapHandler_LoadStripX x, y
MapHandler_LoadStripX: macro
    ld b, \1
    ld c, \2
    call m_MapHandler_LoadStripX
endm

m_MapHandler_LoadStripY:
    MapHandler_GetPointers, b, c ; 47 cycles

    ld b, 11
    .copyLoop
        ;Read metatile index
        ld a, [de]

        ;If it's an object
        cp $40 ; Compare the metatile index with $40 - there are 64 different tiles, everything beyond that is objects
        jr c, .noObject

        ;If the metatile index is an object
        ;TODO object loading

        ;Set the tile below the enemy to be a ground tile
        ld a, $01

        .noObject
        ;Multiply by 4 - one metatile has 4 tiles, and they're aligned in memory
        add a, a
        add a, a

        ;Make sure VRAM is accessible
        waitForRightVRAMmode

        ;Write top 2 tiles
        ld [hl+], a
        inc a
        ld [hl+], a
        inc a
        
        ;Move to bottom - preserve A by storing it in C
        ld c, a

        ld a, l
        add $1E
        ld l, a

        ld a, c

        ;Write bottom 2 tiles
        ld [hl+], a
        inc a
        ld [hl+], a

        ;Move to top of next tile
        ld a, l ;lower
        add $1E
        ld l, a
        ld a, h ;upper
        adc 0
        ld h, a

        ;Wrap fix - basically if h == $9C, h -= 4
        res 2, h

        ;Move map data pointer one tile down
        ld a, e
        add 128
        ld e, a
        ld a, d
        adc 0
        ld d, a

        ;Counter
        dec b
        jr nz, .copyLoop

    ret

;Loads a vertical strip of tiles at an offset. Uses all registers
;Usage: MapHandler_LoadStripY x, y
MapHandler_LoadStripY: macro
    ld b, \1
    ld c, \2
    call m_MapHandler_LoadStripY
endm

;Sets the scroll registers based on the camera and scroll position variables.
;Writes to AB.
;28 cycles
SetScroll:
    ;Horizontal
    ld a, [bCameraX]
    swap a
    and $F0
    ld b, a
    ld a, [iScrollX]
    add b
    ld [rSCX], a

    ;Vertical scroll
    ld a, [bCameraY]
    swap a
    and $F0
    ld b, a
    ld a, [iScrollY]
    add b
    ld [rSCY], a

    ret