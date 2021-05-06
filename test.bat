mkdir o
"../COMPILER/rgbasm" -E -o o/FlanSparx.o FlanSparx.asm
"../COMPILER/rgbasm" -E -o o/hardware.o "hardware.inc"
"../COMPILER/rgbasm" -E -o o/variables.o "variables.asm"
"../COMPILER/rgbasm" -E -o o/Graphics.o "Graphics/Graphics.inc"
"../COMPILER/rgbasm" -E -o o/SpriteOrders.o "Graphics/SpriteOrders.inc"
"../COMPILER/rgbasm" -E -o o/Screens.o "Screens/Screens.inc"
"../COMPILER/rgbasm" -E -o o/Maps.o "Maps/Maps.inc"
"../COMPILER/rgbasm" -E -o o/Charmap.o "Code/Charmap.inc"
"../COMPILER/rgbasm" -E -o o/Macros.o "Code/Macros.asm"
"../COMPILER/rgbasm" -E -o o/Controls.o "Code/Controls.asm"
"../COMPILER/rgbasm" -E -o o/MapHandler.o "Code/MapHandler.asm"
"../COMPILER/rgbasm" -E -o o/TitleScreen.o "Code/TitleScreen.asm"
"../COMPILER/rgbasm" -E -o o/GameLoop.o "Code/GameLoop.asm"
"../COMPILER/rgbasm" -E -o o/InterruptVectors.o "Code/InterruptVectors.asm"
"../COMPILER/rgbasm" -E -o o/SpriteHandler.o "Code/SpriteHandler.asm"
"../COMPILER/rgbasm" -E -o o/Bullet.o "Code/Bullet.asm"
"../COMPILER/rgbasm" -E -o o/Text.o "Code/Text.asm"
"../COMPILER/rgbasm" -E -o o/Objects.o "Code/Objects.asm"
"../COMPILER/rgbasm" -E -o o/HUD.o "Code/HUD.asm"
"../COMPILER/rgbasm" -E -o o/MessageBox.o "Code/MessageBox.asm"
"../COMPILER/rgbasm" -E -o o/Pointers.o "Code/Pointers.asm"
"../COMPILER/rgbasm" -E -o o/RedGem.o "Code/RedGem.asm"
"../COMPILER/rgbasm" -E -o o/Multiply.o "Code/Multiply.asm"
"../COMPILER/rgbasm" -E -o o/Misc.o "Code/Misc.asm"
"../COMPILER/rgbasm" -E -o o/Player.o "Code/Player.asm"
"../COMPILER/rgbasm" -E -o o/Collision.o "Code/Collision.asm"
"../COMPILER/rgbasm" -E -o o/tileset_collision.o "Graphics/tileset_collision.asm"
cd o
"../../COMPILER/rgblink" -n FlanSparx.sym -o FlanSparx.gbc FlanSparx.o hardware.o variables.o Graphics.o SpriteOrders.o Screens.o Maps.o Charmap.o Macros.o Controls.o MapHandler.o TitleScreen.o GameLoop.o InterruptVectors.o SpriteHandler.o Bullet.o HUD.o MessageBox.o Pointers.o RedGem.o Multiply.o Misc.o Player.o Collision.o tileset_collision.o Objects.o Text.o
"../../COMPILER/rgbfix" -j -t FlanTest -m 27 -v -p 0 -r 1 -c FlanSparx.gbc
cd ..