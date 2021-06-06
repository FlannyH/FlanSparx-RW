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
		ld b, a

		;If wPlayerDirection is even, load straight speed, otherwise load diagonal speed
		bit 0, a
			ld a, SPEED_PLAYER_CHARGE_STRAIGHT
		jr z, ._no_diagonal
			ld a, SPEED_PLAYER_CHARGE_DIAGONAL
		._no_diagonal

		jr _Move

MoveNormal:
    ;Get direction and jump to corresponding code
        ld a, [wPlayerDirection]
		ld b, a

		;If wPlayerDirection is even, load straight speed, otherwise load diagonal speed
		bit 0, a
			ld a, SPEED_PLAYER_REGULAR_STRAIGHT
		jr z, ._no_diagonal
			ld a, SPEED_PLAYER_REGULAR_DIAGONAL
		._no_diagonal

	_Move:
		ld [wCurrMoveSpeed], a
		ld a, b

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
		rst $38

        .right
            jp ScrollRight
        .upright
            call ScrollRight
            jp ScrollUp
        .up
            jp ScrollUp
        .upleft
            call ScrollLeft
            jp ScrollUp
        .left
            jp ScrollLeft
        .downleft
            call ScrollLeft
            jp ScrollDown
        .down
            jp ScrollDown
        .downright
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
    ld hl, wShadowOAM

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
    ;wPlayerPos.y += wCurrMoveSpeed
    ld a, [wCurrMoveSpeed]
	ld b, a
	ld a, [wPlayerPos.y_low]
	add b
	ld [wPlayerPos.y_low], a
	
	;If metatile position didn't increase, don't load new tiles
    jr nc, .collision

    ;Otherwise, update the camera position
    ld hl, wPlayerPos.y_metatile
    inc [hl]

    ;Schedule loading new tiles at the right
    ld hl, wBooleans
    set BF_SCHED_LD_DOWN, [hl]
	
    .collision
	ld d, JF_DOWN
    call GetPlayerCollision

    ;If collision, snap to grid
    ret z ; if no collision, return

    xor a ; ld a, 0
    ld [wPlayerPos.y_subpixel], a
    ret

;Scrolls the camera up by 1 pixel.
;Writes all registers
ScrollUp:
    ;wPlayerPos.y -= wCurrMoveSpeed
    ld a, [wCurrMoveSpeed]
	ld b, a
	ld a, [wPlayerPos.y_low]
	sub b
	ld [wPlayerPos.y_low], a
	
	;If metatile position didn't decrease, don't load new tiles
    jr nc, ._no_tiles
		;Otherwise, update the camera position, and schedule tile load
		ld hl, wPlayerPos.y_metatile
		dec [hl]
		ld hl, wBooleans
		set BF_SCHED_LD_UP, [hl]
	._no_tiles
	
    ;Get collision - do nothing if no collision
	ld d, JF_UP
    call GetPlayerCollision
    ret z

    ;If collision, snap to grid
    xor a ; ld a, 0
    ld [wPlayerPos.y_subpixel], a

    ld hl, wPlayerPos.y_metatile
	inc [hl]

	;And make sure not to load any tiles (would be a CPU hog otherwise)
	ld hl, wBooleans
	res BF_SCHED_LD_UP, [hl]

    ret

;Scroll the camera right by 1 pixel.
;Writes all registers
ScrollRight:
    ;wPlayerPos.x += wCurrMoveSpeed
    ld a, [wCurrMoveSpeed]
	ld b, a
	ld a, [wPlayerPos.x_low]
	add b
	ld [wPlayerPos.x_low], a
	
	;If metatile position didn't increase, don't load new tiles
    jr nc, .collision

    ;Otherwise, update the camera position
    ld hl, wPlayerPos.x_metatile
    inc [hl]

    ;Schedule loading new tiles at the right
    ld hl, wBooleans
    set BF_SCHED_LD_RIGHT, [hl]
	
    .collision
	ld d, JF_RIGHT
    call GetPlayerCollision

    ;If collision, snap to grid
    ret z ; if no collision, return

    xor a ; ld a, 0
    ld [wPlayerPos.x_subpixel], a
    ret

;Scrolls the camera left by 1 pixel.
;Writes all registers
ScrollLeft:
    ;wPlayerPos.x -= wCurrMoveSpeed
    ld a, [wCurrMoveSpeed]
	ld b, a
	ld a, [wPlayerPos.x_low]
	sub b
	ld [wPlayerPos.x_low], a
	
	;If metatile position didn't decrease, don't load new tiles
    jr nc, ._no_tiles
		;Otherwise, update the camera position, and schedule tile load
		ld hl, wPlayerPos.x_metatile
		dec [hl]
		ld hl, wBooleans
		set BF_SCHED_LD_LEFT, [hl]
	._no_tiles
	
    ;Get collision - do nothing if no collision
	ld d, JF_LEFT
    call GetPlayerCollision
    ret z

    ;If collision, snap to grid
    xor a ; ld a, 0
    ld [wPlayerPos.x_subpixel], a

    ld hl, wPlayerPos.x_metatile
	inc [hl]

	;And make sure not to load any tiles (would be a CPU hog otherwise)
	ld hl, wBooleans
	res BF_SCHED_LD_LEFT, [hl]

    ret