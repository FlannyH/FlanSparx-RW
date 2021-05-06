import os

link_command = '""RGBDS/rgblink" -n FlanSparx.sym -o FlanSparx.gbc "'

for root, dirs, files in os.walk(".", topdown=False):
    for name in files:
        if (name.endswith(".asm")) or (name.endswith(".gbz80")) or (name.endswith(".inc")):
            source = (os.path.join(root, name))
            destination = name.replace(name.split(".")[-1], "o")
            print(destination)
            os.system(f'""RGBDS/rgbasm" -E -o "o/{destination}" "{source}""')
            link_command += "o/" + destination + " "

os.system (link_command)
os.system('""RGBDS/rgbfix" -j -t FlanTest -m 27 -v -p 0 -r 1 -c FlanSparx.gbc"')