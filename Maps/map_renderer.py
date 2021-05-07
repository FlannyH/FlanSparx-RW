import pygame
import os

map_name = "map_tutorial"

#Open files
tileset = pygame.image.load("newtileset.png")
map_bin = open(map_name + ".bin", "rb")

#Get map width
map_width = ord(open(map_name + "_meta.bin", "rb").read(1))
map_height = os.path.getsize(map_name + ".bin") // map_width
print (map_width, map_height)

#Prepare surface
surface = pygame.Surface((map_width*16, map_height*16))

for y in range(map_height):
    for x in range(map_width):
        #Get tile id
        tile_id = ord(map_bin.read(1))
        
        tile_y = (tile_id // 8) * 16
        tile_x = (tile_id % 8) * 16
        
        #Render tile id
        for tile_sub_y in range(16):
            for tile_sub_x in range(16):
                #Get pixel
                pixel = tileset.get_at((tile_x + tile_sub_x, tile_y + tile_sub_y))
                #Write pixel
                surface.set_at(((x*16)+tile_sub_x, (y*16)+tile_sub_y), pixel)
                   
pygame.image.save(surface, map_name + "_render.png")