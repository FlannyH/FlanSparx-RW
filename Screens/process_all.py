import os

script_path = os.path.dirname(__file__) + "\\"

includefile = open(script_path+"Screens.asm", "w")

includefile.write('Section "Screens", ROM0\n')

for root, dirs, files in os.walk(script_path, topdown=False):
    for name in files:
        if (name.endswith(".json")):
            print (f"\t--Converting {name}--")
            os.system(script_path+f"json2bin.py {(os.path.join(root, name))}")
            includefile.write(f'screen_title: incbin "./Screens/{name.replace(".json", ".bin")}"\n')