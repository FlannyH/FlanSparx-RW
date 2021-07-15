include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "SwarmerStill", ROM0
Object_Start_SwarmerStill:
	jp Object_Start_GemCommon

Object_Update_SwarmerStill:
	jp Object_Update_GemCommon

Object_Draw_SwarmerStill:
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

        ;Mark gem as collected
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