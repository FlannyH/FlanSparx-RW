include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Map Handler", ROM0
;Usage - ld d, x_offset; ld e, y_offset; call MapHandler_GetPointers
;Takes the current camera position, and turns it into map (DE) and VRAM (HL) pointers.
;Thrashes ABC, stores result in DEHL.
MapHandler_GetPointers:
;Load the variables into BC for efficiency
    ld a, [wPlayerPos.x_metatile]
    add d ; x offset
    ld b, a
    ld [hRegStorage1], a
    ld a, [wPlayerPos.y_metatile]
    add e ; y offset
    ld c, a
    ld [hRegStorage2], a

    call MapHandler_GetMapDataPointer

;Get VRAM destination pointer from camera position - writes BCHL - uses ADE
;VRAM uses 8x8 tiles, map data uses 16x16 tiles, convert from 16 space to 8 space first (mul by 2)
; 24 cycles
    sla b
    sla c

    ;Target state of DE: %100110yy yyyxxxxx
    ;Handle Y coordinate
    ld a, c ; ld a, [wPlayerPos.y_metatile]
    add a
    add a
    add a
    ld l, a
    ld h, %00100110

    ;Shift through to L
    add hl, hl
    add hl, hl

    ;Handle X coordinate
    ld a, b
    and $1F
    or l
    ld l, a
	
	ret

HandleGBCpalettes:
    ;Skip if not Gameboy Color
    ld c, a ; save tile ID in C
    ld a, [hGameboyType]
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
    waitUnlockVRAM_A
    ld a, [de]

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

	ret

;Input: A - enemy ID
HandleObjectTile:
    push hl
    push bc
    push de
    
        ld l, a ; low byte of HL
        ld [hRegStorage3], a

    ;Check if not flagged as collected
    call GetCollectableFlag
    jr nz, .end

    ld a, [hMapLoaded] ; set rom bank to current map
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
	ld d, b
	ld e, c
    call MapHandler_GetPointers
   
    ld b, 13
    .copyLoop
		push bc
        ;Read metatile index
        ld a, [hMapLoaded]
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
        call HandleGBCpalettes
		ld c, a
        waitUnlockVRAM_A
		ld a, c


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

        waitUnlockVRAM_A
        ld a, c

        ;Write bottom 2 tiles
        ld [hl+], a
        inc a
        ld [hl+], a

        ;Move to top of next tile
		ld a, l ; lower
		sub $20
		ld l, a
		jr nc, :+
			dec h
		:

        ;Wrap fix - basically make sure the pointer is aligned to a 16x16 grid by setting bit 1 of the Y coordinate to 0
        res 5, l

        ;Counter
        inc de
        ld a, [hRegStorage1]
        inc a
        ld [hRegStorage1], a
		pop bc
        dec b
        jr nz, .copyLoop

    ret

m_MapHandler_LoadStripY:
	ld d, b
	ld e, c
    call MapHandler_GetPointers

    ld b, 11
    .copyLoop
		push bc
        ;Read metatile index
        ld a, [hMapLoaded]
        ld [set_bank], a
        ld a, [de]

        ;If it's an object
        cp $40 ; Compare the metatile index with $40 - there are 64 different tiles, everything beyond that is objects
        jr c, .noObject

        ;If the metatile index is an object
        sub $40
        ;call HandleObjectTile

        ;Set the tile below the enemy to be a ground tile
        ld a, $01

        .noObject
        ;Multiply by 4 - one metatile has 4 tiles, and they're aligned in memory
        add a, a
        add a, a

        ;Make sure VRAM is accessible
        call HandleGBCpalettes
		ld c, a
        waitUnlockVRAM_A
		ld a, c

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

        waitUnlockVRAM_A
        ld a, c

        ;Write bottom 2 tiles
        ld [hl+], a
        inc a
        ld [hl+], a

        ;Move to top of next tile
		ld a, l
		add $1E
		ld l, a
		adc h
		sub l
		ld h, a

        ;Wrap fix - basically if h == $9C, h -= 4
        res 2, h

        ;Move map data pointer one tile down
        ld a, [hMapWidth]
        add e
        ld e, a
        adc d
        sub e
        ld d, a

        ;Counter
        ld a, [hRegStorage2]
        inc a
        ld [hRegStorage2], a
		pop bc
        dec b
        jr nz, .copyLoop

    ret

;Sets the scroll registers based on the camera and scroll position variables.
;Writes to AB.
;28 cycles
SetScroll:
    ;Horizontal
    ld a, [wPlayerPos.x_metatile]
    and $0F
    ld b, a
    ld a, [wPlayerPos.x_subpixel]
	and $F0
    add b
	swap a
    add 8
    ld [rSCX], a

    ;Vertical scroll
    ld a, [wPlayerPos.y_metatile]
    and $0F
    ld b, a
    ld a, [wPlayerPos.y_subpixel]
	and $F0
    add b
	swap a
    ld [rSCY], a

    ret

HandleOneTileStrip:
    ld hl, wBooleans
    
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
		lb bc, 11, -1
		jp m_MapHandler_LoadStripY
    .loadUp
        res BF_SCHED_LD_UP, [hl]
		lb bc, -1, 0
		jp m_MapHandler_LoadStripX
    .loadLeft
        res BF_SCHED_LD_LEFT, [hl]
		lb bc, 0, -1
		jp m_MapHandler_LoadStripY
    .loadDown
        res BF_SCHED_LD_DOWN, [hl]
		lb bc, -1, 9
		jp m_MapHandler_LoadStripX