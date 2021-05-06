#Meta
ROM_NAME := FlanSparx
ROM_EXT := gbc

#Directory constants
DIR_CODE := Code
DIR_GRAPHICS := Graphics
DIR_SCREENS := Screens
DIR_MAPS := Maps
DIR_BIN := Bin
DIR_OBJ := Obj
DIR_RGBDS := RGBDS

#ASM input
SRCS = $(wildcard */*.asm)
DEST_PART1 = $(patsubst $(DIR_CODE)/%.asm,$(DIR_OBJ)/%.o,$(SRCS))
DEST_PART2 = $(patsubst $(DIR_SCREENS)/%.asm,$(DIR_OBJ)/%.o,$(DEST_PART1))
DEST_PART3 = $(patsubst $(DIR_MAPS)/%.asm,$(DIR_OBJ)/%.o,$(DEST_PART2))
DEST = $(patsubst $(DIR_GRAPHICS)/%.asm,$(DIR_OBJ)/%.o,$(DEST_PART3))

#ROM output
ROM = $(DIR_BIN)/$(ROM_NAME).$(ROM_EXT)

#Compilation arguments
ARG_RGBASM := -E
ARG_RGBLINK := 
ARG_RGBFIX := -j -t FlanTest -m 27 -v -p 255 -r 1 -c

# Program constants
ifneq ($(OS),Windows_NT)
	# POSIX OSes
	RM_RF := rm -rf
	MKDIR_P := mkdir -p
else
	# Windows
	RM_RF := -del /q
	MKDIR_P := -mkdir
endif

#Target
all: $(ROM)
#	$(RM_RF) Obj
.PHONY: all


#Compilation
$(DIR_BIN)/%.$(ROM_EXT) $(DIR_BIN)/%.sym $(DIR_BIN)/%.map: $(DEST)
	$(DIR_RGBDS)/rgblink $(ARG_RGBLINK) -m $(DIR_BIN)/$*.map -n $(DIR_BIN)/$*.sym -o $(DIR_BIN)/$*.$(ROM_EXT) $^
	$(DIR_RGBDS)/rgbfix $(ARG_RGBFIX) $(DIR_BIN)/$*.$(ROM_EXT)

vpath %.asm $(DIR_CODE) $(DIR_GRAPHICS) $(DIR_SCREENS) $(DIR_MAPS)

$(DIR_OBJ)/%.o $(DIR_OBJ)/%.mk: %.asm
#	-mkdir $(DIR_OBJ)
	$(DIR_RGBDS)/rgbasm $(ARG_RGBASM) -M ./$(DIR_OBJ)/$*.mk -o ./$(DIR_OBJ)/$*.o "$<"

run_scripts:
	python Graphics/process_all.py