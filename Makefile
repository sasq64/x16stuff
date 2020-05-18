

test.prg : test.asm
	java -jar $(HOME)/.local/bin/KickAss.jar test.asm

run : test.prg
	$(HOME)/projects/x16-emulator/build/x16-emu -rom rom.bin -prg test.prg -run

