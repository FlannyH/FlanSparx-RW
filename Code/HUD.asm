Section "error handler", ROM0
ErrorHandler:
    pop de
    push de
    ;Prepare Message
        ld hl, TextBuffer
        ld a, "e"
        ld [hl+], a
        ld a, "r"
        ld [hl+], a
        ld a, "r"
        ld [hl+], a
        ld a, " "
        ld [hl+], a
        ld a, "$"
        ld [hl+], a

        ;High D
            ld a, d
            swap a
            and $0F
            add $17
            ld [hl+], a

        ;Low D
            ld a, d
            and $0F
            add $17
            ld [hl+], a

        ;High E
            ld a, e
            swap a
            and $0F
            add $17
            ld [hl+], a

        ;Low E
            ld a, e
            and $0F
            add $17
            ld [hl+], a

    ld a, high(TextBuffer)
    ld [iErrorCode+0], a
    ld a, low(TextBuffer)
    ld [iErrorCode+1], a

    ChangeState MessageBox
    reti

Section "hard crash", ROM0[$38]
Error2:
    jp Start ; restart the game

Section "LYC Interrupt", ROM0[$48]
    jp LYChandler

Section "LYC handler", ROM0
LYChandler:
    push af
    push bc
    ld a, [rLYC]
    ;HUD
        cp 8
        jr z, .line8disableWindow
        cp 144
        jr z, .line144enableWindow

    ;Message box
        ld c, a
        ld a, [bMsgBoxAnimTimer]
        add 104
        ld b, a

        ld a, c
        cp b ; if message box
        jr z, .lineXshowMessageBox

    ;crash the game if this all fails
        call ErrorHandler

    .line8disableWindow
        waitForRightVRAMmode
        ;Disable window layer and enable sprite layer
            ld a, [rLCDC]
            or LCDCF_OBJON
            and ~(LCDCF_BG8000);
            ld [rLCDC], a
            ld a, 168
            ld [rWX], a

        ;If message box state, set interrupt accordingly
            ld a, [pCurrentState]
            cp STATE_MessageBox
            jr nz, .endIf
                ld a, [bMsgBoxAnimTimer]
                add 104
                ld [rLYC], a
                pop bc
                pop af
                reti
            .endIf

        ;Prepare next scanline interrupt
            ld a, 144
            ld [rLYC], a
        pop bc
        pop af
        reti

    .line144enableWindow   
        waitForRightVRAMmode
        ;Enable window layer and disable sprites
        ld a, [rLCDC]
        and ~LCDCF_OBJON
        or LCDCF_BG8000;
        ld [rLCDC], a
        ld a, 7
        ld [rWX], a

        ;Set window scroll
        ld a, 7
        ld [rWX], a
        xor a ; ld a, 0
        ld [rWY], a

        ;Prepare next scanline interrupt
        ld a, 8
        ld [rLYC], a
        pop bc
        pop af
        reti

    .lineXshowMessageBox
        waitForRightVRAMmode
        ;Enable window layer and disable sprites
            ld a, [rLCDC]
            and ~LCDCF_OBJON
            or LCDCF_BG8000;
            ld [rLCDC], a
            ld a, 7
            ld [rWX], a

        ;Set window scroll
            ld a, [rLY]
            ld [rWY], a

        ;Prepare next scanline interrupt
            ld a, 144
            ld [rLYC], a

        pop bc
        pop af
        reti


SECTION "User Interface", ROM0
;Update the tiles on the window layer for the gem count and health bar
UpdateHUD:
    push hl

    ;Display gem icon
    ld hl, _SCRN1 ; Window tile data
    inc l
    ld [hl], $7E ; Gem icon
    inc l

    ;Update gem count
    ;Left digit
    ld a, [bCurrGemDec1]
    add $74
    ld [hl+], a

    ;Middle digit
    ld a, [bCurrGemDec2]
    swap a
    and $0F ; Get the high nibble
    add $74
    ld [hl+], a

    ;Right digit
    ld a, [bCurrGemDec2]
    and $0F ; Get the low nibble
    add $74 ; that's where the number tiles start
    ld [hl+], a

    ;Display health icon
    ld l, $0E
    ld [hl], $73 ; health icon
    inc l

    ;Display health bar
    ld a, [bPlayerHealth]
    ;first tile
    cp 2
    call nc, .full
    cp 1
    call z, .half
    call c, .empty

    inc l

    ;second tile
    cp 4
    call nc, .full
    cp 3
    call z, .half
    call c, .empty

    inc l

    ;second tile
    cp 6
    call nc, .full
    cp 5
    call z, .half
    call c, .empty


    pop hl
    ret

    .full
        ld [hl], $70
        ret
    .half
        ld [hl], $71
        ret
    .empty
        ld [hl], $72
        ret

ClearWindowLayer:
    ;Tiles
    ld hl, $9E33
    ld a, $7F
    .loop1
        ld [hl-], a
        bit 2, h
        jr nz, .loop1

    ;Colour palette
    ld a, [bGameboyType]
    cp GAMEBOY_COLOR ; if bGameboyType == GAMEBOY_COLOR
    ret nz
        ;Switch to attributes bank
        ld a, 1
        ld [rVBK], a

        ;Write palette
        ld hl, $9E33
        ld a, $02
        .loop2
            ld [hl-], a
            bit 2, h
            jr nz, .loop2

        ;Switch back to tile bank
        ld a, 0
        ld [rVBK], a
    ret

GenerateMessageBox:
    ;Initialize the pointer at the top left
    ld hl, $9C20

    ;Put corner piece
    ld a, $6A
    ld [hl+], a

    ;Then put exactly 18 horizontal pieces
    inc a
    ld b, 9
    .loopHor1
        ld [hl+], a
        ld [hl+], a
        dec b
        jr nz, .loopHor1

    ;Put corner piece
    inc a
    ld [hl+], a

    ;Put vertical pieces
    inc a
    ld hl, $9C40
    ld [hl+], a

    ld a, $46
    ld b, 18
    .loopTextRow1
        ld [hl+], a
        inc a
        dec b
        jr nz, .loopTextRow1

    ld a, $6D
    ld [hl], a

    ld l, $60
    ld [hl], a

    ld l, $73
    ld [hl], a

    ld l, $80
    ld [hl+], a
    
    ld a, $58
    ld b, 18
    .loopTextRow2
        ld [hl+], a
        inc a
        dec b
        jr nz, .loopTextRow2

    ld a, $6D
    ld [hl], a

    ;Put corner piece
    ld l, $A0
    inc a
    ld [hl+], a

    ;Then put exactly 18 horizontal pieces
    ld a, $6B
    ld b, 9
    .loopHor2
        ld [hl+], a
        ld [hl+], a
        dec b
        jr nz, .loopHor2

    ;Put corner piece
    ld a, $6F
    ld [hl+], a

    ret