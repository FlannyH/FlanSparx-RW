include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "SwarmerMove", ROM0
Object_Start_SwarmerMove:
	;Get entity ID
		ld d, high(Object_IDs)
		ld e, c
		ld a, [de]

	;Mark it as spawned
        push hl
        call SetCollectableFlag
        pop hl

	jp Object_Start_GemCommon

Object_Update_SwarmerMove:
	call Object_Update_SwarmerStill
	;Move according to direction if player is close enough
		;Get player distance
			;move to Y position
				ld a, l
				and $F0
				add 2
				ld l, a
			;get object x - pixel
				ld a, [hl+]
				and $F0
				ld b, a
				ld a, [hl+]
				and $0F
				or b
				swap a
				ld b, a
			;get player x - pixel
				ld a, [wPlayerPos.x_subpixel]
				and $F0
				ld c, a
				ld a, [wPlayerPos.x_metatile]
				and $0F
				or c
				swap a
				add 80 ; offset to player from camera
		;If the player is within 40 pixels of the enemy
			sub b
			add 56
			cp 112
			jr nc, ._no_move
			;move to X position
				inc l
			;get object y - pixel
				ld a, [hl+]
				and $F0
				ld b, a
				ld a, [hl+]
				and $0F
				or b
				swap a
				ld b, a
			;get player y - pixel
				ld a, [wPlayerPos.y_subpixel]
				and $F0
				ld c, a
				ld a, [wPlayerPos.y_metatile]
				and $0F
				or c
				swap a
				add 64 ; offset to player from camera
		;If the player is within 40 pixels of the enemy
			sub b
			add 56
			cp 112
			jr nc, ._no_move

		;If we get here, move towards the player
			;Get pointer to speed LUT entry
				ld a, [hl]
				add a
				add low(.speed_LUT)
				ld e, a
				ld a, high(.speed_LUT)
				adc 0
				ld d, a
			;Get pointer to X position
				ld a, l
				and $F0
				add 2
				ld l, a
			;Add speed to position
				;X
					ld a, [de] ; read speed
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
				inc de
				inc l
				inc l
				;Y
					ld a, [de] ; read speed
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

		._no_move

	ret

.speed_LUT ; sub_x, sub_y, from right counter clockwise
	db SPEED_SWARMER_STRAIGHT	, 0
	db SPEED_SWARMER_DIAGONAL	, -SPEED_SWARMER_DIAGONAL
	db 0						, -SPEED_SWARMER_STRAIGHT
	db -SPEED_SWARMER_DIAGONAL	, -SPEED_SWARMER_DIAGONAL
	db -SPEED_SWARMER_STRAIGHT	, 0
	db -SPEED_SWARMER_DIAGONAL	, SPEED_SWARMER_DIAGONAL
	db 0						, SPEED_SWARMER_STRAIGHT
	db SPEED_SWARMER_DIAGONAL	, SPEED_SWARMER_DIAGONAL



Object_Draw_SwarmerMove:
    jp Object_Draw_SwarmerStill

Object_PlyColl_SwarmerMove:
    jp Object_PlyColl_SwarmerStill