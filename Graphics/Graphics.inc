Section "font", ROM0, Align[8]
font_tiles: incbin "Graphics/font.chr"
font_tiles_end:

Section "sprites_crawdad", ROM0, Align[8]
sprites_crawdad_tiles: incbin "Graphics/sprites_crawdad.chr"
sprites_crawdad_tiles_end:

Section "tileset_crawdad", ROM0, Align[8]
tileset_crawdad_tiles: incbin "Graphics/tileset_crawdad.chr"
tileset_crawdad_tiles_end:

Section "tileset_crawdad_palette", ROM0, Align[7]
tileset_crawdad_palette: incbin "Graphics/tileset_crawdad.pal"
tileset_crawdad_palette_end:

Section "tileset_crawdad_palassign", ROM0, Align[8]
tileset_crawdad_palassign: incbin "Graphics/tileset_crawdad.pas"
tileset_crawdad__palassign_end:

Section "tileset_title_tiles", ROMX, Align[8]
tileset_title_tiles: incbin "Graphics/tileset_title_tile.bin"
tileset_title_tiles_end:

Section "tileset_title_meta", ROM0, Align[8]
tileset_title_meta: incbin "Graphics/tileset_title_meta.bin"
tileset_title_meta_end:

Section "tileset_title_palassign", ROM0, Align[8]
tileset_title_palassign: incbin "Graphics/tileset_title.pas"
tileset_title__palassign_end:

