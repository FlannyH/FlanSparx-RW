Section "Start Routine Pointers", ROM0, ALIGN[8]
Object_StartRoutinePointers:
    dw Object_Start_None
    dw Object_Start_Bullet        ;Bullet
    dw Object_Start_RedGem        ;RedGem
    dw Object_Start_GreenGem      ;GreenGem
    dw Object_Start_BlueGem       ;BlueGem
    dw Object_Start_YellowGem     ;YellowGem
    dw Object_Start_PurpleGem     ;PurpleGem
	dw Object_Start_SwarmerStill  ;SwarmerStill
	dw Object_Start_SwarmerMove   ;SwarmerMove

Section "Update Routine Pointers", ROM0, ALIGN[8]
Object_UpdateRoutinePointers:
    dw Object_Update_None
    dw Object_Update_Bullet        ;Bullet
    dw Object_Update_RedGem        ;RedGem
    dw Object_Update_GreenGem      ;GreenGem
    dw Object_Update_BlueGem       ;BlueGem
    dw Object_Update_YellowGem     ;YellowGem
    dw Object_Update_PurpleGem     ;PurpleGem
	dw Object_Update_SwarmerStill  ;SwarmerStill
	dw Object_Update_SwarmerMove   ;SwarmerMove

Section "Draw Routine Pointers", ROM0, ALIGN[8]
Object_DrawRoutinePointers:
    dw Object_Draw_None
    dw Object_Draw_Bullet        ;Bullet
    dw Object_Draw_RedGem        ;RedGem
    dw Object_Draw_GreenGem      ;GreenGem
    dw Object_Draw_BlueGem       ;BlueGem
    dw Object_Draw_YellowGem     ;YellowGem
    dw Object_Draw_PurpleGem     ;PurpleGem
	dw Object_Draw_SwarmerStill  ;SwarmerStill
	dw Object_Draw_SwarmerMove   ;SwarmerMove

Section "Player Collision Routine Pointers", ROM0, ALIGN[8]
Object_PlyCollRoutinePointers:
    dw Object_PlyColl_None
    dw Object_PlyColl_None          ;Bullet
    dw Object_PlyColl_RedGem        ;RedGem
    dw Object_PlyColl_GreenGem      ;GreenGem
    dw Object_PlyColl_BlueGem       ;BlueGem
    dw Object_PlyColl_YellowGem     ;YellowGem
    dw Object_PlyColl_PurpleGem     ;PurpleGem
	dw Object_PlyColl_SwarmerStill  ;SwarmerStill
	dw Object_PlyColl_SwarmerMove   ;SwarmerMove

Section "Bullet Collision Routine Pointers", ROM0, ALIGN[8]
Object_BulletCollRoutinePointers: ;input: C = entity slot, DE = bullet coordinates on screen, output: A = destroy bullet? $01 true, $00 false
    dw Object_BulletColl_None
    dw Object_BulletColl_None ;Bullet
    dw Object_BulletColl_None ;RedGem
    dw Object_BulletColl_None ;GreenGem
    dw Object_BulletColl_None ;BlueGem
    dw Object_BulletColl_None ;YellowGem
    dw Object_BulletColl_None ;PurpleGem
	dw Object_BulletColl_SwarmerStill ;SwarmerStill
	dw Object_BulletColl_SwarmerStill ;SwarmerMove