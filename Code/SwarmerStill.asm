include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "SwarmerStill", ROM0
Object_Start_SwarmerStill:
	;Get entity ID
		ld d, high(Object_IDs)
		ld e, c
		ld a, [de]

	;Mark it as spawned
        push hl
        call SetCollectableFlag
        pop hl
		
	jp Object_Start_GemCommon

Object_Update_SwarmerStill_old:
	;jp Object_Update_GemCommon
	;Turn towards player
		;Get pointer to entity
			ld a, c
			swap a
			and $F0
			ld l, a
			ld a, c
			swap a
			and $0F
			or high(Object_TableStart)
			ld h, a
		;Find tile positions
		push bc
		push de
			;DE = swarmer XY
				inc l
				inc l
				inc l
				ld d, [hl]
				inc l
				inc l
				inc l
				ld e, [hl]
				inc l
			;Direction checks
				ld a, [wPlayerPos.x_metatile]
				add 5
				cp d
				jr z, .up_down ;Up/down
				inc a
				cp d
				jr z, .up_down ;Up/down
				jr c, .left
				jr .right
				
	.end
		pop de
		pop bc

		;Handle state
			ld a, l
			and $F0
			ld l, a
			bit OBJSTATE_OFFSCREEN, [hl]
			jr nz, .unload
			inc l

	ret

	;If dx = 0, check if up or down
	.up_down
		ld a, [wPlayerPos.y_metatile]
		add 4
		cp e
			ld [hl], D_UP
		jr c, .end
			ld [hl], D_DOWN
		jr .end

	.right
		ld a, [wPlayerPos.y_metatile]
		add 4
		;If above (-y)
		cp e
		jr z, .s_right
		inc a
		cp e
		jr z, .s_right
		ld a, [wPlayerPos.y_metatile]
		add 4
		cp e
			ld [hl], D_UPRIGHT
		jr c, .end
			ld [hl], D_DOWNRIGHT
		jr .end
	.s_right
		ld [hl], D_RIGHT
		jr .end

	.left
		ld a, [wPlayerPos.y_metatile]
		add 4
		;If above (-y)
		cp e
		jr z, .s_left
		inc a
		cp e
		jr z, .s_left
		ld a, [wPlayerPos.y_metatile]
		add 4
		cp e
			ld [hl], D_UPLEFT
		jr c, .end
			ld [hl], D_DOWNLEFT
		jr .end
	.s_left
		ld [hl], D_LEFT
		jr .end

    .unload
        ;low nibble
        ld a, l
        and $F0
        swap a
        ld b, a

        ;high nibble
        ld a, h
        and $0F
        swap a
        or b
        jp Object_DestroyCurrent

Object_Draw_SwarmerStill:
    push hl
    push bc

	;Get direction from object table and store it in D
		ld a, c
		swap a
		and $F0
		add 7
		ld l, a
		ld a, c
		swap a
		and $0F
		add high(Object_TableStart)
		ld h, a
	push de
		ld d, [hl]	

    call PrepareSpriteDraw
	jr nz, .skip

    ;Prepare pointer to sprite order entry
		ld hl, SprCrawdad_0
		ld a, d
		add a
		add a
		add l
		ld l, a
	pop de

	;Draw sprite
		call Object_DrawSingle
		ld a, b
		add 8
		ld b, a
		call Object_DrawSingle
    
    pop bc
    pop hl
    dec b
    ret
.skip
	pop de
	pop bc
	pop hl
	ret

Object_Update_SwarmerStill:
	;Turn towards player
		;Get pointer to entity
			ld a, c
			swap a
			and $F0
			ld l, a
			ld a, c
			swap a
			and $0F
			or high(Object_TableStart)
			ld h, a
		;If off screen, exit
			bit OBJSTATE_OFFSCREEN, [hl]
			ret nz

		;Find tile positions
		push bc
		push de
			;D = swarmer X
				inc l
				inc l
				ld a, [hl+]
				and $F0
				ld d, a
				ld a, [hl+]
				and $0F
				or d
				swap a
				ld d, a
			;E = swarmer Y
				inc l
				ld a, [hl+]
				and $F0
				ld e, a
				ld a, [hl+]
				and $0F
				or e
				swap a
				ld e, a
			;Direction checks
				;Get player X
					ld a, [wPlayerPos.x_subpixel]
					and $F0
					ld b, a
					ld a, [wPlayerPos.x_metatile]
					and $0F
					or b
					swap a
					add 80 ; camera to player offset
				;Compare to swarmer X
					;Check if center first (if 0 < p-o+8 < 16)
						sub d
						add 8
						cp 16
						jr c, .up_down
					;Else, if left (p-o+8 < 0)
						bit 7, a
						jr nz, .check_left
					;Otherwise, right
						jr .check_right
				
	.up_down
		;Get player Y
			ld a, [wPlayerPos.y_subpixel]
			and $F0
			ld b, a
			ld a, [wPlayerPos.y_metatile]
			and $0F
			or b
			swap a
			add 64 ; camera to player offset
		;Compare to swarmer Y
			;If up (p-o+8 < 0), direction = up, otherwise, direction = down
				sub e
				add 8
				bit 7, a
				jr nz, .up
					ld [hl], D_DOWN
					jr .end
				.up
					ld [hl], D_UP
					jr .end
	.check_left
		;Get player Y
			ld a, [wPlayerPos.y_subpixel]
			and $F0
			ld b, a
			ld a, [wPlayerPos.y_metatile]
			and $0F
			or b
			swap a
			add 64 ; camera to player offset
		;Compare to swarmer Y
			;Check if center first (if 0 < p-o+8 < 16)
				sub e
				add 8
				cp 16
				jr c, .left
			;Else, if up (p-o+8 < 0)
				bit 7, a
				jr nz, .up_left
			;Otherwise, down
				jr .down_left
		jr .end

	.check_right
		;Get player Y
			ld a, [wPlayerPos.y_subpixel]
			and $F0
			ld b, a
			ld a, [wPlayerPos.y_metatile]
			and $0F
			or b
			swap a
			add 64 ; camera to player offset
		;Compare to swarmer Y
			;Check if center first (if 0 < p-o+8 < 16)
				sub e
				add 8
				cp 16
				jr c, .right
			;Else, if up (p-o+8 < 0)
				bit 7, a
				jr nz, .up_right
			;Otherwise, down
				jr .down_right
		jr .end
	.right
		ld [hl], D_RIGHT
		jr .end
	.up_right
		ld [hl], D_UPRIGHT
		jr .end
	.down_right
		ld [hl], D_DOWNRIGHT
		jr .end
	.left
		ld [hl], D_LEFT
		jr .end
	.up_left
		ld [hl], D_UPLEFT
		jr .end
	.down_left
		ld [hl], D_DOWNLEFT
		jr .end
	.end
		pop de
		pop bc
		ret

Object_PlyColl_SwarmerStill:
    ;Get pointer to table entry
        swap b
        ld a, b
        and $F0
        ld l, a

        ld a, b
        and $0F
        or high(Object_TableStart)
        ld h, a

    call GetObjPlyColl
        
    ;If collision
    jr nc, .noCollision
		;Decrease player health
			ld a, [wPlayerHealth]
			dec a
			ld [wPlayerHealth], a

        ;Get object ID
			ld a, h
			swap a
			and $F0
			ld b, a
			ld a, l
			swap a
			and $0F
			or b

        ;Mark object as destroyed
        	ld c, a

        ;Get object ID
			ld h, high(Object_IDs)
			ld l, a
			ld a, [hl]
		
			push hl
			call SetCollectableFlag
			pop hl
			ld a, c

        ;Destroy object
        	jp Object_DestroyCurrent
    .noCollision

    ret
	
Object_BulletColl_SwarmerStill:
    ;Get pointer to table entry
        swap c
        ld a, c
        and $F0
        ld l, a

        ld a, c
        and $0F
        or high(Object_TableStart)
        ld h, a
        
	;We have pixel position for bullet in DE
	;We also have the object pointer in HL
	;Let's get the object position in pixel space now -> BC
		;Move to X position
			inc l
			inc l
		;Read X position and store in B
			ld a, [hl+]
			and $F0
			ld b, a
			ld a, [hl+]
			and $0F
			or b
			swap a
			ld b, a
		;Move to Y position
			inc l
		;Read Y position and store in B
			ld a, [hl+]
			and $F0
			ld c, a
			ld a, [hl+]
			and $0F
			or c
			swap a
			ld c, a
	
	;Then, we define our object size (half), and add the bullet size to it
	push hl
	ld hl, $0808

	push bc
	push de
	call GetObjObjCollision
	pop de
	pop bc
	pop hl

    ;If collision
    jr nc, .noCollision
        ;Get object ID
			ld a, h
			swap a
			and $F0
			ld b, a
			ld a, l
			swap a
			and $0F
			or b

        ;Mark object as destroyed
        	ld c, a

        ;Get object ID
			ld h, high(Object_IDs)
			ld l, a
			ld a, [hl]
		
			push hl
			call SetCollectableFlag
			pop hl
			ld a, c

        ;Destroy object
        	call Object_DestroyCurrent
			scf
    .noCollision

    ret