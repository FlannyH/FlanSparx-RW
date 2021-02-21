include "hardware.inc"
include "variables.asm"
include "Graphics/Graphics.inc"
include "Graphics/SpriteOrders.inc"
include "Screens/Screens.inc"
include "Maps/Maps.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"
include "Code/Controls.asm"
include "Code/MapHandler.asm"
include "Code/TitleScreen.asm"
include "Code/GameLoop.asm"
include "Code/InterruptVectors.asm"
include "Code/SpriteHandler.asm"
include "Code/Bullet.asm"
include "Code/Text.asm"
include "Code/Objects.asm"
include "Code/HUD.asm"
include "Code/MessageBox.asm"

Section "Jumpstart Code", ROM0[$100]
Jumpstart:
    di
    jp Start

REPT $150 - $104
    db 0
ENDR

Section "Init", ROM0
Start:
    ;Temporarily store the Game Boy type
    ld [$DFFF], a

    ;Move stack pointer
    ld sp, $D000

    ;Clear RAM
    ClearRAM

    ;Get the Game Boy type back
    ld a, [$DFFF]
    ld [bGameboyType], a

    ;Setup interrupts
    ld a, IEF_VBLANK
    ld [rIE], a
    ld [rIF], a

    ;Prepare sprite routine
    call CopyDMARoutine

    ;Go to title screen
    ;ChangeState TitleScreen
    ChangeState DebugWarning

    ei

    .halt
        halt
        jr .halt