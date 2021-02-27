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
        tilesetStartIDs = [x["firstgid"] for x in jsonData["tilesets"]] #layer["data"][0] #tileset starts at an offset for some reason, note that and correct for it
        height = jsonData["height"]
        width = jsonData["width"]
        
        for x in range(width):
            for y in range(height):
                tileid = -1
                i = 0
                while (tileid > 255 or tileid < 0):
                    tileid = layer["data"][x*height + y] - tilesetStartIDs[i]
                    i += 1
                tiles.append(tileid)
                
#Write it to a binary file
outfile = open(argv[1].replace(".json", ".bin"), "wb")
outfile.write(bytes(tiles)) #Level data length
outfile.close()

outfile = open(argv[1].replace(".json", "_meta.bin"), "wb")
outfile.write(bytes([width]))

print ("Done!")