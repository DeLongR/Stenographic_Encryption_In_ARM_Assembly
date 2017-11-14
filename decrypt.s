@ vim:ft=arm

	.arch  armv8-a
	.fpu   neon-fp-armv8
	.cpu   cortex-a53
	.syntax unified
	.global main

	.text

/* Function Read Secret Messages */
/* Opens Reads Secret Message from Image */
/* Parameter: r0 is set to the memory buffer of image */
/* Return: r0 memory buffer of text */
getMessage:
	stmfd 	sp!, {r4,r5,r6,r7,r8,r9,lr}

	mov	r4, r0			/* Store Image Memory Buffer */
	mov	r5, #0			/* Itterator Image File */
	mov	r7, #0			/* Storage Memory Address of Text File */

	/* Parameter: r0 is set to the memory */
	/* Parameter: r1 is set to the current itterator value */
	mov	r0, r4			/* Image Memory Buffer */
	mov	r1, r5			/* Itterator Image File */
	bl	readByte		

	ldr 	r2, =keyValue
	strb	r0, [r2]		/* Store Key Value */
	mov	r5, r1			/* Store Itterator */ 	

	/* Parameter: r0 is set to the memory */
	/* Parameter: r1 is set to the current itterator value */
	mov	r0, r4			/* Image Memory Buffer */
	mov	r1, r5			/* Itterator Image File */
	bl	readByte		

	mov	r6, r0			/* Store Message Length */
	ldr 	r2, =msgLength
	strb	r0, [r2]		/* Store Message Length */
	mov	r5, r1			/* Store Itterator */ 	

	/* Based on Msg Length */
	mov  	r0, r6		/* Retieve Memory Length */
	bl   	malloc
	mov  	r7, r0		/* Store Memory Pointer */

/* Read Message From Outer Loop */
	/* Retrieve Msg Length  */
	mov	r9, #0			/* Msg Length Counter */

outmLoop:
	/* Parameter: r0 is set to the memory */
	/* Parameter: r1 is set to the current itterator value */
	mov	r0, r4			/* Image Memory Buffer */
	mov	r1, r5			/* Itterator Image File */
	bl	readByte		

	mov	r5, r1			/* Store Itterator */ 	
	strb	r0, [r7, r9]		/* Store Message to Memory */
		
	add	r9, r9, #1		/* Increment outer loop */
	cmp	r9, r6			/* Compare Incrementor vs. Msg Length */
	ble	outmLoop
	
	/* Return Text Memory */
	mov	r0, r7	

	ldmfd 	sp!, {r4,r5,r6,r7,r8,r9,lr}
	mov  	pc, lr

/* Read Message Byte by Byte */
/* Parameter: r0 is set to the memory */
/* Parameter: r1 is set to the current itterator value */
/* Return: r0 value calutated */
/* Return: r1 byte itterator */
readByte:
	stmfd 	sp!, {r4,r5,r6,lr}

	mov	r2, r0			/* Storage Memory Address of Image File */
	mov	r3, #0			/* Multiplier */
	mov	r4, #0			/* Byte Itterator */
	mov 	r5, #0			/* Byte Mask */
	mov	r6, #0			/* Value Holder */
bLoop:	
	/* Load First Byte */
	ldrb	r0, [r2, r1]		/* Load Byte of Memory */
	cmp	r0, #32			/* Compare with Space if not space move on */
	beq	bSkip
	cmp	r0, #10			/* Compare with New Line if not new line move on*/
	beq	bSkip

	/* Isolate Relevant Bits */
	mov	r5, #3
	and	r0, r0, r5		/* And Image Byte with Bit Mask 00000011 */
	
	/* Left Shift The r0 by the size of the itterator times 2 */
	mov	r5, #2
	mul	r5, r4, r5
	mov	r0, r0, lsl r5
	
	/* Pass the The Least two significant digits of stored number  */
	orr	r6, r6, r0		/* Or Bit Mask with Relevant Bits **/

	/* Itterate Text */
	add	r4, r4, #1
bSkip:
	/* Itterate Image First Byte by Two Two always just to least significant digit */
	add	r1, r1, #1	
	cmp	r4, #4			/* Check for four byte end */
	blt	bLoop

	/* Return r0 and r1 */
	mov	r0, r6			/* Returned Value */
	
	ldmfd 	sp!, {r4,r5,r6,lr}
	mov  	pc, lr

/* Function Read Image */
/* Opens file, reads contents and stores them to a memory buffery */
/* Parmeter: r0 is set to the image file */ 
/* Return: r0 is set to the memory allocated */
readImage:
	stmfd 	sp!, {r4,r5,r6,r7,lr}

	/* Open File */
	ldr	r1, =rmode  
	bl	fopen

	/* Read in Code */
	mov  	r4, r0		/* Store file Pointer */

	ldr  	r1, =infmtS
	ldr  	r2, =code
	bl   	fscanf
	
	/* Read in Width and Height */
	mov  	r0, r4
	ldr  	r1, =infmtInt2
	ldr  	r2, =width
	ldr  	r3, =height
	bl   	fscanf

	/* Read In Max Value Type */
	mov  	r0, r4
	ldr  	r1, =infmtInt
	ldr  	r2, =maxval
	bl   	fscanf
	
	/* Use Width and Height to Calculate Max Height */
	ldr  	r2, =width
	ldr  	r2, [r2]
	ldr  	r3, =height
	ldr  	r3, [r3]
	mul  	r6, r2, r3

	/* Store Max Size */
	ldr	r7, =maxSize
	str	r6, [r7]

	/* Based on Max Size Allocate Memory */
	mov  	r0, r6
	bl   	malloc

	mov  	r5, r0		/* Store Memory Pointer */

	/* Perform Read to Allocated Memory */
	mov  	r1, #1		
	mov  	r2, r6		/* Pass Size */
	mov  	r3, r4		/* Restore File Pointer */
	bl   	fread

	/* Close File */
	mov  	r0, r4
	bl   	fclose

	mov  	r0, r5		/* Return allocated memory */

	ldmfd 	sp!, {r4,r5,r6,r7,lr}
	mov  	pc, lr
	
/* Print Secret Message Function */
/* Opens memory pointer, reads contents and writes them to file */
/* Parmeter: r0 is set to the text file name */ 
/* Paramter: r1 is set to the memory pointer of the secret text */
/* Return: no return */
printSecret:
	stmfd sp!, {r4,r5,r6,r7,r8,lr}
	mov	r8, r0			/* Store Text Pointer */
	mov	r6, r1			/* Move Secret Message Memory Address */
	mov	r4, #0			/* Itterator for Moving Through Text File */
	ldr 	r5, =msgLength		/* Length of Message */
	ldr	r5, [r5]
	ldr	r7, =keyValue		/* Key Value */
	ldr	r7, [r7]

	/* Open File */
	mov	r0, r8
	ldr  	r1, =wmode
	bl   	fopen
	
	mov  	r8, r0			/* Store File Pointer to Memory */

	/* Print Key Value */
	mov	r0, r8
	ldr	r1, =outfmtKey
	mov	r2, r7			/* Print Key Value */
	bl   	fprintf

	/* Print Message Lengthe */
	mov	r0, r8
	ldr	r1, =outfmtLength
	mov	r2, r5			/*Print Message Length */
	bl	fprintf

	/* Remove Secret Message from Message */
psLoop:
	mov	r0, r8
	ldr	r1, =outfmtChar
	ldrb	r2, [r6, r4]
	subs	r2, r2, r7	
	cmp	r2, #0
	addlt	r2, r2, #127	
	bl	fprintf
		
	add	r4, r4, #1
	cmp	r4, r5
	blt	psLoop	
	/* Finish Secret Message */

	/* Close New File */
	mov  	r0, r8
	bl   	fclose

	ldmfd 	sp!, {r4,r5,r6,r7,r8,lr}
	mov  	pc, lr

/* Main Program Call */
main:
	/* r8 Secret Message Memory */
	/* Print Secret Image File Name */
	ldr	r0, =outfmtSecretImageFN	
	ldr	r1, =secretImage
	bl	printf	

	/* Load Secret Image */
	ldr	r0, =secretImage
	bl	readImage
	mov	r7, r0			/* Store Allocated memory */
	
	/* Retrieve Secret Message */
	mov	r0, r7
	bl	getMessage
	mov	r8, r0			/* Store Secret Message Memory */

	/* Print Secret Message */
	ldr	r0, =stegoText
	mov	r1, r8			/* Restore Secret Message Memory */
	bl	printSecret

	/* Free Secret Text Memory */
	mov	r0, r8
	bl	free
	
	/* Free Image Memory */
	mov	r0, r7
	bl	free

	/* Print Secret Image File Name */
	ldr	r0, =outfmtSecretFN	
	ldr	r1, =stegoText
	bl	printf

	/* Finish Execution */
	mov	r0, #0
	mov	r7, #1
	svc	#0

.data

/*************************** Constants ***** **********************/
/* Bit Mask to 127 */
mask:		.word 0x0000007f

/* Bit mask for last two digits of Word */
maskTwoDigit:	.word 0xFFFC

/* Image with Secret Message */
secretImage:	.asciz	"secret.pgm"

/* Stego Message */
stegoText:	.asciz "stego.txt"

/********************* In and Out Formats **********************/
/* Output Format for Image File Name */
outfmtImageFN:		.asciz	"Image File Name: %s \n"

/* Output Format for Secret Text File Name */
outfmtSecretFN:		.asciz	"Secret Text File Name: %s \n"

/* Output Format for Secret Text File Name */
outfmtSecretImageFN:	.asciz	"Secret Image File Name: %s \n"

/* Format for Printing Out Key Value */
outfmtKey:		.asciz	"Key Value equals %i\n"

/* Format for Printing Out Output Length */
outfmtLength:		.asciz	"Secret Message Length %i\n"

/* Format for Printing Out Characters */
outfmtChar:		.asciz	"%c"

/* Error Message for End of File */
e_errorMsg:		.asciz	"Encryption: Error message \n"	

/* Format for Reading Characters */
infmtC:			.asciz	"%c"

/* Format for Printing Out Characters */
outfmtC:		.asciz	"%c\n"

/* Format for Reading String */
infmtS:			.asciz "%s"

/* Format for Printing Out Strings */
outfmtS:		.asciz	"%s\n"

/* Format for Reading in Integer */
infmtInt:		.asciz	"%i"

/* Format for Reading in Two Integers */
infmtInt2:		.asciz	"%i %i"

/* Format for Printing Out Integer */
outfmtInt:		.asciz	"%i\n"

/* Format for Print Out Two Integers */
outfmtInt2:		.asciz	"%i %i\n"

/********************* Read and Write Modes **********************/
/* Read Mode Format */
rmode:		.asciz  "rb"

/* Write Mode */
wmode:		.asciz  "wb"

/********************* Values to Stores **********************/
/* Length of Message */
msgLength:	.word 0

/* Key Value for Cipher */
keyValue:	.word 0

/* Image File Width */
width:		.word 0

/* Image File Height */
height: 	.word 0

/* Maximum size of PGM Format */
maxval:		.word 0

/* Maximum Size of Bytes */
maxSize:	.word 0

/* Code for Storing Initial PGM File Parameters */
code:		.space 3
		.align 2

