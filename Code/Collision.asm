include "Code/constants.asm"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Collision Detection", ROM0
;Checks for collision at the current player position - 100 cycles
;Input: DE - XY tile offset
GetPlayerCollision:
    ;Go to the map bank
		ldh a, [hMapLoaded]
		ld [set_bank], a

	;Handle X metatile
		ld a, [wPlayerPos.x_metatile]
		add 5
		ld b, a

	;Handle Y metatile
		ld a, [wPlayerPos.y_metatile]
		add 4
		ld c, a

	;Handle direction specific stuff
		bit J_RIGHT, d
		jr nz, .right
		bit J_LEFT, d
		jr nz, .left
		bit J_DOWN, d
		jr nz, .down
		bit J_UP, d
		jr nz, .up

	.right
		inc b ; move one tile to the right
		
	.left
		;Handle top part of tile
		push bc
			;Go 2 pixels down, and update the Y tile
				ld a, [wPlayerPos.y_subpixel]
				add $20
				ld a, c
				adc 0
				ld c, a
			;Check collision
				call GetCollisionAtBC
		pop bc

		;If collision here, exit, we have collision
		ret nz

		;Otherwise, check bottom part of tile
			;Go 13 pixels down, and update the Y tile
				ld a, [wPlayerPos.y_subpixel]
				add $D0
				ld a, c
				adc 0
				ld c, a
			;Check collision
				jp GetCollisionAtBC
	.down
		inc c ; move one tile down
	.up
		;Handle top part of tile
		push bc
			;Go 2 pixels down, and update the Y tile
				ld a, [wPlayerPos.x_subpixel]
				add $20
				ld a, b
				adc 0
				ld b, a
			;Check collision
				call GetCollisionAtBC
		pop bc

		;If collision here, exit, we have collision
		ret nz

		;Otherwise, check bottom part of tile
			;Go 13 pixels down, and update the Y tile
				ld a, [wPlayerPos.x_subpixel]
				add $D0
				ld a, b
				adc 0
				ld b, a
			;Check collision
				jp GetCollisionAtBC


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
    
;Input: BC - XY tile position on the map
GetCollisionAtBC:
    call MapHandler_GetMapDataPointer
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
        rst RunSubroutine

        pop hl


        jr .loop

;Check for object collision at (player.x - obj.x + offset)
;Input: HL - object table entry pointer (start) - 
;Output: nc=no collision, c=collision - Destroys ABC, and the lower nibble of L
GetObjPlyColl:
	;Handle X
		;Get player X in pixel space
			ld a, [wPlayerPos.x_subpixel]
			and $F0
			ld b, a
			ld a, [wPlayerPos.x_metatile]
			and $0F
			or b
			swap a
			add 80; wPlayerPos is the top left of the screen, move it to the right spot
			ld b, a
		;Get object X in pixel space
			inc l
			inc l
			ld a, [hl+]
			and $F0
			ld c, a
			ld a, [hl+]
			and $0F
			or c
			swap a
		;If (object_x - player_x) between -10 and 10, collision, otherwise nope
			;o-p+10 between 0 and 20 works too
			sub b
			add 10
			cp 20
			ret nc ; return if no collision
	;Handle Y
		;Get player Y in pixel space
			ld a, [wPlayerPos.y_subpixel]
			and $F0
			ld b, a
			ld a, [wPlayerPos.y_metatile]
			and $0F
			or b
			swap a
			add 64
			ld b, a
		;Get object Y in pixel space
			inc l
			ld a, [hl+]
			and $F0
			ld c, a
			ld a, [hl+]
			and $0F
			or c
			swap a
		;If (object_y - player_y) between -10 and 10, collision, otherwise nope
			;o-p+10 between 0 and 20 works too
			sub b
			add 10
			cp 20
	;The result of the last CP instruction is the result of the collision detection - return
		ret

;BC = center position A, DE = center position B, HL = combined hitbox size
;Returns carry flag, C = collision, NC = no collision
GetObjObjCollision:
	;Check X coordinate
		;diffX = abs(centerA.x - centerB.x)
			;A = centerA - centerB
				ld a, b
				sub d

			;A = abs(A)
				bit 7, a
				jr z, .positiveX
					cpl
					inc a
				.positiveX
		;if (diffX >= combinedHitbox.x) return No Collision
			cp a, h
			ret nc
	;Check Y coordinate
		;diffY = abs(centerA.y - centerB.y)
			;A = centerA - centerB
				ld a, c
				sub e

			;A = abs(A)
				bit 7, a
				jr z, .positiveY
					cpl
					inc a
				.positiveY
		;if (diffX >= combinedHitbox.x) return No Collision, otherwise return Collision
			cp a, l
			ret