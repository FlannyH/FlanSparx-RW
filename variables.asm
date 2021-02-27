
Section "HRAM", HRAM
pCurrentState: ds 1 ; current state index, see InterruptVectors -> States
bMapLoaded: ds 1
bMapWidth: ds 1
bCameraX: ds 1
bCameraY: ds 1
iScrollX: ds 2
iScrollY: ds 2
iCurrMoveSpeed: ds 2
bPlayerDirection: ds 1 ; $00-right, $01-upright, ..., $07 - bottom right
bBooleans: ds 1
bCollisionResult1: ds 1
bCollisionResult2: ds 1
bCurrCheckOnScreenObj: ds 1
bShootTimer: ds 1
bPlayerHealth: ds 1
bCurrGemDec1: ds 1
bCurrGemDec2: ds 1
bMsgBoxAnimTimer: ds 1
bMsgBoxAnimState: ds 1
bHandlingUpdateMethod: ds 1 ;If the game is lagging, make sure it doesn't call the update routine before the current one is finished

bJoypadCurrent: ds 1 ; right, left, up, down, start, select, b, a
bJoypadLast: ds 1
bJoypadPressed: ds 1
bJoypadReleased: ds 1
bGameboyType: ds 1 ; $01-GB/SGB, $FF-GBP, $11-GBC

bRegStorage1: ds 1
bRegStorage2: ds 1

Section "Shadow OAM", WRAM0, ALIGN[8]
wShadowOAM:
pPlayerSpriteSlot: ds 2*4 ; 2/40 - total 2/40
sprites_bullets: ds 6*4 ; 8/40 - total 8/40
sprites_objects: ds 32*4 ; 32/40 - total 40/40

Section "Buffers", WRAM0, ALIGN[8]
TextBuffer: ds 36

Section "Debug variables", WRAM0, ALIGN[8]
iErrorCode: ds 2

Section "Object Arrays 2", WRAM0, ALIGN[8]
Object_IDs: ds $100
Object_Types: ds $100