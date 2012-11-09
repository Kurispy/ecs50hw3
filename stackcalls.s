	.file	"stackcalls.c"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	andl	$-16, %esp
	subl	$32, %esp
	call	initstack
	movl	$9, (%esp)
	call	pushstack
	movl	24(%esp), %eax
	movl	%eax, (%esp)
	call	popstack
	movl	%eax, 28(%esp)
	movl	$5, (%esp)
	call	pushstack
	call	swapstack
	movl	$2, (%esp)
	call	printstack
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3"
	.section	.note.GNU-stack,"",@progbits
