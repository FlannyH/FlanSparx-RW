import wave
import sys

name = sys.argv[1].replace(".wav","")

infile = wave.open(f"{name}.wav", 'rb')
outfile = open(f"{name}.bin", "wb")
frame = 0

current_byte = 0


if infile.getnchannels() == 1:
	while frame != None:
		curr_byte = 0
		frame = infile.readframes(1)[0]
		frame = int(round(frame/255*15))
		curr_byte |= frame
		curr_byte = curr_byte << 4
		frame = infile.readframes(1)[0]
		frame = int(round(frame/255*15))
		curr_byte |= frame
		outfile.write(bytes([curr_byte]))
		current_byte += 1
		if current_byte > 7*1024*1024:
			exit()
			
else:
	while frame != None:
		curr_byte = 0
		frame = infile.readframes(1)
		frame1 = int(frame[0]/255*15)
		frame2 = int(frame[1]/255*15)
		frame1 = frame1 << 4
		frame1 += frame2
		outfile.write(bytes([frame1]))
		current_byte += 1
		if current_byte > 7*1024*1024:
			exit()