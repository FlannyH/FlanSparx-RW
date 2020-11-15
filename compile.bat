cd Graphics
process_all.py
cd ..

cd Screens
process_all.py
cd ..

"../COMPILER/rgbasm" -o FlanSparx.o FlanSparx.asm
"../COMPILER/rgblink" -n FlanSparx.sym -o FlanSparx.gbc FlanSparx.o
"../COMPILER/rgbfix" -j -t FlanTest -m 27 -v -p 0 -r 1 FlanSparx.gbc
rem start FlanSparx.gbc
pause