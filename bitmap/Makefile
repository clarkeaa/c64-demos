bitmap.prg: bitmap.asm c64-speedracer.data
	acme bitmap.asm

play: bitmap.prg
	open bitmap.prg

convert: convert.c
	clang -g convert.c -o convert

c64-speedracer.data: speedracer.data convert
	./convert speedracer.data c64-speedracer.data
