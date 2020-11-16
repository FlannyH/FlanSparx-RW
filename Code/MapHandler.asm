Section "Map Handler", ROM0
MapHandler_LoadStripX:
;debug
    ld a, 5
    ld [bCameraX], a
    ld a, 9
    ld [bCameraY], a

;Load the variables into BC for efficiency
; 8 cycles
    ld a, [bCameraX]
    ld b, a
    ld a, [bCameraY]
    ld c, a

;Get map data pointer from camera position - writes DE - reads ABC
; 11 cycles
    ;Note - map data is always 128 wide, so it's more efficient to calculate offsets
    
    ;Target state of DE: %01yyyyyy yxxxxxxx - the 01 at the start will be done at the end
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

;Get VRAM destination pointer from camera position - writes BCHL - uses ABC
;VRAM uses 8x8 tiles, map data uses 16x16 tiles, convert first
; 24 cycles
    sla b
    sla c

    ;Target state of HL: %100110yy yyyxxxxx
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

    or $98 ; Make it point to the tilemap

    ld h, a

    ;Handle X coordinate
    ld a, b
    and $1F
    or l
    ld l, a

    ret