include "Graphics/tileset_collision.asm"
Section "Collision Detection", ROM0
;Checks for collision at the current player position - 100 cycles
GetPlayerCollision: macro
    ;Go to the map bank
    ld a, [bMapLoaded]
    ld [set_bank], a
    
    ;Load player position into BC, and add player offset
    ld a, [bCameraX]
    add ($05 + \1)
    add a
    ld b, a
    ld a, [bCameraY]
    add ($04 + \2)
    add a
    ld c, a

    ;Handle X scroll
    ld a, [iScrollX]
    rla
    swap a
    and $01
    add b
    ld b, a
    ld [debug1], a
    
    ;Handle Y scroll
    ld a, [iScrollY]
    rla
    swap a
    and $01
    add c
    ld c, a
    ld [debug2], a

    ;Save these coordinates for later
    push bc

    ;Get them back to metatile space
    srl b
    srl c

    ;Get position in map data
    MapHandler_GetMapDataPointer ; 12 cycles

    ;Get collision
    ld a, [de]
    ld [bCollisionResult1], a

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

    ld a, [bCollisionResult1]
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

    call IsSolid
    
    ret