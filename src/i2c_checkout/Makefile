# this retains the intermediate files
.PRECIOUS: %.s %.obj
CC=pblaze-cc.py
AS=pblaze-as.py
LD=pblaze-ld.py

# pblaze-ld/pblaze-as flags
CFLAGS=-l
LDFLAGS=
ASFLAGS=-6

# target. Change this only (other than flags).
all: i2c_checkout_rom.v

clean:
	rm -rf *.v
	rm -rf *.obj
	rm -rf *.s
	rm -rf *.hex

%.s : %.c
	$(CC) $(CFLAGS) $<

%.obj : %.s
	$(AS) $(ASFLAGS) $<

%.hex : %.s
	$(AS) $(ASFLAGS) --hex $<

%.v : %.obj
	$(LD) $(LDFLAGS) $<


