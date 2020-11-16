from sys import argv
from math import ceil
infile = open(argv[1], "rb")
lastbyteindex = -1
data = infile.read()
infile.close()
index = len(data)
while index > 0:
    index -= 1
    if data[index] != 0x00:
        print (index)
        break;

length = ceil(((index+1) / 16)) * 16 #each tile is 16 bytes, so round up
   
outfile = open(argv[1], "wb")
outfile.write(data[:length])
print ("Done!")