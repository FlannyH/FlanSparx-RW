Section "Player Handler", ROM0

;Handles input
;- Uses AB
Player_HandleInput: MACRO
    ;Direction will be stored in B

    ld a, [bJoypadCurrent]

    ;B?
    ;bit J_B, a
    ;TODO spawn bullet object

    ;Right?
    bit J_RIGHT, a
    jr nz, .handleRight

    ;Left?
    bit J_LEFT, a
    jr nz, .handleLeft
    
    ;Up?
    bit J_UP, a
    jp nz, .handleUp

    ;Down?
    bit J_DOWN, a
    jp nz, .handleDown

    jp .afterPlayerInput

    ;RIGHT
    .handleRight
        ld a, [bJoypadCurrent]

        ;Top Right?
        bit J_UP, a
        jr nz, .UpRight

        ;Bottom Right?
        bit J_DOWN, a
        jr nz, .DownRight

        ;Just right
        ld16const iCurrMoveSpeed, SPEED_STRAIGHT
        call ScrollRight
        ld b, D_RIGHT
        jr .setDirection

    .UpRight
        ld16const iCurrMoveSpeed, SPEED_DIAGONAL
        call ScrollUp
        call ScrollRight
        ld b, D_UPRIGHT
        jr .setDirection
        
    .DownRight
        ld16const iCurrMoveSpeed, SPEED_DIAGONAL
        call ScrollDown
        call ScrollRight
        ld b, D_DOWNRIGHT
        jr .setDirection

    ;LEFT
    .handleLeft
        ld a, [bJoypadCurrent]

        ;Top Left?
        bit J_UP, a
        jr nz, .UpLeft

        ;Bottom Left?
        bit J_DOWN, a
        jr nz, .DownLeft

        ;Just left
        ld16const iCurrMoveSpeed, SPEED_STRAIGHT
        call ScrollLeft
        ld b, D_LEFT
        jr .setDirection

    .UpLeft
        ld16const iCurrMoveSpeed, SPEED_DIAGONAL
        call ScrollUp
        call ScrollLeft
        ld b, D_UPLEFT
        jr .setDirection
        
    .DownLeft
        ld16const iCurrMoveSpeed, SPEED_DIAGONAL
        call ScrollDown
        call ScrollLeft
        ld b, D_DOWNLEFT
        jr .setDirection

    ;UP/DOWN
    .handleUp
        ld16const iCurrMoveSpeed, SPEED_STRAIGHT
        call ScrollUp
        ld b, D_UP
        jr .setDirection

    .handleDown
        ld16const iCurrMoveSpeed, SPEED_STRAIGHT
        call ScrollDown
        ld b, D_DOWN

    .setDirection
        ld a, b
        ld [bPlayerDirection], a

    ;Get 

    .afterPlayerInput
ENDM

Player_Draw: MACRO
    ;Get offset to sprite pattern for this direction - multiply by 4 to get actual entry
    ld a, [bPlayerDirection]
    add a, a
    add a, a

    ;Convert the offset to an actual pointer
    add low(SpriteOrders_Player)
    ld d, high(SpriteOrders_Player)
    ld e, a

    ;We now have Y in A and X in C
    ;Go to Shadow OAM
    ld hl, pPlayerSpriteSlot

    ;Sprite 1
    ld a, 80
    ld [hl+], a ; Y
    ld a, 80
    ld [hl+], a ; X
    ld a, [de] 
    ld [hl+], a ; Tile ID
    inc e
    ld a, [de] 
    ld [hl+], a ; Attribute
    inc e
    ;Sprite 2
    ld a, 80
    ld [hl+], a ; Y
    ld a, 88
    ld [hl+], a ; X
    ld a, [de] 
    ld [hl+], a ; Tile ID
    inc e
    ld a, [de] 
    ld [hl+], a ; Attribute
    inc e


ENDM

ObjUpdate_Player:
    call GetJoypadStatus
    Player_HandleInput
    Player_Draw

    ret


;Scrolls the camera down by 1 pixel.
;Writes all registers
ScrollDown:
    ;Increment Y scroll
    AddInt16 iScrollY, iCurrMoveSpeed

    ;Compare with 16
    cp 16

    ;If it's below 16, don't load any new tiles
    jr c, .doNotLoadNewTiles

    ;Otherwise, remove 16 from the scroll
    sub 16
    ld [iScrollY], a

    ;Update the camera position
    ld hl, bCameraY
    inc [hl]

    ;Load new tiles to the bottom of the screen
    MapHandler_LoadStripX -1, 9
    jr .collision

    .doNotLoadNewTiles
    ld [iScrollY], a
    ;jr .collision

    .collision
    call GetPlayerCollisionDown

    ;If collision, snap to grid
    or a ; cp 0
    ret z ; if no collision, return

    xor a ; ld a, 0
    ld [iScrollY], a
    ret

;Scrolls the camera up by 1 pixel.
;Writes all registers
ScrollUp:    
    ;Decrement Y scroll
    SubInt16 iScrollY, iCurrMoveSpeed

    ;If positive, don't load any new tiles
    bit 7, a
    jr z, .doNotLoadNewTiles

    ;Otherwise, add 16 to the scroll
    add 16
    ld [iScrollY], a

    ;Update the camera position
    ld hl, bCameraY
    dec [hl]

    ;Load new tiles to the top of the screen
    MapHandler_LoadStripX -1, 0
    jr .collision

    .doNotLoadNewTiles
    ld [iScrollY], a
    ;jr .collision

    .collision
    call GetPlayerCollisionUp

    ;If collision, snap to grid
    or a ; cp 0
    ret z ; if no collision, return

    xor a ; ld a, 0
    ld [iScrollY], a

    ld hl, bCameraY
    inc [hl]
    ret

;Scroll the camera right by 1 pixel.
;Writes all registers
ScrollRight:
    ;Increment X scroll
    AddInt16 iScrollX, iCurrMoveSpeed

    ;If below 16, don't load any new tiles
    cp 16
    jr c, .doNotLoadNewTiles

    ;Otherwise, remove 16 from the scroll
    sub 16
    ld [iScrollX], a

    ;Update the camera position
    ld hl, bCameraX
    inc [hl]

    ;Load new tiles to the right of the screen
    MapHandler_LoadStripY 11, -1
    jr .collision

    .doNotLoadNewTiles
    ld [iScrollX], a
    ;jr .collision

    .collision
    call GetPlayerCollisionRight

    ;If collision, snap to grid
    or a ; cp 0
    ret z ; if no collision, return

    xor a ; ld a, 0
    ld [iScrollX], a
    ret

;Scrolls the camera left by 1 pixel.
;Writes all registers
ScrollLeft:
    ;Decrement X scroll
    SubInt16 iScrollX, iCurrMoveSpeed

    ;If positive, don't load any new tiles
    bit 7, a
    jr z, .doNotLoadNewTiles

    ;Otherwise, add 16 to the scroll
    add 16
    ld [iScrollX], a

    ;Update the camera position
    ld hl, bCameraX
    dec [hl]

    ;Load new tiles to the left of the screen
    MapHandler_LoadStripY 0, -1
    jr .collision

    .doNotLoadNewTiles
    ld [iScrollX], a
    ;jr .collision

    .collision
    call GetPlayerCollisionLeft

    ;If collision, snap to grid
    or a ; cp 0
    ret z ; if no collision, return

    xor a ; ld a, 0
    ld [iScrollX], a

    ld hl, bCameraX
    inc [hl]
    ret