import os
script_path = os.path.dirname(__file__) + "\\"
charmap =  " !\"#$%&'()*+,-./:;<=>?@0123456789ABDCEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\n"
outfile = open(script_path+"Charmap.inc","w")
i = 128
for c in charmap:
    if c == "\\":
        value = "\\\\"
    elif c == "\"":
        value = "\\\""
    elif c == "{":
        value = "\\{"
    elif c == "\n":
        value = "\\n"
    else:
        value = c
    outfile.write(f"charmap \"{value}\", ${hex(i)[2:].zfill(2)}\n")
    i += 1