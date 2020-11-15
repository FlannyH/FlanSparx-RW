from sys import argv
infile = open(argv[1], "rb")
outfile = open(f"{argv[1].replace('.gbt', '')}_tile.bin", "wb")
outfile2 = open(f"{argv[1].replace('.gbt', '')}_meta.bin", "wb")
dupes = list()
amountOfDupesFound = 0
while True:
    #read 8 bytes
    data = infile.read(16)
    if (len(data) == 0):
        break
    #print(list(data))
    
    if data in dupes:
        outfile2.write (bytes([dupes.index(data)]))
        amountOfDupesFound += 1
        continue
    else:
        dupes.append(data)
        outfile2.write (bytes([dupes.index(data)]))

    
    
    
    outfile.write(data)
print (f"Done! - Removed {amountOfDupesFound} duplicate tiles")