import os

includefile = open("Maps.inc", "w")

for root, dirs, files in os.walk(".", topdown=False):
    for name in files:
        if (name.endswith(".json")):
            print (f"\t--Converting {name}--")
            os.system(f"json2bin.py {name}")
            os.system(f"removestraydata.py {name.replace('.json','.bin')}")
            includefile.write(f'Section "{name.replace(".json","")}", ROMX, ALIGN[14]\n')
            includefile.write(f'{name.replace(".json","")}: incbin "./Maps/{name.replace(".json",".bin")}"\n\n')