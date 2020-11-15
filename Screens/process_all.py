import os

includefile = open("Screens.inc", "w")

includefile.write('Section "Screens", ROM0\n')

for root, dirs, files in os.walk(".", topdown=False):
    for name in files:
        if (name.endswith(".json")):
            print (f"\t--Converting {name}--")
            os.system(f"json2bin.py {(os.path.join(root, name))}")
            includefile.write(f'screen_title: incbin "./Screens/{name.replace(".json", ".bin")}"\n')