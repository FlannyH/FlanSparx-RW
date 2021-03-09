include "constants.asm"
include "hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Map Handler", ROM0
;Usage - MapHandler_GetPointers x_offset, y_offset.
;Takes the current camera position, and turns it into map (DE) and VRAM (HL) pointers.
;Thrashes ABC, stores result in DEHL.
MapHandler_GetPointers: macro
;Load the variables into BC for efficiency
    ld a, [bCameraX]
    add \1 ; x offset
    ld b, a
    ld [bRegStorage1], a
    ld a, [bCameraY]
    add \2 ; y offset
    ld c, a
    ld [bRegStorage2], a

    MapHandler_GetMapDataPointer

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

HandleGBCpalettes: macro
    ;Skip if not Gameboy Color
    ld c, a ; save tile ID in C
    ld a, [bGameboyType]
    cp GAMEBOY_COLOR
    jr nz, .nopalettes

    ;Otherwise, write palette index to VRAM

    ;Prepare DE
    ld a, c
    push de
    ld de, tileset_crawdad_palassign
    add e
    ld e, a

    ld a, bank(tileset_crawdad_palassign)
    ld [set_bank], a

    ;Switch to VRAM attribute bank
    ld a, 1
    ld [rVBK], a
    
    ;Write top part
    ld a, [de]

    waitForRightVRAMmode

    ld [hl+], a
    inc e
    ld a, [de]
    ld [hl+], a
    inc e

    ;Move to bottom
    ld a, l
    add $1E
    ld l, a

    ;Write bottom part
    ld a, [de]
    ld [hl+], a
    inc e
    ld a, [de]
    ld [hl-], a

    ;Move back to start of tile
    ld a, l
    sub $20
    ld l, a

    ;Switch to VRAM tile bank
    xor a ; ld a, 0
    ld [rVBK], a

    pop de

    .nopalettes
    ld a, c
endm

;Input: A - enemy ID
HandleObjectTile:
    push hl
    push bc
    push de
    
        ld l, a ; low byte of HL
        ld [bRegStorage3], a

    ;Check if not flagged as collected
    call GetCollectableFlag
    jr nz, .end

    ld a, [bMapLoaded] ; set rom bank to current map
    ld [set_bank], a

    ld h, high(OBJDATA) ; high byte of HL

    ld b, [hl] ; Load object type
    call Object_SpawnObject

    .end

    pop de
    pop bc
    pop hl

    ret

m_MapHandler_LoadStripX:
    MapHandler_GetPointers b, c ; 48 cycles
   
    ld b, 13
    .copyLoop ; One loop is 31 cycles
        ;Read metatile index
        ld a, [bMapLoaded]
        ld [set_bank], a
        ld a, [de]

        ;If it's an object
        cp $40 ; Compare the metatile index with $40 - there are 64 different tiles, everything beyond that is objects
        jr c, .noObject

        ;If the metatile index is an object
        sub $40
        call HandleObjectTile

        ;Set the tile below the enemy to be a ground tile
        ld a, $01
        
        .noObject
        ;Multiply by 4 - one metatile has 4 tiles, and they're aligned in memory
        add a, a
        add a, a

        ;Make sure VRAM is accessible
        HandleGBCpalettes
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
        SubConst8fromR16 h, l, $20

        ;Wrap fix - basically make sure the pointer is aligned to a 16x16 grid by setting bit 1 of the Y coordinate to 0
        res 5, l

        ;Counter
        inc de
        ld a, [bRegStorage1]
        inc a
        ld [bRegStorage1], a
        dec b
        jr nz, .copyLoop

    ret

m_MapHandler_LoadStripY:
    MapHandler_GetPointers, b, c ; 48 cycles

    ld b, 11
    .copyLoop
        ;Read metatile index
        ld a, [bMapLoaded]
        ld [set_bank], a
        ld a, [de]

        ;If it's an object
        cp $40 ; Compare the metatile index with $40 - there are 64 different tiles, everything beyond that is objects
        jr c, .noObject

        ;If the metatile index is an object
        sub $40
        call HandleObjectTile

        ;Set the tile below the enemy to be a ground tile
        ld a, $01

        .noObject
        ;Multiply by 4 - one metatile has 4 tiles, and they're aligned in memory
        add a, a
        add a, a

        ;Make sure VRAM is accessible
        HandleGBCpalettes
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
        AddConst8toR16 h, l, $1E

        ;Wrap fix - basically if h == $9C, h -= 4
        res 2, h

        ;Move map data pointer one tile down
        ld a, [bMapWidth]
        add e
        ld e, a
        adc d
        sub e
        ld d, a

        ;Counter
        ld a, [bRegStorage2]
        inc a
        ld [bRegStorage2], a
        dec b
        jr nz, .copyLoop

    ret

;Loads a vertical strip of tiles at an offset. Uses all registers
;Usage: MapHandler_LoadStripY x, y
MapHandler_LoadStripY: macro
    lb bc, \1, \2
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
    add 8
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

HandleOneTileStrip:
    ld hl, bBooleans
    
    bit BF_SCHED_LD_RIGHT, [hl]
    jr nz, .loadRight
    
    bit BF_SCHED_LD_UP, [hl]
    jr nz, .loadUp
    
    bit BF_SCHED_LD_LEFT, [hl]
    jr nz, .loadLeft
    
    bit BF_SCHED_LD_DOWN, [hl]
    jr nz, .loadDown

    ret

    .loadRight
        res BF_SCHED_LD_RIGHT, [hl]
        MapHandler_LoadStripY 11, -1
        ret
    .loadUp
        res BF_SCHED_LD_UP, [hl]
        MapHandler_LoadStripX -1, 0
        ret
    .loadLeft
        res BF_SCHED_LD_LEFT, [hl]
        MapHandler_LoadStripY 0, -1
        ret
    .loadDown
        res BF_SCHED_LD_DOWN, [hl]
        MapHandler_LoadStripX -1, 9
        ret