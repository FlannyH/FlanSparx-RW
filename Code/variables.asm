include "Code/Types.asm"

if !DEF(VARIABLES)
VARIABLES SET 1

Section "HRAM variables", HRAM
HRAMvariables:
	u8 hCurrentState ; current state index, see InterruptVectors -> States
	u8 hMapLoaded
	u8 hMapWidth
	u8 hJoypadCurrent ; right, left, up, down, start, select, b, a
	u8 hJoypadLast
	u8 hJoypadPressed
	u8 hJoypadReleased
	u8 hGameboyType ; $01-GB/SGB, $FF-GBP, $11-GBC
	u8 hRegStorage1
	u8 hRegStorage2
	u8 hRegStorage3

	u8 hMapLoaderMode
	u8 hMapLoaderLoopCounter
	hMapLoaderLoopDEHL: ds 4

	u16 hSPstorage
	u8 hSCX
	u8 hSCY
HRAMvariablesEnd:

Section "Main variables", WRAM0
WRAMvariables:
	Position12_4 wPlayerPos

	s8 wCurrMoveSpeed
	u8 wPlayerDirection ; $00-right, $01-upright, ..., $07 - bottom right
	u8 wBooleans
	u8 wCollisionResult1
	u8 wCollisionResult2
	u8 wCurrCheckOnScreenObj
	u8 wShootTimer
	u8 wPlayerHealth
	u8 wCurrGemDec1
	u8 wCurrGemDec2
	u8 wMsgBoxAnimTimer
	u8 wMsgBoxAnimState
	u8 wHandlingUpdateMethod ;If the game is lagging, make sure it doesn't call the update routine before the current one is finished

WRAMvariablesEnd:

Section "Shadow OAM", WRAM0, ALIGN[8]
wShadowOAM:
	ds $A0
.end

ds $60 ; the rest of the shadow oam gets cleared too, so dont let rgbds assign any important tables to there

Section "Buffers", WRAM0, ALIGN[8]
wTextBuffer: ds 36
.end

Section "Debug variables", WRAM0, ALIGN[8]
	u16 iErrorCode

Section "Object Arrays 2", WRAM0, ALIGN[8]
Object_IDs: ds $100
.end
Object_Types: ds $100
.end

Section "Object Arrays 3", WRAM0, ALIGN[5]
Object_Flags: ds $20
.end

ENDC