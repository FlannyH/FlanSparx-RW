Section "Start Routine Pointers", ROM0, ALIGN[8]
Object_StartRoutinePointers:
    dw Object_Start_None
    dw Object_Start_Bullet
    dw Object_Start_RedGem

Section "Update Routine Pointers", ROM0, ALIGN[8]
Object_UpdateRoutinePointers:
    dw Object_Update_None
    dw Object_Update_Bullet
    dw Object_Update_RedGem

Section "Draw Routine Pointers", ROM0, ALIGN[8]
Object_DrawRoutinePointers:
    dw Object_Draw_None
    dw Object_Draw_Bullet
    dw Object_Draw_RedGem

Section "Player Collision Routine Pointers", ROM0, ALIGN[8]
Object_PlyCollRoutinePointers:
    dw Object_PlyColl_None
    dw Object_PlyColl_None
    dw Object_PlyColl_RedGem