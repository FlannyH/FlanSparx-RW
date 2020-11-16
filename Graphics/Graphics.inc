Section "font", ROM0, Align[8]
font_tiles: incbin "./Graphics/font.chr"

font_tiles_end:

Section "tileset_crawdad_tiles", ROM0, Align[8]
tileset_crawdad_tiles: incbin "./Graphics/tileset_crawdad_tile.bin"
tileset_crawdad_tiles_end:

Section "tileset_crawdad_meta", ROM0, Align[8]
tileset_crawdad_meta: incbin "./Graphics/tileset_crawdad_meta.bin"

tileset_crawdad_meta_end:

Section "tileset_title_tiles", ROM0, Align[8]
tileset_title_tiles: incbin "./Graphics/tileset_title_tile.bin"
tileset_title_tiles_end:

Section "tileset_title_meta", ROM0, Align[8]
tileset_title_meta: incbin "./Graphics/tileset_title_meta.bin"

tileset_title_meta_end:

