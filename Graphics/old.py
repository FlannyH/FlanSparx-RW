import os
import pygame

script_path = os.path.dirname(__file__) + "\\"

def Sort(colours, distance_from_black):
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


def ProcessImage(filepath):
	print (filepath)
	image = pygame.image.load(filepath)
	output = open(filepath[:-4] + ".chr", "wb")
	#Get palettes
	palettes = list()

	#Loop over every tile
	for tile_y in range(16):
		try:
			for tile_x in range(16):
				#Get all the different colours
				colours = list()
				for y in range(8):
					for x in range(8):
						pixel = image.get_at(((tile_x*8)+x, (tile_y*8)+y))
						if pixel not in colours:
							colours.append(pixel)
							
				new_colours = [None, None, None, None]
				thresholds = [x/3 for x in range(4)]
				distance_from_black = [c.hsla[2] / 100 for c in colours]

				available_mappings = [0, 1, 2, 3]

				while len(colours) > 0:
					lowest_index = distance_from_black.index(min(distance_from_black))
					distances = [abs(x - distance_from_black[lowest_index]) for x in thresholds]
					mapping = distances.index(min(distances))

					new_colours[available_mappings[mapping]] = colours[lowest_index]
					del distance_from_black[lowest_index]
					del colours[lowest_index]
					del thresholds[mapping]
					del available_mappings[mapping]

				colours = new_colours
				print (colours)
				
				#print (colours)
		except Exception as e:
			print(e)
			break

for root, dirs, files in os.walk(script_path + "Tiles\\", topdown=False):
	for name in files:
		if name.endswith(".png"):
			ProcessImage(root+name)

