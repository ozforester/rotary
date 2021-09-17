TARGET	 = rotary
SOURCES := $(wildcard *.S)
OBJECTS  = $(SOURCES:.S=.o)
CFLAGS = -fno-stack-protector -fno-pic -DF_CPU=4000000 -Wall -mmcu=atmega8 -ffunction-sections -fdata-sections -Os

all:
	avr-gcc ${CFLAGS} -c -Wall ${OPT} -mmcu=atmega8 -o ${TARGET}.o ${TARGET}.S
	avr-gcc ${CFLAGS} -Wall ${OPT} -mmcu=atmega8 -o ${TARGET} ${TARGET}.o
	avr-objcopy -R .eeprom -O ihex ${TARGET} ${TARGET}.hex
	avr-size ${TARGET}
	avr-size ${TARGET}.hex

flash:
	avrdude -c usbasp -p m8 -B 2 -U flash:w:${TARGET}.hex

clean:
	rm -f $(OBJECTS) ${TARGET}  $(TARGET).o $(TARGET).elf $(TARGET).hex
