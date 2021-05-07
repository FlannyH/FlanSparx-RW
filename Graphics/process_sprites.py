import pygame
import os
pygame.init()

transparency_color = pygame.Color(0, 0, 0)
file_out_2bpp = open("sprites_crawdad.chr", "wb")
file_out_pal = open("tileset_crawdad.pal", "r+b")
file_out_pal.seek(64)
sprite_order_data_raw = list()
filenames = list()
palettes = list()
palette_mapping = list()

def FlipHorizontal(tile):
	flipped_tile = list()

	for row in tile:
		flipped_tile.append(int(bin(row)[2:].zfill(8)[::-1], 2))

	return flipped_tile

def FlipVertical(tile):
	flipped_tile = list()

	for y in range(32):
		#Good old swizzling around
		y_modified = (31-y) ^ 0x01
		flipped_tile.append(tile[y_modified])

	return flipped_tile

def FlipBoth(tile):
	return FlipHorizontal(FlipVertical(tile))

def ProcessImage(filename):
	global file_out_2bpp
	#Open file
	file_in_png = pygame.image.load(filename)

	colours = list()

	#Get palette
	for y in range(file_in_png.get_height()):
		for x in range(file_in_png.get_width()):
			colour = file_in_png.get_at((x, y))
			if colour not in colours:
				colours.append(colour)

	#Check colour limit
	if len(colours) > 4:
		print (f"[ERROR] File '{filename}' has {len(colours)} colours, max supported is 4")
		exit()

	transparent_found = False
	for c in colours:
		if c.a == 0 or c == transparency_color:
			transparent_found = True
			del colours[colours.index(c)]

	#Check if transparent colour exists
	if not transparent_found:
		print (f"[ERROR] File '{filename}' has no transparent colour!")
		exit()

	#Get distances to black and white colour palettes - this is to determine the palette's order
	bw_palette = [0, 85, 170, 255]

	distance_from_black = [(c.r*c.r + c.g*c.g + c.b*c.b) ** 0.5 for c in colours]

	#Very bad bubble sort oh god what the fuck lmao send help
	while True:
		changes = 0
		if distance_from_black[0] > distance_from_black[1]:
			#Swap distances
			tmp = distance_from_black[0]
			distance_from_black[0] = distance_from_black[1]
			distance_from_black[1] = tmp

			#Swap colours
			tmp = colours[0]
			colours[0] = colours[1]
			colours[1] = tmp

			changes += 1
		if distance_from_black[1] > distance_from_black[2]:
			#Swap
			tmp = distance_from_black[1]
			distance_from_black[1] = distance_from_black[2]
			distance_from_black[2] = tmp

			#Swap colours
			tmp = colours[1]
			colours[1] = colours[2]
			colours[2] = tmp

			changes += 1
		if changes == 0:
			break

	#Now process the actual image
	curr_sprite_order_data = list()
	for x_offset in range(0, file_in_png.get_width(), 8):
		curr_sprite_order_data.append(file_out_2bpp.tell()//32)
		for y in range(16):
			bitplane1 = 0
			bitplane2 = 0
			for x in range(8):
				bitplane1 <<= 1
				bitplane2 <<= 1
				
				pixel = file_in_png.get_at((x+x_offset, y))
				#If transparent, this is a zero
				if pixel.a != 0 and pixel != transparency_color:
					index = colours.index(pixel)
					bitplane1 |= 1 * (((index + 1) & 0x01) > 0)
					bitplane2 |= 1 * (((index + 1) & 0x02) > 0)
			file_out_2bpp.write(bytes([bitplane1, bitplane2]))
	sprite_order_data_raw.append(curr_sprite_order_data)

	#Save the palette
	if colours not in palettes:
		palettes.append(colours)
	palette_mapping.append(palettes.index(colours))

for root, dirs, files in os.walk(".", topdown=False):
	for name in files:
		if name.endswith(".png"):
			ProcessImage(name)
			filenames.append(name[:-4])

#Find duplicates
file_out_2bpp.close()
file_in_2bpp = open("sprites_crawdad.chr", "rb")

unique_sprite_chunks = list()
mapping = list()
attributes = list()

curr_tile_id = 0
while True:
	if not (curr_sprite_chunk := list(file_in_2bpp.read(32))):
		break
	#Handle no flip
	if curr_sprite_chunk in unique_sprite_chunks:
		mapping.append(unique_sprite_chunks.index(curr_sprite_chunk))
		attributes.append(0x00)
	#Handle horizontal flip
	elif FlipHorizontal(curr_sprite_chunk) in unique_sprite_chunks:
		mapping.append(unique_sprite_chunks.index(FlipHorizontal(curr_sprite_chunk)))
		attributes.append(0x20)
	#Handle vertical flip
	elif FlipVertical(curr_sprite_chunk) in unique_sprite_chunks:
		mapping.append(unique_sprite_chunks.index(FlipVertical(curr_sprite_chunk)))
		attributes.append(0x40)
	#Handle both flip
	elif FlipBoth(curr_sprite_chunk) in unique_sprite_chunks:
		mapping.append(unique_sprite_chunks.index(FlipBoth(curr_sprite_chunk)))
		attributes.append(0x60)
	else:
		unique_sprite_chunks.append(curr_sprite_chunk)
		mapping.append(unique_sprite_chunks.index(curr_sprite_chunk))
		attributes.append(0x00)
	curr_tile_id += 1

#Replace duplicates in array
for sprite_index in range(len(sprite_order_data_raw)):
	for tile_index in range(len(sprite_order_data_raw[sprite_index])):
		sprite_order_data_raw[sprite_index][tile_index] = [mapping[sprite_order_data_raw[sprite_index][tile_index]], attributes[sprite_order_data_raw[sprite_index][tile_index]]]

#Write only unique tiles to output
file_in_2bpp.close()
file_out_2bpp = open("sprites_crawdad.chr", "wb")
for tile in unique_sprite_chunks:
	file_out_2bpp.write(bytes(tile))

#Get groups
group_file = open("groups.txt", "r")
group_data = group_file.read()
group_data = group_data.replace("\n","")
group_data = group_data.replace("\r","")
group_data = group_data.replace("\t","")
group_data = group_data.replace(" ","")
group_data_split = group_data.split(";")

groups = list()
for group in group_data_split:
	try:
		name, members = group.split("=")
		members = members.replace("{", "").replace("}", "")
		members = members.split(",")
	except:	
		continue
	groups.append ([name, members])

#Write metadata file
file_out_metadata = open("Sprites_meta.asm", "w")
file_out_metadata.write('Section "Sprite orders", ROM0, ALIGN[5]\n')

#Create file ordering - groups first, rest added in whatever order the code wants
for group in groups:
	file_out_metadata.write(group[0] + ":\n")
	for filename in group[1]:
		index = filenames.index(filename)
		file_out_metadata.write(filenames[index] + ": db ")

		for y in range (len(sprite_order_data_raw[index])):
			file_out_metadata.write ("$" + hex(2*sprite_order_data_raw[index][y][0])[2:].zfill(2).upper() + ", ")
			file_out_metadata.write ("$" + hex(palette_mapping[index] + sprite_order_data_raw[index][y][1])[2:].zfill(2).upper())
			if ((y+1) < len(sprite_order_data_raw[index])):
				file_out_metadata.write (", ")
			else:
				file_out_metadata.write ("\n")

		del filenames[index]
		del palette_mapping[index]
		del sprite_order_data_raw[index]


for x in range(len(filenames)):
	file_out_metadata.write(filenames[x] + ": db ")
	for y in range (len(sprite_order_data_raw[x])):
		file_out_metadata.write ("$" + hex(2*sprite_order_data_raw[x][y][0])[2:].zfill(2).upper() + ", ")
		file_out_metadata.write ("$" + hex(palette_mapping[x] + sprite_order_data_raw[x][y][1])[2:].zfill(2).upper())
		if ((y+1) < len(sprite_order_data_raw[x])):
			file_out_metadata.write (", ")
		else:
			file_out_metadata.write ("\n")

if (len(palettes) >= 8):
	print (f"[ERROR] Too many colour palettes! Game Boy Colour supports a maximum of 8, but {len(palettes)} were detected!")
	exit()

for colours in palettes:
	#Colour 0 is black
	file_out_pal.write(bytes([0, 0]))
	for c in colours:
		word = 0
		word |= ((c.r >> 3) << 0)
		word |= ((c.g >> 3) << 5)
		word |= ((c.b >> 3) << 10)
		file_out_pal.write (word.to_bytes(2, "little"))