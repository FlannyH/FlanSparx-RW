;Sprite orders are formatted just like OAM entries, but without Y and X, so (Tile ID, Attributes)
;Each sprite is made of 2 parts
Section "Sprite Orders", ROM0,align[5]
SpriteOrders_Player:
SprPlayer_0:   db $00, $00, $02, $00
SprPlayer_45:  db $04, $00, $06, $00
SprPlayer_90:  db $08, $00, $08, $20
SprPlayer_135: db $06, $20, $04, $20
SprPlayer_180: db $02, $20, $00, $20
SprPlayer_225: db $06, $60, $04, $60
SprPlayer_270: db $08, $40, $08, $60
SprPlayer_315: db $04, $40, $06, $40