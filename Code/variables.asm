if !DEF(VARIABLES)
VARIABLES SET 1

Section "HRAM variables", HRAM
hCurrentState: ds 1 ; current state index, see InterruptVectors -> States
hMapLoaded: ds 1
hMapWidth: ds 1
hJoypadCurrent: ds 1 ; right, left, up, down, start, select, b, a
hJoypadLast: ds 1
hJoypadPressed: ds 1
hJoypadReleased: ds 1
hGameboyType: ds 1 ; $01-GB/SGB, $FF-GBP, $11-GBC
hRegStorage1: ds 1
hRegStorage2: ds 1
hRegStorage3: ds 1

hMapLoaderMode: ds 1
hMapLoaderLoopCounter: ds 1
hMapLoaderLoopDEHL: ds 4

bDebugValue: ds 2
hSPstorage: ds 2

Section "Main variables", WRAM0
WRAMvariables:
wCameraX: ds 1
wCameraY: ds 1
wScrollX: ds 2
wScrollY: ds 2
wCurrMoveSpeed: ds 2
wPlayerDirection: ds 1 ; $00-right, $01-upright, ..., $07 - bottom right
wBooleans: ds 1
wCollisionResult1: ds 1
wCollisionResult2: ds 1
wCurrCheckOnScreenObj: ds 1
wShootTimer: ds 1
wPlayerHealth: ds 1
wCurrGemDec1: ds 1
wCurrGemDec2: ds 1
wMsgBoxAnimTimer: ds 1
wMsgBoxAnimState: ds 1
wHandlingUpdateMethod: ds 1 ;If the game is lagging, make sure it doesn't call the update routine before the current one is finished

WRAMvariablesEnd:

Section "Shadow OAM", WRAM0, ALIGN[8]
wShadowOAM:
pPlayerSpriteSlot: ds 2*4 ; 2/40 - total 2/40
sprites_bullets: ds 6*4 ; 8/40 - total 8/40
sprites_objects: ds 32*4 ; 32/40 - total 40/40
wShadowOAMend:
ds $60 ; the rest of the shadow oam gets cleared too, so dont let rgbds assign any important tables to there

Section "Buffers", WRAM0, ALIGN[8]
TextBuffer: ds 36
TextBufferEnd:

Section "Debug variables", WRAM0, ALIGN[8]
iErrorCode: ds 2

Section "Object Arrays 2", WRAM0, ALIGN[8]
Object_IDs: ds $100
Object_IDsEnd: 
Object_Types: ds $100
Object_TypesEnd: 

Section "Object Arrays 3", WRAM0, ALIGN[5]
Object_Flags: ds $20
Object_FlagsEnd:

ENDC