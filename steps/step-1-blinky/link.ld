/* ENTRY tells the linker what address to jump to when the code is system
 * powers on or is reset.
 */
ENTRY(_reset); /* _reset is defined in main.c */

MEMORY {
  flash(rx)  : ORIGIN = 0x08000000, LENGTH = 256k
  sram(rwx)  : ORIGIN = 0x20000000, LENGTH = 64k  /* remaining 64k in a separate address space */
}

/* _estack is the highest memory addresss in sram. The stack starts here and
 * grows down toward lower memory addresses.
 */
_estack     = ORIGIN(sram) + LENGTH(sram);

SECTIONS {
  .vectors  : { KEEP(*(.vectors)) }   > flash
  .text     : { *(.text*) }           > flash
  .rodata   : { *(.rodata*) }         > flash

  /* .data section is stored in ram
   * initialized?
   */
  .data : {
    _sdata = .;   /* .data section start */
    *(.first_data)
    *(.data SORT(.data.*))
    _edata = .;  /* .data section end */
  } > sram AT > flash
  _sidata = LOADADDR(.data);

  /* .bss section is stored in ram.
   * Values are initialized to zero. This saves space when initializing
   * large swaths of memory. good stuff
   */
  .bss : {
    _sbss = .;              /* .bss section start */
    *(.bss SORT(.bss.*) COMMON)
    _ebss = .;              /* .bss section end */
  } > sram

  . = ALIGN(8);
  _end = .;     /* for cmsis_gcc.h  */
}
