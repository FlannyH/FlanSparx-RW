import pygame

scale = 4

window = pygame.display.set_mode((128*scale, 128*scale))
buffer = pygame.Surface((128, 128))

graphics_data = open("tileset_title.gbt", "rb").read()

mode = 0 #0: 8x8, 1: 8x16, 2: 16x16

palettef = open("tileset_crawdad.pal", "rb")
palettes = list()
while(1):
    try:
        currpal = list()
        #Read 4 colours
        for c in range(4):
            #Read 2 bytes as 1 colour
            colourbin1 =  bin(ord(palettef.read(1)))[2:].zfill(8)
            colourbin2 = bin(ord(palettef.read(1)))[2:].zfill(7)
            colourbin = colourbin2 + colourbin1
            
            b = int(colourbin[0:5]  , 2)
            g = int(colourbin[5:10] , 2)
            r = int(colourbin[10:15], 2)
            print (r,g,b)
            currpal.append (pygame.Color(r*8,g*8,b*8))
        palettes.append(currpal)
    except:
        break
        
print(palettes[0])
        

while 1:
    pygame.display.flip()
    while (event := pygame.event.poll()):
        if (event.type == pygame.QUIT):
            exit()
    palassign = open("tileset_title.pas", "rb")
    for tile in range(256):
        currpal = palettes[ord(palassign.read(1))]
        for y in range(8):
            for x in range(8):
                try:
                    b1 = bin(graphics_data[tile*0x010 + y * 0x002])[2:].zfill(8)
                    b2 = bin(graphics_data[tile*0x010 + y * 0x002 + 1])[2:].zfill(8)
                    #print (b1, b2)
                    b = b2[x] + b1[x]
                    #print(b)
                    b = int(b, 2)
                    c = currpal[b]
                    if (mode == 0):
                        px = (tile % 16) * 8 + x
                        py = (tile // 16) * 8 + y
                        buffer.set_at((px, py), c)
                    elif (mode == 1):
                        px = (tile>>1) * 8 + x
                        py = ((tile // 32)*2 + (tile & 1)) * 8 + y
                        buffer.set_at((px % 128, py), c)
                        pass
                    elif (mode == 2):
                        px = (((tile>>2)<<1) + tile % 2) * 8 + x
                        py = ((tile // 32)*2 + (tile >> 1 & 1)) * 8 + y
                        buffer.set_at((px % 128, py), c)
                        pass
                except:
                    break
    window.blit(pygame.transform.scale(buffer, (128*scale, 128*scale)), (0, 0))
    palassign.close()
    #input()