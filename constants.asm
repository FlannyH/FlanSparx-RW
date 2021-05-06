
;Objects are saved in RAM
;The array is separated so every byte is a separate array
;This way, if you use HL as a pointer, you can change H to
;determine what you're loading, and then use L to determine
;which object slot you're loading from

    IF !DEF(MAP_VARIABLES)
MAP_VARIABLES SET 1

MAPDATA equ $4000
OBJDATA equ $7F00
MAPMETA equ $7E00

ENDC

    IF !DEF(OBJECT_VARIABLES)
OBJECT_VARIABLES SET 1

Object_TableStart equ $D000

;16 bytes per entry
Object_State            equ $00
Object_PositionXfine    equ $01
Object_PositionX        equ $02
Object_PositionYfine    equ $03
Object_PositionY        equ $04  
Object_Rotation         equ $05

Object_Bullet_VelX      equ $06    
Object_Bullet_VelY      equ $07      

Object_ID               equ $0F
ENDC

;HRAM Variables
;Define variable locations in RAM
    IF !DEF(VARIABLES)
VARIABLES SET 1

;Constants
STATE_None          EQU $00
STATE_TitleScreen   EQU $01
STATE_GameLoop      EQU $02
STATE_DebugWarning  EQU $03
STATE_MessageBox    EQU $04


B_HALFTIMER       EQU %00000001
B_SCHED_LD_RIGHT  EQU %00000010
B_SCHED_LD_UP     EQU %00000100
B_SCHED_LD_LEFT   EQU %00001000
B_SCHED_LD_DOWN   EQU %00010000
B_LOADMAP_STAGE   EQU %00100000

BF_HALFTIMER      EQU 0
BF_SCHED_LD_RIGHT EQU 1
BF_SCHED_LD_UP    EQU 2
BF_SCHED_LD_LEFT  EQU 3
BF_SCHED_LD_DOWN  EQU 4
BF_LOADMAP_STAGE  EQU 5


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
SPEED_PLAYER_REGULAR_STRAIGHT EQU $0143
SPEED_PLAYER_REGULAR_DIAGONAL EQU $0100
SPEED_PLAYER_CHARGE_STRAIGHT EQU $0200
SPEED_PLAYER_CHARGE_DIAGONAL EQU $0196
SPEED_BULLET_STRAIGHT EQU $06
SPEED_BULLET_DIAGONAL EQU $04

;Fire rate
BULLET_FIRERATE_NORMAL EQU 10

;Gameboy types
GAMEBOY_REGULAR EQU $01
GAMEBOY_POCKET  EQU $FF
GAMEBOY_COLOR   EQU $11

;ROM banks
set_bank            EQU $2000

;Object types
OBJTYPE_REMOVED EQU $FF
OBJTYPE_NONE    EQU $00
OBJTYPE_BULLET  EQU $01
OBJTYPE_REDGEM  EQU $02

;Object states
OBJSTATE_OFFSCREEN EQU 7

;Message box state
MSGBOX_INSTANT EQU 1

ENDC