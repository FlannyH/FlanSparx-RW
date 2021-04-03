include "constants.asm"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Collision Detection", ROM0
;Checks for collision at the current player position - 100 cycles
GetPlayerCollision: macro
    ;Go to the map bank
    ldh a, [bMapLoaded]
    ld [set_bank], a
    
    ;Load player position into BC, and add player offset
    ldh a, [bCameraX]
    add ($05 + \1)
    add a
    ld b, a
    ldh a, [bCameraY]
    add ($04 + \2)
    add a
    ld c, a

    ;Handle X scroll
    ldh a, [iScrollX]
    rla
    swap a
    and $01
    add b
    ld b, a
    ;ld [debug1], a
    
    ;Handle Y scroll
    ldh a, [iScrollY]
    rla
    swap a
    and $01
    add c
    ld c, a
    ;ld [debug2], a

    ;Save these coordinates for later
    push bc

    ;Get them back to metatile space
    srl b
    srl c

    ;Get position in map data
    MapHandler_GetMapDataPointer ; 12 cycles

    ;Get collision
    ld a, [de]
    ldh [bCollisionResult1], a

    ;Get the coordinates back
    pop bc

    ;Add one to either the x or y coordinate, depending on what the user set
    if (\3 == "left" || \3 == "right")
    ld a, 1
    add c
    ld c, a
    elif (\3 == "up" || \3 == "down")
    ld a, 1
    add b
    ld b, a
    endc

    ;Get them back to metatile space
    srl b
    srl c
    
    ;Get position in map data
    MapHandler_GetMapDataPointer ; 12 cycles

    ;Get collision
    ld a, [de]

    call IsSolid
    jr nz, .collision

    ldh a, [bCollisionResult1]
    call IsSolid
    jr nz, .collision

    .nocollision
    xor a ; ld a, 0
    ret


    .collision
    ld a, 1
endm

;Input: A - Tile ID
;Output: Z flag
;Uses: ABCHL
IsSolid:
    ;If A >= $40, not solid
    cp $40
    jr nc, .enemyspot

    ;Get pointer to right byte
    ld hl, tileset_solidness
    add l
    ld l, a

    ;Check solidness bit
    bit 0, [hl]
    ret

    ;Enemy spots load as ground tiles
    .enemyspot
    xor a ; Set Z flag
    ret



GetPlayerCollisionRight:
    GetPlayerCollision 1, 0, "right"
    ret
GetPlayerCollisionLeft:
    GetPlayerCollision 0, 0, "left"
    ret
GetPlayerCollisionUp:
    GetPlayerCollision 0, 0, "up"
    ret
GetPlayerCollisionDown:
    GetPlayerCollision 0, 1, "down"
    ret
    
;Input: BC - XY tile position on the map
GetCollisionAtBC:
    MapHandler_GetMapDataPointer
    ;Get tile id
    ld a, [de]
    jp IsSolid

;Check player is colliding with any objects
PlayerCollObject:
    ld hl, Object_Types
    .loop
        ;HL = &routine pointer
        ld a, [hl+]
        inc a
        jr z, .loop
        dec a
        ret z ; if type = 0, return

        add a

        push hl
        ld b, l
        dec b

        ld l, a
        ld h, high(Object_PlyCollRoutinePointers)

        ld a, [hl+]
        ld h, [hl]
        ld l, a
        
        ;call hl
        call RunSubroutine

        pop hl


        jr .loop

;Input: HL - object table entry pointer (start) - Output: D - 0 if no collision, 1 if collision - Destroys ABC, and the lower nibble of L
GetObjPlyColl:
    ld d, 0
    ;Handle Object X
        ;Fine
        inc l
        ldh a, [iScrollX]
        sub [hl]
        add 12
        bit 4, a
        jr z, .noCarryX
            sub $10
            scf
        .noCarryX
        ld b, a

        ;Tile
        ldh a, [bCameraX]
        adc 5 ; offset and carry in one instruction pog
        inc l
        sub [hl]

        ;If tile distance is $00, then theres collision, pog, move on
        or a
        jr z, .collisionX

        ;If >= $02, no collision, return
        cp 2
        ret nc

        ;If $01, theres collision if fine distance < 8
        ld a, b
        cp 8
        ret nc

    .collisionX

    ;Handle Object Y
        ;Fine
        inc l
        ldh a, [iScrollY]
        sub [hl]
        add 8
        bit 4, a
        jr z, .noCarryY
            sub $10
            scf
        .noCarryY
        ld b, a

        ;Tile
        ldh a, [bCameraY]
        adc 4 ; offset and carry in one instruction pog
        inc l
        sub [hl]

        ;If tile distance is $00, then theres collision, pog, move on
        or a
        jr z, .collisionY

        ;If >= $02, no collision, return
        cp 2
        ret nc

        ;If $01, theres collision if fine distance < 8
        ld a, b
        cp 8
        ret nc
    
    .collisionY

    inc d

    ret