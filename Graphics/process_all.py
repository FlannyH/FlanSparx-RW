import os

includefile = open("Graphics.asm", "w")

for root, dirs, files in os.walk(".", topdown=False):
    for name in files:
        if (name.endswith(".gbt")):
            print (f"\t--Converting {name}--")
            os.system(f"removestraydata.py {(os.path.join(root, name))}")
            os.system(f"compresstile.py {(os.path.join(root, name))}")
            includefile.write(f"Section \"{name[:-4]}_tiles\", ROMX, Align[8]\n")
            includefile.write(f"{name[:-4]}_tiles: incbin \"./Graphics/{name[:-4]}_tile.bin\"\n")
            includefile.write(f"{name[:-4]}_tiles_end:\n\n")
            includefile.write(f"Section \"{name[:-4]}_meta\", ROM0, Align[8]\n")
            includefile.write(f"{name[:-4]}_meta: incbin \"./Graphics/{name[:-4]}_meta.bin\"\n")
            includefile.write(f"{name[:-4]}_meta_end:\n\n")
        if (name.endswith(".gbs")):
            print (f"\t--Converting {name}--")
            os.system(f"removestraydata.py {(os.path.join(root, name))}")
            os.system(f"compresssprite.py {(os.path.join(root, name))}")
            includefile.write(f"Section \"{name[:-4]}_tiles\", ROM0, Align[8]\n")
            includefile.write(f"{name[:-4]}_tiles: incbin \"./Graphics/{name[:-4]}_tile.bin\"\n")
            includefile.write(f"{name[:-4]}_tiles_end:\n\n")
            includefile.write(f"Section \"{name[:-4]}_meta\", ROM0, Align[8]\n")
            includefile.write(f"{name[:-4]}_meta: incbin \"./Graphics/{name[:-4]}_meta.bin\"\n")
            includefile.write(f"{name[:-4]}_meta_end:\n\n")
        if (name.endswith(".chr")):
            includefile.write(f"Section \"{name[:-4]}\", ROM0, Align[8]\n")
            includefile.write(f"{name[:-4]}_tiles: incbin \"./Graphics/{name}\"\n")
            includefile.write(f"{name[:-4]}_tiles_end:\n\n")
        if (name.endswith(".pas")):
            includefile.write(f"Section \"{name[:-4]}_palassign\", ROM0, Align[8]\n")
            includefile.write(f"{name[:-4]}_palassign: incbin \"./Graphics/{name}\"\n")
            includefile.write(f"{name[:-4]}__palassign_end:\n\n")
        if (name.endswith(".pal")):
            includefile.write(f"Section \"{name[:-4]}_palette\", ROM0, Align[7]\n")
            includefile.write(f"{name[:-4]}_palette: incbin \"./Graphics/{name}\"\n")
            includefile.write(f"{name[:-4]}_palette_end:\n\n")