CFLAGS  ?=  -W -Wall -Wextra -Werror -Wundef -Wshadow -Wdouble-promotion \
            -Wformat-truncation -fno-common -Wconversion \
            -g3 -Os -ffunction-sections -fdata-sections -I. \
            -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 $(EXTRA_CFLAGS)
LDFLAGS ?= -Tlink.ld -nostartfiles -nostdlib --specs nano.specs -lc -lgcc -Wl,--gc-sections -Wl,-Map=$@.map
SOURCES = main.c

ifeq ($(OS),Windows_NT)
  RM = cmd /C del /Q /F
else
  RM = rm -f
endif

build: firmware.bin

firmware.elf: $(SOURCES) link.ld
	arm-none-eabi-gcc $(SOURCES) $(CFLAGS) $(LDFLAGS) -o $@

firmware.bin: firmware.elf
	arm-none-eabi-objcopy -O binary $< $@

flash: firmware.bin
	openocd \
		-f /usr/share/openocd/scripts/interface/stlink.cfg \
	    -f /usr/share/openocd/scripts/target/stm32f4x.cfg  \
		-c "program firmware.bin exit 0x08000000 reset"

# debug target: ttyACM0
# serial port: ttyACM1
flash-bmp: firmware.bin
	gdb-multiarch \
		-ex 'target extended-remote /dev/ttyACM0' \
		-ex 'monitor swdp_scan' \
		-ex 'attach 1' \
		-ex 'load firmware.bin' \
		-ex 'exit'


flash-jlink: firmware.bin
	openocd -f '/usr/share/openocd/scripts/interface/jlink.cfg' \
			-c 'transport select swd' \
		    -f '/usr/share/openocd/scripts/target/stm32f4x.cfg' \
			-c "program firmware.bin exit 0x08000000 reset"

openocd: firmware.bin flash
	openocd -f /usr/share/openocd/scripts/interface/stlink.cfg \
		    -f /usr/share/openocd/scripts/target/stm32f4x.cfg &

debug: firmware.elf openocd
	gdb-multiarch \
		firmware.elf \
		-ex 'target extended-remote localhost:3333' \
		-ex 'monitor [target current] configure -event gdb-detach {shutdown}' # stop openocd on exit

clean:
	$(RM) firmware.*
