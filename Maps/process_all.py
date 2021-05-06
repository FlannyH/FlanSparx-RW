import os

includefile = open("Maps.inc", "w")
includefile.write('include "constants.asm"\n\n')

for root, dirs, files in os.walk(".", topdown=False):
    for name in files:
        currBank = 1
        if (name.endswith(".json")):
            print (f"\t--Converting {name}--")
            os.system(f"json2bin.py {name}")
            os.system(f"removestraydata.py {name.replace('.json','.bin')}")
            includefile.write(f'Section "{name.replace(".json","")}", ROMX[MAPDATA], BANK[{currBank}]\n')
            includefile.write(f'{name.replace(".json","")}: incbin "./Maps/{name.replace(".json",".bin")}"\n\n')
            includefile.write(f'Section "{name.replace(".json","")} metadata", ROMX[MAPMETA], BANK[{currBank}]\n')
            includefile.write(f'{name.replace(".json","")}_meta: incbin "./Maps/{name.replace(".json","_meta.bin")}"\n\n')
            includefile.write(f'Section "{name.replace(".json","")} objects", ROMX[OBJDATA], BANK[{currBank}]\n')
            includefile.write(f'{name.replace(".json","")}_obj: incbin "./Maps/{name.replace(".json","_obj.bin")}"\n\n')