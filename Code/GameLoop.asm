include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Title Screen Loop", ROM0
StateStart_GameLoop:
    ;Wait for the current frame to finish and then turn off the display
    call waitVBlank
    di
    LCDoffHL

    ld a, IEF_VBLANK | IEF_LCDC
    ldh [rIE], a
    ldh [rIF], a

    ld a, 8
    ldh [rLYC], a

    ld hl, rSTAT
    set 6, [hl]

    ;Turn on 2x CPU mode if this is a Gameboy Color
    ldh a, [bGameboyType]
    cp GAMEBOY_COLOR
    jr nz, .noGBC
        ld a, 1
        ldh [rKEY1], a
        stop
    .noGBC

    ;Load the scene
    ld a, bank(map_tutorial)
    ldh [bMapLoaded], a
    ld [set_bank], a

    ;Get map width
    ld a, [MAPMETA]
    ldh [bMapWidth], a

    ;Set camera position
    ld a, 39
    ldh [bCameraX], a
    ld a, 27
    ldh [bCameraY], a
    ld a, 2
    ldh [bPlayerDirection], a

    ;Load spriteset
    CopyTileBlock sprites_crawdad_tiles, $8000, $0000

    ;Load tileset
    CopyTileBlock tileset_crawdad_tiles, $8800, $0800
    CopyTileBlock tileset_crawdad_tiles, $9000, $0000

    ;Clear Window Layer
    call ClearWindowLayer
    call InitWindowLayer

    ;Initialize OAM
    call hOAMDMA

    ;Load just over one screens worth of tiles
    ld b, 11 ; counter
    ld c, -1 ; y offset
    .loop
        push bc
        ld b, -1
        call m_MapHandler_LoadStripX
        pop bc

        inc c
        dec b
        jr nz, .loop

    ;Set variables
    ld16const iCurrMoveSpeed, $0180

    ;Turn the screen back on
    ld a, LCDCF_BG8800 | LCDCF_OBJ16 | LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_WIN9C00 | LCDCF_BG9800 | LCDCF_WINON
    ldh [rLCDC], a

    ret

StateUpdate_GameLoop:
    call UpdateHUD
    call HandleSprites
    call SetScroll
    call ObjUpdate_Player
    call Object_Update
    call FillShadowOAM
    ld c, 8
.checkLoop
    call Object_CheckOnScreen
    dec c
    jr nz, .checkLoop
    call HandleOneTileStrip
    

    ret