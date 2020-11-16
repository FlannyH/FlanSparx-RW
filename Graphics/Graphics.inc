Section "font", ROM0, Align[8]
font_tiles: incbin "./Graphics/font.chr"
font_tiles_end:

Section "tileset_crawdad", ROM0, Align[8]
tileset_crawdad_tiles: incbin "./Graphics/tileset_crawdad.chr"
tileset_crawdad_tiles_end:

Section "tileset_title_tiles", ROM0, Align[8]
tileset_title_tiles: incbin "./Graphics/tileset_title_tile.bin"
tileset_title_tiles_end:

Section "tileset_title_meta", ROM0, Align[8]
tileset_title_meta: incbin "./Graphics/tileset_title_meta.bin"
tileset_title_meta_end:

