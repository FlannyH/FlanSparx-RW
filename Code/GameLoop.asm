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
    ld16const bCurrMoveSpeed, $0180

    ;Turn the screen back on
    ld a, LCDCF_BG8800 | LCDCF_OBJ16 | LCDCF_ON | LCDCF_BGON; | LCDCF_OBJON
    ld [rLCDC], a

    ret

StateUpdate_GameLoop:
    call SetScroll

    ;TODO - make separate input handler
    call ObjUpdate_Player

    reti

;Scrolls the camera down by 1 pixel.
;Writes all registers
ScrollDown:
    ;Increment Y scroll
    AddInt16 bScrollY, bCurrMoveSpeed

    ;Compare with 16
    cp 16

    ;If it's below 16, don't load any new tiles
    jr c, .doNotLoadNewTiles

    ;Otherwise, remove 16 from the scroll
    sub 16
    ld [bScrollY], a

    ;Update the camera position
    ld hl, bCameraY
    inc [hl]

    ;Load new tiles to the bottom of the screen
    MapHandler_LoadStripX -1, 9
    ret

    .doNotLoadNewTiles
    ld [bScrollY], a
    ret

;Scrolls the camera up by 1 pixel.
;Writes all registers
ScrollUp:
    ;Decrement Y scroll
    SubInt16 bScrollY, bCurrMoveSpeed

    ;If positive, don't load any new tiles
    bit 7, a
    jr z, .doNotLoadNewTiles

    ;Otherwise, add 16 to the scroll
    add 16
    ld [bScrollY], a

    ;Update the camera position
    ld hl, bCameraY
    dec [hl]

    ;Load new tiles to the top of the screen
    MapHandler_LoadStripX -1, 0
    ret

    .doNotLoadNewTiles
    ld [bScrollY], a
    ret

;Scroll the camera right by 1 pixel.
;Writes all registers
ScrollRight:
    ;Increment X scroll
    AddInt16 bScrollX, bCurrMoveSpeed

    ;If below 16, don't load any new tiles
    cp 16
    jr c, .doNotLoadNewTiles

    ;Otherwise, remove 16 from the scroll
    sub 16
    ld [bScrollX], a

    ;Update the camera position
    ld hl, bCameraX
    inc [hl]

    ;Load new tiles to the right of the screen
    MapHandler_LoadStripY 10, -1
    ret

    .doNotLoadNewTiles
    ld [bScrollX], a
    ret

;Scrolls the camera left by 1 pixel.
;Writes all registers
ScrollLeft:
    ;Decrement X scroll
    SubInt16 bScrollX, bCurrMoveSpeed

    ;If positive, don't load any new tiles
    bit 7, a
    jr z, .doNotLoadNewTiles

    ;Otherwise, add 16 to the scroll
    add 16
    ld [bScrollX], a

    ;Update the camera position
    ld hl, bCameraX
    dec [hl]

    ;Load new tiles to the left of the screen
    MapHandler_LoadStripY 0, -1
    ret

    .doNotLoadNewTiles
    ld [bScrollX], a
    ret