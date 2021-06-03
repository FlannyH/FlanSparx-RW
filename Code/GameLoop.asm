include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

Section "Title Screen Loop", ROM0
StateStart_GameLoop:
    ;Wait for the current frame to finish and then turn off the display
    call waitVBlank
    di
    ld hl, rLCDC
    res 7, [hl]

    ld a, IEF_VBLANK | IEF_LCDC
    ldh [rIE], a
    ldh [rIF], a

    ld a, 8
    ldh [rLYC], a

    ld hl, rSTAT
    set 6, [hl]

    ;Turn on 2x CPU mode if this is a Gameboy Color
    ldh a, [hGameboyType]
    cp GAMEBOY_COLOR
    jr nz, .noGBC
        ld a, 1
        ldh [rKEY1], a
        stop
    .noGBC

    ;Load the scene
    ld a, bank(map_tutorial)
    ldh [hMapLoaded], a
    ld [set_bank], a

    ;Get map width
    ld a, [MAPMETA]
    ldh [hMapWidth], a

    ;Set camera position
    ld a, 39
    ld [wPlayerPos.x_metatile], a
    ld a, 27
    ld [wPlayerPos.y_metatile], a
    ld a, 2
    ld [wPlayerDirection], a

    ;Load spriteset
    ;CopyTileBlock sprites_crawdad_tiles, $8000, $0000
	Copy sprites_crawdad_DMG_tiles, $8000
	Copy tileset_gui_tiles, $86A0

	;Clear text buffer
	ld hl, $8460
	ld b, ($6A-$46) * 4
	xor a
	.clear_loop
		ld [hl+], a
		ld [hl+], a
		ld [hl+], a
		ld [hl+], a
		dec b
		jr nz, .clear_loop

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
	ld a, $18
    ld [wCurrMoveSpeed], a

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