from sys import argv
import json

#Handle arguments
if (len(argv) != 2):
    print("Usage: csv2bin.py <input.json>")
    exit()

#Load file
infile = open(argv[1], "r")

jsonData = json.load(infile)

#Find tile layer
tiles = list()

#Get tileset ID
tilesetID = 0

for layer in jsonData["layers"]:
    #print (layer["name"])
    
    if layer["name"] == "tiles":
        tilesetStart = layer["data"][0] #tileset starts at an offset for some reason, note that and correct for it
        height = 128
        width = 128
        
        for x in range(width):
            for y in range(height):
                tileid = layer["data"][x*height + y] - tilesetStart
                if (tileid > 255 or tileid < 0):
                    print (f"Error at tile position ({x}, {y}), tile id {tileid} is invalid")
                tiles.append(layer["data"][x*height + y] - tilesetStart)
                
#Write it to a binary file
outfile = open(argv[1].replace(".json", ".bin"), "wb")

#Write the data
outfile.write(bytes(tiles)) #Level data length
outfile.close()

print ("Done!")