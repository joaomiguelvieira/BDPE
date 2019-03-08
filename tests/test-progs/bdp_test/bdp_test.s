	.arch armv8-a
	.file	"bdp_test.c"
	.text
	.align	2
	.global	bdp_hw
	.type	bdp_hw, %function
bdp_hw:
.LFB0:
	.cfi_startproc
	str	x19, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 19, -32
	str	x0, [sp, 24]
	str	x1, [sp, 16]
	ldr	x0, [sp, 24]
	ldr	x1, [sp, 16]
#APP
// 7 "bdp_test.c" 1
	.long 0b10000011000000010000000000000001
	cmp x1, 0x40
	b.ls 0xc
	ldr x1, [x1]
	.long 0b11000011000000010000000000000001
	mov x0, x1
	
// 0 "" 2
#NO_APP
	mov	x19, x0
	mov	x0, x19
	ldr	x19, [sp], 32
	.cfi_restore 19
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE0:
	.size	bdp_hw, .-bdp_hw
	.section	.rodata
	.align	3
.LC0:
	.string	"%d"
	.text
	.align	2
	.global	print_binary
	.type	print_binary, %function
print_binary:
.LFB1:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp
	str	x0, [sp, 24]
	str	wzr, [sp, 44]
	b	.L4
.L6:
	ldr	w0, [sp, 44]
	cmp	w0, 0
	beq	.L5
	ldr	w0, [sp, 44]
	and	w0, w0, 3
	cmp	w0, 0
	bne	.L5
	mov	w0, 32
	bl	putchar
.L5:
	ldr	x0, [sp, 24]
	lsr	x0, x0, 63
	and	w0, w0, 255
	mov	w1, w0
	adrp	x0, .LC0
	add	x0, x0, :lo12:.LC0
	bl	printf
	ldr	x0, [sp, 24]
	lsl	x0, x0, 1
	str	x0, [sp, 24]
	ldr	w0, [sp, 44]
	add	w0, w0, 1
	str	w0, [sp, 44]
.L4:
	ldr	w0, [sp, 44]
	cmp	w0, 63
	bls	.L6
	nop
	ldp	x29, x30, [sp], 48
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE1:
	.size	print_binary, .-print_binary
	.section	.rodata
	.align	3
.LC1:
	.string	"Result = %ld\n"
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB2:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	mov	x0, -15
	str	x0, [sp, 24]
	mov	x0, -14
	str	x0, [sp, 16]
	add	x0, sp, 16
	mov	x1, x0
	ldr	x0, [sp, 24]
	bl	bdp_hw
	mov	x1, x0
	adrp	x0, .LC1
	add	x0, x0, :lo12:.LC1
	bl	printf
	mov	w0, 0
	ldp	x29, x30, [sp], 32
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.ident	"GCC: (GNU Toolchain for the A-profile Architecture 8.2-2019.01 (arm-rel-8.28)) 8.2.1 20180802"
	.section	.note.GNU-stack,"",@progbits
