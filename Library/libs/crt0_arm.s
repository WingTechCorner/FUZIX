.section ".header"
.globl _start
_start:
	.ascii "bFAR"
	.word 4                   // rev
	.word 1f - _start         // entrypoint
	.word __data_start - _start
	.word __data_end - _start
	.word __bss_end - _start
	.word __heap_size         // stack_size; also heap
	.word __data_end - _start // reloc_start (also, amount to load off disk)
	.word 0                   // reloc_count
	.word 0x1                 // flags (load in RAM)
	.word 0, 0, 0, 0, 0, 0    // filler

1:
	/* Stack adjustment. For some reason Fuzix has two quads worth of dummy
	 * values here (m68k stack frame, maybe?). */

	add sp, sp, #8

	/* Our argv, envp etc are on the stack; but we need to align the stack
	 * (the kernel doesn't do this for us). */
	
	mov r4, sp
	bic sp, sp, #7

	/* Wipe BSS.*/

	ldr r0, =__bss_start
	mov r1, #0
	ldr r2, =__bss_end
	sub r2, r2, r0
	bl memset

	/* Initialise stdio. */

	bl __stdio_init_vars

	/* Pull argc and argv off the old stack pointer. */

	ldmfd r4!, {r0, r1}

	/* What's left on the stack is the environment. */

	mov r2, r4
	ldr r3, =environ
	str r2, [r3]

	/* When main returns, jump to _exit. */

	ldr lr, =exit
	b main
	
.globl environ
.comm environ, 4


