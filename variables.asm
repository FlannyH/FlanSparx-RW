;HRAM Variables
Section "HRAM", HRAM[$FF88]
pCurrentState: ds 1 ; current state index, see InterruptVectors -> States
bCameraX: ds 1
bCameraY: ds 1

;Define variable locations in RAM
    IF !DEF(VARIABLES)
VARIABLES SET 1

;Constants
STATE_None          EQU $00
STATE_TitleScreen   EQU $01
STATE_GameLoop      EQU $02

;System state variables
joypad_current	EQU $C200 ; 8 bit, right, left, up, down, start, select, b, a
joypad_last		EQU $C201 ; 8 bit
joypad_pressed	EQU $C202 ; 8 bit
joypad_released	EQU $C203 ; 8 bit
gameboy_type    EQU $C204 ; 8 bit, $01-GB/SGB, $FF-GBP, $11-GBC

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

;Gameboy types
GAMEBOY_REGULAR EQU $01
GAMEBOY_POCKET  EQU $FF
GAMEBOY_COLOR   EQU $11

;ROM banks
set_bank            EQU $2000

ENDC