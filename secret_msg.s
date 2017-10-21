	.arch  armv8-a
	.fpu   neon-fp-armv8
	.cpu   cortex-a53
	.syntax unified
	.global main

	.text

readimage:
	stmfd sp!, {r4,r5,r6,lr}

	ldr  r1, =rmode
	bl   fopen
	mov  r4, r0

	ldr  r1, =infmt1
	ldr  r2, =code
	bl   fscanf
	
	mov  r0, r4
	ldr  r1, =infmt2
	ldr  r2, =width
	ldr  r3, =height
	bl   fscanf

	mov  r0, r4
	ldr  r1, =infmt3
	ldr  r2, =maxval
	bl   fscanf

	ldr  r2, =width
	ldr  r2, [r2]
	ldr  r3, =height
	ldr  r3, [r3]
	mul  r6, r2, r3

	mov  r0, r6
	bl   malloc

	mov  r5, r0
	mov  r1, #1
	mov  r2, r6
	mov  r3, r4
	bl   fread

	mov  r0, r4
	bl   fclose

	mov  r0, r5

	ldmfd sp!, {r4,r5,r6,lr}
	mov  pc, lr
	
writeimage:
	stmfd sp!, {r4,r5,r6,r7,lr}

	mov  r7, r1
	ldr  r1, =wmode
	bl   fopen
	mov  r4, r0

	ldr  r1, =outfmt1
	ldr  r2, =code
	bl   fprintf
	
	mov  r0, r4
	ldr  r1, =outfmt2
	ldr  r2, =width
	ldr  r2, [r2]
	ldr  r3, =height
	ldr  r3, [r3]
	bl   fprintf

	mov  r0, r4
	ldr  r1, =outfmt3
	ldr  r2, =maxval
	ldr  r2, [r2]
	bl   fprintf

	ldr  r2, =width
	ldr  r2, [r2]
	ldr  r3, =height
	ldr  r3, [r3]
	mul  r6, r2, r3

	mov  r0, r7
	mov  r1, #1
	mov  r2, r6
	mov  r3, r4
	bl   fwrite

	mov  r0, r4
	bl   fclose

	ldmfd sp!, {r4,r5,r6,r7,lr}
	mov  pc, lr

morphimage:
	
	stmfd sp!, {r4,r5,r6,r7,r8,r9,r10,r12,lr}

	mov  r4, r0
	mov  r5, r1

	ldr  r2, =width
	ldr  r2, [r2]
	ldr  r3, =height
	ldr  r3, [r3]
	mul  r12, r2, r3

	mov  r0, r12
	bl   malloc
	mov  r6, r0

	mov  r10, #0
	vmov s3, r10
	ldr  r9, =notalpha
	vldr s4, [r9]
	ldr  r9, =alphainc
	vldr s6, [r9]
	
imagesloop:
	ldr  r2, =width
	ldr  r2, [r2]
	ldr  r3, =height
	ldr  r3, [r3]
	mul  r12, r2, r3
	mov  r7, r12

morphloop:

	subs  r7, r7, #1
	blt  donemorph

	ldrb r8, [r4, r7]
	vmov s1, r8
	vcvt.f32.u32  s1, s1

	ldrb r8, [r5, r7]
	vmov s2, r8
	vcvt.f32.u32  s2, s2

	vmul.f32 s1, s1, s3
	vmul.f32 s2, s2, s4
	vadd.f32 s5, s1, s2
	vcvt.u32.f32  s5, s5
	vmov r8, s5
	strb r8, [r6, r7]

	b  morphloop
donemorph:
@	ldr  r0, =file3
	mov  r1, r6
	bl   writeimage

	ldr   r0, =syscomm
	bl    system

	vadd.f32 s3, s3, s6
	vsub.f32 s4, s4, s6	
	mov   r10, #0
	vmov  s7, r10
	vcmp.f32  s4, s7
	vmrs  APSR_nzcv, FPSCR
	bge  imagesloop
	
	mov  r0, r6
	bl   free
 
	ldmfd sp!, {r4,r5,r6,r7,r8,r9,r10,r12,lr}
	mov  pc, lr


/* Encrypt Text */
encryptText:
	stmfd sp!, {lr}
	/* Load File Char Array */
	ldr  r6, =charArray

	/* Set Loop Counter */
	mov  r7, #0

	/* Open Read File */
	ldr  r0, =textFile
	ldr  r1, =rmode
	bl   fopen

	/* Store File Pointer */
	mov  r5, r0		

encryptLoop:
	mov	r0, r5		/* Load File Pointer */
	ldr	r1, =e_infmt	/* Set Encrpytion Format */	
	bl	fscanf		/* Read Stand Pointer Value */
	cmp	r0, #1
	bne	endEncrypt
	strb	r2, [r6, r7]	/* Store Value to Char Array */
	beq	encryptLoop		

endEncrypt:
	/* Check for End of File */
	mov	r0, r5
	bl	feof
	cmp	r0, #0		/* Compare for Error Message */
	ldreq	r0, =e_errorMsg	/* Error Message */
	bleq	printf

	/* Close File */
	mov  r0, r5
	bl   fclose

	ldmfd sp!, {lr}
	mov  pc, lr

/* Main Program Call */
main:
	ldr  r0, =imageFile	/* Load Image File */
	bl   readimage

	mov  r4, r0		/* Save image memory address */
	
	mov  r0, r4		/* Free image memory */
	bl   free

	/* Print Image File Name */
	ldr  r0, =outfmtImageFN	
	ldr  r1, =imageFile
	bl   printf	

	/* Print Secret Text File Name */
	ldr  r0, =outfmtSecretFN	
	ldr  r1, =textFile
	bl   printf	

	/* Print Secret Image File Name */
	ldr  r0, =outfmtSecretFN	
	ldr  r1, =secretImage
	bl   printf	

	/* Load Text File and Encrypt Text */
	ldr  r0, =textFile
	bl   encryptText

	/* Finish Execution */
	mov   r0, #0
	mov   r7, #1
	svc   #0

	.data

/* System Message */
syscomm:   
	.asciz  "gpicview marcie_secret.pgm"

/* Original Image File */
imageFile:
	.asciz	"marcie.pgm"

/* Secret Message Text File */
textFile:
	.asciz	"secret.txt"

/* Image with Secret Message */
secretImage:
	.asciz	"marcie_secret.pgm"

/* Output Format for Image File Name */
outfmtImageFN:
	.asciz	"Image File Name: %s \n"

/* Output Format for Secret Text File Name */
outfmtSecretFN:
	.asciz	"Secret Text File Name: %s \n"

/* Output Format for Secret Text File Name */
outfmtSecretImageFN:
	.asciz	"Secret Image File Name: %s \n"

/* Error Message for End of File */
e_errorMsg:
	.asciz	"Encryption: Error message \n"	

/* Encryption Input Format */
e_infmt:
	.asciz	"%c"

flushy:
	.asciz  "\n"
infmt1:
	.asciz  "%s"
infmt2:
	.asciz	"%i %i"
infmt3:
	.asciz	"%i"
outfmt1:
	.asciz  "%s\n"
outfmt2:
	.asciz	"%i %i\n"
outfmt3:
	.asciz	"%i\n"

/* Read Mode Format */
rmode:
	.asciz  "rb"

/* Store Character Array */
charArray:
	.space 120
wmode:
	.asciz  "wb"
code:
	.space 3
	.align 2
width:
	.word 0
height: 
	.word 0
maxval:
	.word 0
alpha:
	.float 0.5
notalpha:
	.float 1.0
alphainc:
	.float 0.1

