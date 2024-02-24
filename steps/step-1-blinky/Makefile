#
# Source Files
#
SOURCES = main.c

#
# Compiler Flags
#
CFLAGS  ?=  -W -Wall -Wextra -Werror -Wundef -Wshadow -Wdouble-promotion \
            -Wformat-truncation -fno-common -Wconversion \
            -g3 -Os -ffunction-sections -fdata-sections -I. \
            -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 $(EXTRA_CFLAGS)

#
# Linker Flags
#
LDFLAGS ?= -Tlink.ld -nostartfiles -nostdlib --specs nano.specs \
		   -lc -lgcc -Wl,--gc-sections -Wl,-Map=$@.map

#
# Operating System Checks
#
ifeq ($(OS),Windows_NT)
  RM = cmd /C del /Q /F
else
  RM = rm -f
endif

#
# Things that make can do with thie Makefile
#

build: firmware.bin

firmware.elf: $(SOURCES) link.ld
	@echo ' '
	@echo "Compiling from source files..."
	arm-none-eabi-gcc $(SOURCES) $(CFLAGS) $(LDFLAGS) -o $@

firmware.bin: firmware.elf
	@echo ' '
	@echo "Converting ELF to BIN..."
	arm-none-eabi-objcopy -O binary $< $@

flash-stlink: firmware.bin
	@echo ' '
	@echo "Flashing firmware.bin via stlink..."
	openocd \
		-f interface/stlink.cfg \
		-c "transport select hla_swd" \
		-f target/stm32f4x.cfg  \
		-c "adapter speed 1800" \
		-c "program firmware.bin exit 0x08000000 reset" 

# Black Magic Probe debug target: ttyACM0
# Black Magic Probe serial port: ttyACM1
flash-bmp: firmware.bin
	@echo ' '
	gdb-multiarch \
		-ex 'target extended-remote /dev/ttyACM0' \
		-ex 'monitor swdp_scan' \
		-ex 'attach 1' \
		-ex 'load firmware.bin' \
		-ex 'exit'

flash-jlink: firmware.bin
	@echo ' '
	@echo "Flashing firmware.bin via J-Link..."
	openocd \
		-f '/usr/share/openocd/scripts/interface/jlink.cfg' \
		-c 'transport select swd' \
	    -f '/usr/share/openocd/scripts/target/stm32f4x.cfg' \
		-c "program firmware.bin exit 0x08000000 reset"

openocd: firmware.bin flash-stlink
	@echo ' '
	@echo "Starting openocd via stlink..."
	openocd \
		-f /usr/share/openocd/scripts/interface/stlink.cfg \
	    -f /usr/share/openocd/scripts/target/stm32f4x.cfg &

openocd-jlink: firmware.bin flash-jlink
	@echo ' '
	@echo "Starting openocd via J-Link..."
	openocd \
		-f /usr/share/openocd/scripts/interface/jlink.cfg \
		-c 'transport select swd' \
	    -f /usr/share/openocd/scripts/target/stm32f4x.cfg \
		-c "adapter speed 12000" &

debug-stlink: firmware.elf openocd
	@echo ' '
	@echo "Starting debug via openocd..."
	gdb-multiarch \
		firmware.elf \
		-ex 'target extended-remote localhost:3333' \
		-ex 'set confirm off' \
		-ex 'tui new-layout foo regs 20 asm 20 src 30 cmd 3 status 3' \
		-ex 'layout foo' \
		-ex 'tui disable' \
		-ex 'monitor [target current] configure -event gdb-detach {shutdown}' # stop openocd on exit

debug-jlink: firmware.elf openocd-jlink
	@echo ' '
	@echo "Starting debug via openocd..."
	gdb-multiarch \
		firmware.elf \
		-ex 'target extended-remote localhost:3333' \
		-ex 'set confirm off' \
		-ex 'tui new-layout foo regs 20 asm 20 src 30 cmd 3 status 3' \
		-ex 'layout foo' \
		-ex 'winheight regs 11' \
		-ex 'winheight cmd 8' \
		-ex 'tui disable' \
		-ex 'monitor [target current] configure -event gdb-detach {shutdown}' # stop openocd on exit

debug: debug-jlink
#debug: debug-stlink

flash: flash-jlink

clean:
	@echo ' '
	$(RM) firmware.*

# command to compile and load stm32f103:
# openocd \
	# -f /usr/share/openocd/scripts/interface/jlink.cfg \
	# -c "transport select swd" \
	# -f /usr/share/openocd/scripts/target/stm32f1x.cfg \
	# -c "program bluepill.elf verify reset exit"


 # command to debug
 # openocd \
	 #  -f /usr/share/openocd/scripts/interface/jlink.cfg \
	 #  -c "transport select swd" \
	 #  -f /usr/share/openocd/scripts/target/stm32f1x.cfg \
	 #  -c "program bluepill.elf verify reset"


