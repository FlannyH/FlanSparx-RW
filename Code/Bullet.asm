include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Bullet", ROM0
Object_Start_Bullet:
    ;HL = Object_TableStart + (slot_id * 16)
        ;high byte = high(Object_TableStart) + slot_id >> 4
        ld a, c ; retrieve current object slot id
        swap a
        and $0F
        add high(Object_TableStart)
        ld h, a

        ;low byte = slot_id << 4
        ld a, c ; retrieve current object slot id
        swap a
        and $F0
        ld l, a

    ;Reset state variable
        xor a ; ld a, 0
        ld [hl+], a

    ;Copy the player's position to this object
		inc l
        ld a, [wPlayerPos.x_low]
        add $40
        ld [hl+], a
        ld a, [wPlayerPos.x_high]
        adc 5
        ld [hl+], a

		inc l
        ld a, [wPlayerPos.y_low]
        add $40
        ld [hl+], a
        ld a, [wPlayerPos.y_high]
        adc 4
        ld [hl+], a


    ;Copy the player's rotation to this object
        ld a, [wPlayerDirection]
        ld [hl-], a
		dec l
		dec l ; we're now at velocity_y

    ;Convert rotation into speed
        or a
        jr z, .right
        dec a
        jr z, .upright
        dec a
        jr z, .up
        dec a
        jr z, .upleft
        dec a
        jr z, .left
        dec a 
        jr z, .downleft
        dec a
        jr z, .down
        dec a
        jr z, .downright

    ;If we get here, rotation is invalid, return
        ret

    .right
		xor a ; ld a, 0
		ld [hl-], a
		dec l
		dec l
        ld a, SPEED_BULLET_STRAIGHT
        ld [hl+], a
        jr .afterSettingVelocity

    .upright
        ld a, -SPEED_BULLET_DIAGONAL
        ld [hl-], a
		dec l
		dec l
        ld a, SPEED_BULLET_DIAGONAL
        ld [hl], a
        jr .afterSettingVelocity

    .up
		ld a, -SPEED_BULLET_STRAIGHT
		ld [hl-], a
		dec l
		dec l
        xor a ; ld a, 0
        ld [hl], a
        jr .afterSettingVelocity

    .upleft
        ld a, -SPEED_BULLET_DIAGONAL
        ld [hl-], a
		dec l
		dec l
        ld a, -SPEED_BULLET_DIAGONAL
        ld [hl], a
        jr .afterSettingVelocity

    .left
		xor a ; ld a, 0
		ld [hl-], a
		dec l
		dec l
        ld a, -SPEED_BULLET_STRAIGHT
        ld [hl], a
        jr .afterSettingVelocity

    .downleft
        ld a, SPEED_BULLET_DIAGONAL
        ld [hl-], a
		dec l
		dec l
        ld a, -SPEED_BULLET_DIAGONAL
        ld [hl], a
        jr .afterSettingVelocity

    .down
		ld a, SPEED_BULLET_STRAIGHT
		ld [hl-], a
		dec l
		dec l
        xor a ; ld a, 0
        ld [hl+], a
        jr .afterSettingVelocity

    .downright
        ld a, SPEED_BULLET_DIAGONAL
        ld [hl-], a
		dec l
		dec l
        ld a, SPEED_BULLET_DIAGONAL
        ld [hl], a
        jr .afterSettingVelocity

    .afterSettingVelocity
        ret

Object_Update_Bullet:
	;Get pointer to object data
		swap c
		ld a, c
		and $0F
		add high(Object_TableStart)
		ld h, a
		ld a, c
		and $F0
		ld l, a

	;Handle state
		bit OBJSTATE_OFFSCREEN, [hl]
		jr nz, .destroyBullet
		inc l

	;Add velocity X to position
		;load velocity
		ld a, [hl+]
		bit 7, a
		jr z, ._positive_x
		._negative_x
			add [hl]
			ld [hl+], a
			;If carry, don't dec
			jr c, ._end_x
				dec [hl]
			jr ._end_x
		._positive_x
			add [hl]
			ld [hl+], a
			;If no carry, don't dec
			jr nc, ._end_x
				inc [hl]
		._end_x
	ld b, [hl] ; load current collision tile X coordinates

	;Add velocity Y to position
		;load velocity
		inc l
		ld a, [hl+]
		bit 7, a
		jr z, ._positive_y
		._negative_y
			add [hl]
			ld [hl+], a
			;If carry, don't dec
			jr c, ._end_y
				dec [hl]
			jr ._end_y
		._positive_y
			add [hl]
			ld [hl+], a
			;If no carry, don't dec
			jr nc, ._end_y
				inc [hl]
		._end_y
		ld c, [hl] ; load current collision tile Y coordinate

	;Get collision tile coordinates (B - pos x, C - pos y)
        push hl
        call GetCollisionAtBC
        pop hl
        jr z, .endOfSubroutine

        .destroyBullet
        ;If that tile is solid, destroy the bullet
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

        ;Destroy the object
        jp Object_DestroyCurrent

    .endOfSubroutine
        ret

	ret



;Input: BC - XY position in pixels, DE - shadow OAM, HL - sprite order
Object_DrawSingle:
    ;Write Y
    ld a, c
    ld [de], a
    inc e
    ;Write X
    ld a, b
    ld [de], a
    inc e
    ;Write tile id
    ld a, [hl+]
    ld [de], a
    inc e
	;Write attributes
    ld a, [hl+]
    ld [de], a
    inc e

    ret

;Input: DE - shadow oam start entry, B - how many sprite slots left, C - current object slot
Object_Draw_Bullet:
    push bc
    call PrepareSpriteDraw
    
    ;Prepare pointer to sprite order entry
    ld hl, SprBullet
    call Object_DrawSingle
    pop bc

    dec b

    ret