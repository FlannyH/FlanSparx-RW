from sys import argv
infile = open(argv[1], "rb")
outfile = open(f"{argv[1].replace('.gbs', '') + '_tile.bin'}", "wb")
outfile2 = open(f"{argv[1].replace('.gbs', '') + '_meta.bin'}", "wb")
dupes = list()
dupesMirror = list()
amountOfDupesFound = 0
while True:
    #read 16 
    data = infile.read(32)
    if (len(data) == 0):
        break
    #print(list(data))
    
    if data in dupes:
        outfile2.write (bytes([dupes.index(data)]))
        outfile2.write (bytes([0x00]))
        amountOfDupesFound += 1
        continue
    elif data in dupesMirror:
        amountOfDupesFound += 1
        outfile2.write (bytes([dupesMirror.index(data)]))
        outfile2.write (bytes([0x20]))
        continue
    else:
        #normal
        dupes.append(data)
        #mirror
        old_data = list(data)
        new_data = list()
        for byte in old_data:
            new_byte = 0
            for x in range(8):
                if (byte & (1<<(7-x))):
                    new_byte += (1<<x)
            new_data.append(new_byte)
        dupesMirror.append(bytes(new_data))
        outfile2.write (bytes([dupes.index(data)]))
        outfile2.write (bytes([0x00]))

    outfile.write(data)
    
print (f"Done! - Removed {amountOfDupesFound} duplicate sprites")