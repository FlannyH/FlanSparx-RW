include "Code/Player.asm"

Section "Title Screen", ROM0
StateStart_GameLoop:
    ;Wait for the current frame to finish and then turn off the display
    call waitVBlank
    LCDoffHL

    ;Load the scene
    ld a, bank(map_tutorial) ; map id 0 is tutorial map
    ld [bMapLoaded], a

    ;Set camera position
    ld a, 20
    ld [bCameraX], a
    ld a, 30
    ld [bCameraY], a

    ;Load spriteset
    CopyTileBlock sprites_crawdad_tiles, $8000, $0000

    ;Load tileset
    CopyTileBlock tileset_crawdad_tiles, $8800, $0800
    CopyTileBlock tileset_crawdad_tiles, $9000, $0000

    ;Load just over one screens worth of tiles
    ld b, 11 ; counter
    ld c, -1 ; y offset
    .loop
        push bc
        MapHandler_LoadStripX -1, c
        pop bc

        inc c
        dec b
        jr nz, .loop

    ;Set variables
    ld16const iCurrMoveSpeed, $0180

    ;Turn the screen back on
    ld a, LCDCF_BG8800 | LCDCF_OBJ16 | LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    ret

StateUpdate_GameLoop:
    call SetScroll
    call ObjUpdate_Player
    call HandleSprites

    reti
