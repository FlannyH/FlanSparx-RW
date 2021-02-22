import os

includefile = open("Maps.inc", "w")

includefile.write("MAPDATA equ $4000\n")
includefile.write("OBJDATA equ $7FF0\n\n")

for root, dirs, files in os.walk(".", topdown=False):
    for name in files:
        currBank = 1
        if (name.endswith(".json")):
            print (f"\t--Converting {name}--")
            os.system(f"json2bin.py {name}")
            os.system(f"removestraydata.py {name.replace('.json','.bin')}")
            includefile.write(f'Section "{name.replace(".json","")}", ROMX[$4000], BANK[{currBank}]\n')
            includefile.write(f'{name.replace(".json","")}: incbin "./Maps/{name.replace(".json",".bin")}"\n\n')
            
            includefile.write(f'Section "{name.replace(".json","")} objects", ROMX[$7F00], BANK[{currBank}]\n')
            includefile.write(f'{name.replace(".json","")}_obj: incbin "./Maps/{name.replace(".json","_obj.bin")}"\n\n')