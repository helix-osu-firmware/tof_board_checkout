# this retains the intermediate files
.PRECIOUS: %.s %.obj
CC=pblaze-cc.py
AS=pblaze-as.py
LD=pblaze-ld.py

# pblaze-ld/pblaze-as flags
LDFLAGS=
ASFLAGS=-6

# target. Change this only.
all: board_checkout_spi_rom.v

clean:
	rm -rf *.v *.obj *.s

%.s : %.c
	$(CC) $(CFLAGS) $<

%.obj : %.s
	$(AS) $(ASFLAGS) $<

%.v : %.obj
	$(LD) $(LDFLAGS) $<


