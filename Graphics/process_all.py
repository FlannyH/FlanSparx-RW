import os

for root, dirs, files in os.walk(".", topdown=False):
    for name in files:
        if (name.endswith(".gbt")):
            print (f"\t--Converting {name}--")
            os.system(f"removestraydata.py {(os.path.join(root, name))}")
            os.system(f"compresstile.py {(os.path.join(root, name))}")
        if (name.endswith(".gbs")):
            print (f"\t--Converting {name}--")
            os.system(f"removestraydata.py {(os.path.join(root, name))}")
            os.system(f"compresssprite.py {(os.path.join(root, name))}")