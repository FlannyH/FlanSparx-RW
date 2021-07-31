
;Objects are saved in RAM
;The array is separated so every byte is a separate array
;This way, if you use HL as a pointer, you can change H to
;determine what you're loading, and then use L to determine
;which object slot you're loading from

    IF !DEF(MAP_VARIABLES)
DEF MAP_VARIABLES EQU 1

DEF MAPDATA EQU $4000
DEF OBJDATA EQU $7F00
DEF MAPMETA EQU $7E00

ENDC

    IF !DEF(OBJECT_VARIABLES)
DEF OBJECT_VARIABLES EQU 1

DEF Object_TableStart EQU $D000

;16 bytes per entry
DEF Object_State            EQU $00
DEF Object_PositionXfine    EQU $01
DEF Object_PositionX        EQU $02
DEF Object_PositionYfine    EQU $03
DEF Object_PositionY        EQU $04  
DEF Object_Rotation         EQU $05

DEF Object_Bullet_VelX      EQU $06    
DEF Object_Bullet_VelY      EQU $07      

DEF Object_ID               EQU $0F
ENDC

;HRAM Variables
;Define variable locations in RAM
    IF !DEF(VARIABLES)
DEF VARIABLES EQU 1

;Constants
DEF STATE_None          EQU $00
DEF STATE_TitleScreen   EQU $01
DEF STATE_GameLoop      EQU $02
DEF STATE_DebugWarning  EQU $03
DEF STATE_MessageBox    EQU $04


DEF B_HALFTIMER       EQU %00000001
DEF B_SCHED_LD_RIGHT  EQU %00000010
DEF B_SCHED_LD_UP     EQU %00000100
DEF B_SCHED_LD_LEFT   EQU %00001000
DEF B_SCHED_LD_DOWN   EQU %00010000
DEF B_LOADMAP_STAGE   EQU %00100000

DEF BF_HALFTIMER      EQU 0
DEF BF_SCHED_LD_RIGHT EQU 1
DEF BF_SCHED_LD_UP    EQU 2
DEF BF_SCHED_LD_LEFT  EQU 3
DEF BF_SCHED_LD_DOWN  EQU 4
DEF BF_LOADMAP_STAGE  EQU 5


;Sprites


;Debug variables
DEF frame_counter	EQU $C400 ; 8 bit, increases with every VBLANK
DEF debug1          EQU $C401
DEF debug2          EQU $C402
DEF debug3          EQU $C403
DEF debug4          EQU $C404
DEF debug5          EQU $C405
DEF debug6          EQU $C406
DEF debug7          EQU $C407
DEF debug8          EQU $C408

;Objects

;Joypad bits
DEF J_RIGHT         EQU 0
DEF J_LEFT          EQU 1
DEF J_UP            EQU 2
DEF J_DOWN          EQU 3
DEF J_A             EQU 4
DEF J_B             EQU 5
DEF J_SELECT        EQU 6
DEF J_START         EQU 7

;Joypad bits
DEF JF_RIGHT         EQU %00000001
DEF JF_LEFT          EQU %00000010
DEF JF_UP            EQU %00000100
DEF JF_DOWN          EQU %00001000
DEF JF_A             EQU %00010000
DEF JF_B             EQU %00100000
DEF JF_SELECT        EQU %01000000
DEF JF_START         EQU %10000000

;Directions
DEF D_RIGHT       EQU 0
DEF D_UPRIGHT     EQU 1
DEF D_UP          EQU 2
DEF D_UPLEFT      EQU 3
DEF D_LEFT        EQU 4
DEF D_DOWNLEFT    EQU 5
DEF D_DOWN        EQU 6
DEF D_DOWNRIGHT   EQU 7

;Speed
DEF SPEED_PLAYER_REGULAR_STRAIGHT EQU $14
DEF SPEED_PLAYER_REGULAR_DIAGONAL EQU $10
DEF SPEED_PLAYER_CHARGE_STRAIGHT EQU $20
DEF SPEED_PLAYER_CHARGE_DIAGONAL EQU $19
DEF SPEED_BULLET_STRAIGHT EQU $60
DEF SPEED_BULLET_DIAGONAL EQU $40
DEF SPEED_SWARMER_STRAIGHT EQU $08
DEF SPEED_SWARMER_DIAGONAL EQU $06

;Fire rate
DEF BULLET_FIRERATE_NORMAL EQU 10

;Gameboy types
DEF GAMEBOY_REGULAR EQU $01
DEF GAMEBOY_POCKET  EQU $FF
DEF GAMEBOY_COLOR   EQU $11

;ROM banks
DEF set_bank            EQU $2000

;Object types
DEF OBJTYPE_REMOVED EQU $FF
DEF OBJTYPE_NONE    EQU $00
DEF OBJTYPE_BULLET  EQU $01
DEF OBJTYPE_REDGEM  EQU $02

;Object states
DEF OBJSTATE_OFFSCREEN EQU 7

;Message box state
DEF MSGBOX_INSTANT EQU 1

ENDC