MACRO Position12_4
\1::
	.x
		.x_low
		.x_subpixel
			ds 1
		.x_high
		.x_metatile
			ds 1
	.y
		.y_low
		.y_subpixel
			ds 1
		.y_high
		.y_metatile
			ds 1
ENDM

MACRO Object
\1::
	.state ; 1 byte
		ds 1
	.x ; 2 bytes
		.x_low
		.x_subpixel
			ds 1
		.x_high
		.x_metatile
			ds 1
	.y ; 2 bytes
		.y_low
		.y_subpixel
			ds 1
		.y_high
		.y_metatile
			ds 1
	.direction ; 1 byte
		ds 1
	.velocity_x ; 1 byte
		ds 1
	.velocity_y ; 1 byte
		ds 1
ENDM