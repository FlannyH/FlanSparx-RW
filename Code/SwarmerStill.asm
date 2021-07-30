include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "SwarmerStill", ROM0
Object_Start_SwarmerStill:
	jp Object_Start_GemCommon

Object_Update_SwarmerStill:
	jp Object_Update_GemCommon
	;Turn towards player
		;Get pointer to entity
			push hl
			ld a, c
			swap a
			and $F0
			ld l, a
			ld a, c
			swap a
			and $0F
			or high(Object_TableStart)
			ld h, a
			pop hl
		;Find tile positions
		push bc
		push de
			;DE = swarmer XY
				inc l
				inc l
				ld d, [hl]
				inc l
				inc l
				inc l
				ld e, [hl]
			;If X is the same, it's up or down
				ld a, [wPlayerPos.x_metatile]
				cp d
				jr z, .up_down
				
	.end
		pop de
		pop bc

	ret

	;If dx = 0
	.up_down
		;Default to up, if not up, add to direction value
		jr .end

Object_Draw_SwarmerStill:
    push hl
    push bc
    call PrepareSpriteDraw

    ;Prepare pointer to sprite order entry
    ld hl, SprCrawdad_0
    call Object_DrawSingle
    ld a, b
    add 8
    ld b, a
    call Object_DrawSingle
    
    pop bc
    pop hl
    
    dec b

    ret

Object_PlyColl_SwarmerStill:
    ld a, 1
    ldh [$FFFE], a
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