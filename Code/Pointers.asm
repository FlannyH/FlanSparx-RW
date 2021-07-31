Section "Start Routine Pointers", ROM0, ALIGN[8]
Object_StartRoutinePointers:
    dw Object_Start_None
    dw Object_Start_Bullet
    dw Object_Start_RedGem
    dw Object_Start_GreenGem
    dw Object_Start_BlueGem
    dw Object_Start_YellowGem
    dw Object_Start_PurpleGem
	dw Object_Start_SwarmerStill
	dw Object_Start_SwarmerMove

Section "Update Routine Pointers", ROM0, ALIGN[8]
Object_UpdateRoutinePointers:
    dw Object_Update_None
    dw Object_Update_Bullet
    dw Object_Update_RedGem
    dw Object_Update_GreenGem
    dw Object_Update_BlueGem
    dw Object_Update_YellowGem
    dw Object_Update_PurpleGem
	dw Object_Update_SwarmerStill
	dw Object_Update_SwarmerMove

Section "Draw Routine Pointers", ROM0, ALIGN[8]
Object_DrawRoutinePointers:
    dw Object_Draw_None
    dw Object_Draw_Bullet
    dw Object_Draw_RedGem
    dw Object_Draw_GreenGem
    dw Object_Draw_BlueGem
    dw Object_Draw_YellowGem
    dw Object_Draw_PurpleGem
	dw Object_Draw_SwarmerStill
	dw Object_Draw_SwarmerMove

Section "Player Collision Routine Pointers", ROM0, ALIGN[8]
Object_PlyCollRoutinePointers:
    dw Object_PlyColl_None
    dw Object_PlyColl_None
    dw Object_PlyColl_RedGem
    dw Object_PlyColl_GreenGem
    dw Object_PlyColl_BlueGem
    dw Object_PlyColl_YellowGem
    dw Object_PlyColl_PurpleGem
	dw Object_PlyColl_SwarmerStill
	dw Object_PlyColl_SwarmerMove