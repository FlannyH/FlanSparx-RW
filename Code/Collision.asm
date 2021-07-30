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
GetObjPlyColl_old:
	;Handle X
		;Fine
			inc l
			ld a, [wPlayerPos.x_subpixel]
			sub [hl]
		;Add offset
			add $80
			ld b, a
		;Tile
			ld a, [wPlayerPos.x_metatile]
			adc 5 ; offset and carry in one instruction pog
			inc l
			sub [hl]
		;If tile distance is $00, then theres collision, pog, move on
			jr z, .collisionX
		;If >= $02, no collision, return
			cp 2
			ret nc
		;If $01, theres collision if subpixel distance < $80
			ld a, b
			cp 8
			ret nc
	.collisionX
	;Handle Y
		;Fine
			inc l
			ld a, [wPlayerPos.y_subpixel]
			sub [hl]
		;Add offset
			add $80
			ld b, a
		;Tile
			ld a, [wPlayerPos.y_metatile]
			adc 4 ; offset and carry in one instruction pog
			inc l
			sub [hl]
		;If tile distance is $00, then theres collision, pog, move on
			jr z, .collisionY
		;If >= $02, no collision, return
			cp 2
			ret nc
		;If $01, theres collision if subpixel distance < $80
			ld a, b
			cp 8
			ret nc
	.collisionY
	;Since all the other rets are 'ret nc', we could just define 'nc' to mean 'no collision'
		scf
		ret

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
		;If (object_x - player_x) between -8 and 8, collision, otherwise nope
			;o-p+8 between 0 and 16 works too
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
		;If (object_y - player_y) between -8 and 8, collision, otherwise nope
			;o-p+8 between 0 and 16 works too
			sub b
			add 10
			cp 20
	;The result of the last CP instruction is the result of the collision detection - return
		ret