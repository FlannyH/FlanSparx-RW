include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Player Handler", ROM0

;Handles input
;- Uses ABHL
Player_HandleInput:
    ;Debug: if B+Select, crash the game
        ldh a, [hJoypadCurrent]
        cp (1 << J_B | 1 << J_SELECT)
        jr nz, .endIf
            call ErrorHandler
            ret
        .endIf

    ;Handle shoot timer - if not zero, count it down, otherwise, spawn a bullet if holding A
    ld a, [wShootTimer]

    or a ; cp 0
    jr nz, .countTimer
    
    
    ;A?
        ;Get joypad
        ldh a, [hJoypadCurrent]
        bit J_A, a
        jr z, .afterBullet ; do not spawn if not holding A

        ;Otherwise, spawn bullet
            ;Reset timer and spawn the bullet
            ld a, BULLET_FIRERATE_NORMAL
            ld [wShootTimer], a

            ld b, OBJTYPE_BULLET
            call Object_SpawnObject

            ;Then go to the rest of the code
            jr .afterBullet

        .countTimer
            ;Decrease the shoot timer and not spawn
            dec a
            ld [wShootTimer], a

        .afterBullet

    ;Direction will be stored in B
    ;Right?    
        ;Get joypad
        ldh a, [hJoypadCurrent]
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

    ;Up     is  1 2 3
    ;Down   is  5 6 7
    ;Left   is  3 4 5
    ;Right  is  7 0 1
    .handleRight
        ld b, D_RIGHT

        ;Inc if up pressed
        ldh a, [hJoypadCurrent]
        bit J_UP , a
        jr z, .noInc1
            inc b
        .noInc1

        ;Dec if down pressed
        ldh a, [hJoypadCurrent]
        bit J_DOWN , a
        jr z, .noDec1
            ld b, D_DOWNRIGHT
        .noDec1

        jr .handleMovement

    .handleLeft
        ld b, D_LEFT

        ;Dec if up pressed
        ldh a, [hJoypadCurrent]
        bit J_UP , a
        jr z, .noInc2
            dec b
        .noInc2

        ;Inc if down pressed
        ldh a, [hJoypadCurrent]
        bit J_DOWN , a
        jr z, .noDec2
            inc b
        .noDec2

        jr .handleMovement

    .handleUp
        ld b, D_UP
        jr .handleMovement
    
    .handleDown
        ld b, D_DOWN
        jr .handleMovement

    .afterPlayerInput
        ;Charge if B is held down
            ldh a, [hJoypadCurrent]
            bit J_B, a
            jr nz, Charge
        ret

    .handleMovement
        ;Save direction
            ld a, b
            ld [wPlayerDirection], a

        ;Charge if B is held down
            ldh a, [hJoypadCurrent]
            bit J_B, a
            jr nz, Charge

        ;Move normally otherwise
            jp MoveNormal

Charge:
    ;Get direction and jump to corresponding code
        ld a, [wPlayerDirection]
        or a ; cp a, D_RIGHT
        jr z, .right
        dec a ; cp a, D_UPRIGHT
        jr z, .upright
        dec a ; cp a, D_UP
        jr z, .up
        dec a ; cp a, D_UPLEFT
        jr z, .upleft
        dec a ; cp a, D_LEFT
        jr z, .left
        dec a ; cp a, D_DOWNLEFT
        jr z, .downleft
        dec a ; cp a, D_DOWN
        jr z, .down
        dec a ; cp a, D_DOWNRIGHT
        jr z, .downright
        ;otherwise, crash the game
        rst $38

        .right
            ld16const wCurrMoveSpeed, SPEED_PLAYER_CHARGE_STRAIGHT
            jp ScrollRight
        .upright
            ld16const wCurrMoveSpeed, SPEED_PLAYER_CHARGE_DIAGONAL
            call ScrollRight
            jp ScrollUp
        .up
            ld16const wCurrMoveSpeed, SPEED_PLAYER_CHARGE_STRAIGHT
            jp ScrollUp
        .upleft
            ld16const wCurrMoveSpeed, SPEED_PLAYER_CHARGE_DIAGONAL
            call ScrollLeft
            jp ScrollUp
        .left
            ld16const wCurrMoveSpeed, SPEED_PLAYER_CHARGE_STRAIGHT
            jp ScrollLeft
        .downleft
            ld16const wCurrMoveSpeed, SPEED_PLAYER_CHARGE_DIAGONAL
            call ScrollLeft
            jp ScrollDown
        .down
            ld16const wCurrMoveSpeed, SPEED_PLAYER_CHARGE_STRAIGHT
            jp ScrollDown
        .downright
            ld16const wCurrMoveSpeed, SPEED_PLAYER_CHARGE_DIAGONAL
            call ScrollRight
            jp ScrollDown
MoveNormal:
    ;Get direction and jump to corresponding code
        ld a, [wPlayerDirection]
        or a ; cp a, D_RIGHT
        jr z, .right
        dec a ; cp a, D_UPRIGHT
        jr z, .upright
        dec a ; cp a, D_UP
        jr z, .up
        dec a ; cp a, D_UPLEFT
        jr z, .upleft
        dec a ; cp a, D_LEFT
        jr z, .left
        dec a ; cp a, D_DOWNLEFT
        jr z, .downleft
        dec a ; cp a, D_DOWN
        jr z, .down
        dec a ; cp a, D_DOWNRIGHT
        jr z, .downright

        .right
            ld16const wCurrMoveSpeed, SPEED_PLAYER_REGULAR_STRAIGHT
            jp ScrollRight
        .upright
            ld16const wCurrMoveSpeed, SPEED_PLAYER_REGULAR_DIAGONAL
            call ScrollRight
            jp ScrollUp
        .up
            ld16const wCurrMoveSpeed, SPEED_PLAYER_REGULAR_STRAIGHT
            jp ScrollUp
        .upleft
            ld16const wCurrMoveSpeed, SPEED_PLAYER_REGULAR_DIAGONAL
            call ScrollLeft
            jp ScrollUp
        .left
            ld16const wCurrMoveSpeed, SPEED_PLAYER_REGULAR_STRAIGHT
            jp ScrollLeft
        .downleft
            ld16const wCurrMoveSpeed, SPEED_PLAYER_REGULAR_DIAGONAL
            call ScrollLeft
            jp ScrollDown
        .down
            ld16const wCurrMoveSpeed, SPEED_PLAYER_REGULAR_STRAIGHT
            jp ScrollDown
        .downright
            ld16const wCurrMoveSpeed, SPEED_PLAYER_REGULAR_DIAGONAL
            call ScrollRight
            jp ScrollDown

ObjUpdate_Player:
    call GetJoypadStatus
    call Player_HandleInput
    call PlayerCollObject
    ;jp Player_Draw

Player_Draw:
    ;Get offset to sprite pattern for this direction - multiply by 4 to get actual entry
    ld a, [wPlayerDirection]
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
	
	ret


;Scrolls the camera down by 1 pixel.
;Writes all registers
ScrollDown:
    ;Increment Y scroll
    AddInt16 wScrollY, wCurrMoveSpeed

    ;Compare with 16
    cp 16

    ;If it's below 16, don't load any new tiles
    jr c, .doNotLoadNewTiles

    ;Otherwise, remove 16 from the scroll
    sub 16
    ld [wScrollY], a

    ;Update the camera position
    ld hl, wCameraY
    inc [hl]

;    ;Load new tiles to the bottom of the screen
;    MapHandler_LoadStripX -1, 9
    ;Schedule loading new tiles at the bottom
    ld hl, wBooleans
    set BF_SCHED_LD_DOWN, [hl]
    jr .collision

    .doNotLoadNewTiles
    ld [wScrollY], a
    ;jr .collision

    .collision
    call GetPlayerCollisionDown

    ;If collision, snap to grid
    or a ; cp 0
    ret z ; if no collision, return

    xor a ; ld a, 0
    ld [wScrollY], a
    ret

;Scrolls the camera up by 1 pixel.
;Writes all registers
ScrollUp:    
    ;Decrement Y scroll
    SubInt16 wScrollY, wCurrMoveSpeed

    ;If positive, don't load any new tiles
    bit 7, a
    jr z, .doNotLoadNewTiles

    ;Otherwise, add 16 to the scroll
    add 16
    ld [wScrollY], a

    ;Update the camera position
    ld hl, wCameraY
    dec [hl]

    ;Load new tiles to the top of the screen
    ;   MapHandler_LoadStripX -1, 0
    ;Schedule loading new tiles at the up
    ld hl, wBooleans
    set BF_SCHED_LD_UP, [hl]
    jr .collision

    .doNotLoadNewTiles
    ld [wScrollY], a
    ;jr .collision

    .collision
    call GetPlayerCollisionUp

    ;If collision, snap to grid
    or a ; cp 0
    ret z ; if no collision, return

    xor a ; ld a, 0
    ld [wScrollY], a

    ld hl, wCameraY
    inc [hl]
    ret

;Scroll the camera right by 1 pixel.
;Writes all registers
ScrollRight:
    ;Increment X scroll
    AddInt16 wScrollX, wCurrMoveSpeed

    ;If below 16, don't load any new tiles
    cp 16
    jr c, .doNotLoadNewTiles

    ;Otherwise, remove 16 from the scroll
    sub 16
    ld [wScrollX], a

    ;Update the camera position
    ld hl, wCameraX
    inc [hl]

;    ;Load new tiles to the right of the screen
;    MapHandler_LoadStripY 11, -1
    ;Schedule loading new tiles at the right
    ld hl, wBooleans
    set BF_SCHED_LD_RIGHT, [hl]
    jr .collision

    .doNotLoadNewTiles
    ld [wScrollX], a
    ;jr .collision

    .collision
    call GetPlayerCollisionRight

    ;If collision, snap to grid
    or a ; cp 0
    ret z ; if no collision, return

    xor a ; ld a, 0
    ld [wScrollX], a
    ret

;Scrolls the camera left by 1 pixel.
;Writes all registers
ScrollLeft:
    ;Decrement X scroll
    SubInt16 wScrollX, wCurrMoveSpeed

    ;If positive, don't load any new tiles
    bit 7, a
    jr z, .doNotLoadNewTiles

    ;Otherwise, add 16 to the scroll
    add 16
    ld [wScrollX], a

    ;Update the camera position
    ld hl, wCameraX
    dec [hl]

;    ;Load new tiles to the left of the screen
;    MapHandler_LoadStripY 0, -1
    ;Schedule loading new tiles at the left
    ld hl, wBooleans
    set BF_SCHED_LD_LEFT, [hl]
    jr .collision

    .doNotLoadNewTiles
    ld [wScrollX], a
    ;jr .collision

    .collision
    call GetPlayerCollisionLeft

    ;If collision, snap to grid
    or a ; cp 0
    ret z ; if no collision, return

    xor a ; ld a, 0
    ld [wScrollX], a

    ld hl, wCameraX
    inc [hl]
    ret