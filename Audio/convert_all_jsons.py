import subprocess
import os

for root, dirs, files in os.walk(".", topdown=False):
    for name in files:
        if (name.endswith(".wav")):
            print (f"\n\n--Converting {name}--")
            newname = name.replace(".wav", "")
            if not os.path.exists(newname + ".bin"):
                os.system(f"wav2bin.py {(os.path.join(root, name))}.wav > nul")
                fInc.write("Section """)