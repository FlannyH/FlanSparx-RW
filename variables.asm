;HRAM Variables
Section "HRAM", HRAM[$FF88]
pCurrentState: ds 1 ; current state index, see InterruptVectors -> States
bMapLoaded: ds 1
bCameraX: ds 1
bCameraY: ds 1
iScrollX: ds 2
iScrollY: ds 2
iCurrMoveSpeed: ds 2
bPlayerDirection: ds 1 ; $00-right, $01-upright, ..., $07 - bottom right
bBooleans: ds 1
bCollisionResult1: ds 1
bCollisionResult2: ds 1

bJoypadCurrent: ds 1 ; right, left, up, down, start, select, b, a
bJoypadLast: ds 1
bJoypadPressed: ds 1
bJoypadReleased: ds 1
bGameboyType: ds 1 ; $01-GB/SGB, $FF-GBP, $11-GBC

Section "Shadow OAM", WRAM0[$C000]
wShadowOAM:
pPlayerSpriteSlot: ds 2*4 ; 2/40 - total 2/40
sprites_bullets: ds 6*4 ; 8/40 - total 8/40
sprites_objects: ds 32*4 ; 32/40 - total 40/40

;Define variable locations in RAM
    IF !DEF(VARIABLES)
VARIABLES SET 1

;Constants
STATE_None          EQU $00
STATE_TitleScreen   EQU $01
STATE_GameLoop      EQU $02

B_HALFTIMER EQU %00000001

;Sprites


;Debug variables
frame_counter	EQU $C400 ; 8 bit, increases with every VBLANK
debug1          EQU $C401
debug2          EQU $C402
debug3          EQU $C403
debug4          EQU $C404
debug5          EQU $C405
debug6          EQU $C406
debug7          EQU $C407
debug8          EQU $C408

;Objects

;Joypad bits
J_RIGHT         EQU 0
J_LEFT          EQU 1
J_UP            EQU 2
J_DOWN          EQU 3
J_A             EQU 4
J_B             EQU 5
J_SELECT        EQU 6
J_START         EQU 7

;Joypad bits
JF_RIGHT         EQU %00000001
JF_LEFT          EQU %00000010
JF_UP            EQU %00000100
JF_DOWN          EQU %00001000
JF_A             EQU %00010000
JF_B             EQU %00100000
JF_SELECT        EQU %01000000
JF_START         EQU %10000000

;Directions
D_RIGHT       EQU 0
D_UPRIGHT     EQU 1
D_UP          EQU 2
D_UPLEFT      EQU 3
D_LEFT        EQU 4
D_DOWNLEFT    EQU 5
D_DOWN        EQU 6
D_DOWNRIGHT   EQU 7

;Speed
SPEED_STRAIGHT EQU $0180
SPEED_DIAGONAL EQU $0130

;Gameboy types
GAMEBOY_REGULAR EQU $01
GAMEBOY_POCKET  EQU $FF
GAMEBOY_COLOR   EQU $11

;ROM banks
set_bank            EQU $2000

ENDC