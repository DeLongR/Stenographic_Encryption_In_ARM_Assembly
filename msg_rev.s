@ vim:ft=armv8

	.arch  armv8-a
	.fpu   neon-fp-armv8
	.cpu   cortex-a53
	.syntax unified
	.global main

	.text

/* Function Convert Image */
/* Opens Image Memory Buffer and Converts Each Byte Field to Number */
/* Parameter: r0 is set to the memory buffer of image */ 
/* Return: r0 memory buffer of new image values */
/* Return: r1 memory sizes */
convertImage:
	stmfd 	sp!, {r4,r5,r6,r7,r8,r9,r10,lr}

	mov	r6, r0			/* Store Image Memory Buffer */
	ldr	r7, =maxSize		/* Store Number of Bytes */
	ldr	r7, [r7]	
	mov	r8, #0			/* Local Store for Byte Size */
	mov	r9, #-1			/* Itterator Image Files */
	mov	r10, #0			/* Itterator for Store New Image */
	/* Malloc Memory for Bytes */
	mov	r0, r7			/* Get size */
	bl	malloc	
	
	mov	r5, r0			/* Store New Memory */
	mov	r1, #1			/* Multiplier */
	mov	r3, #10			/* Constant for Multiplication */
convertLoop:	
	/* Iterate Image Counter */
	add	r9, r9, #1

	/* Load First Byte */
	ldrb	r0, [r6, r9]		/* Load Byte of Memory */
	cmp	r0, #32			/* Compare with Space if not space move on */
	beq	convertNum
	cmp	r0, #10			/* Compare with New Line if not new line move onn*/
	beq	convertNum

	sub	r0, r0, #48		/* Convert Ascci */
	
	mul	r8, r8, r1		/* Muliply based on place */
	
	add	r8, r8, r0		/* Add To Total */

	mul	r1, r1, r3		/* Multiply by ten */
	b	convertLoop
convertNum:
	/* If nothing has been read yet jump back */
	cmp	r8, #0			/* Cmp to negative 0 */
	beq	convertLoop

	strb	r8, [r5, r10]		/* Store new word to memory */
	add	r10, r10, #1		/* Move itterator */
	mov	r8, #0			/* Set R8 back to zero */
	mov	r1, #1			/* Set muliplier back to one */
	cmp	r9, r7			/*Compare to Max Size */
	bgt	convertEnd
	b	convertLoop
	
convertEnd:
	/* Return New Memory */
	mov	r0, r5
	
	/* Return Memory Number Count */
	mov	r1, r10

	ldmfd 	sp!, {r4,r5,r6,r7,r8,r9,r10,lr}
	mov  	pc, lr

/* Function Convert Back to Image */
/* Opens Converted Image Memory Buffer and Converts Each Byte Field to Number */
/* Parameter: r0 is set to the memory of the converted image */ 
/* Return: r0 memory buffer of new image values */
convertBack:
	stmfd 	sp!, {r4,r5,r6,r7,r8,r9,r10,lr}

	mov	r5, r0			/* Store Converted Image Memory Buffer */
	mov	r6, r1			/* Store Converted Image Memory Buffer Size */
	ldr	r7, =maxSize		/* Store Number of Bytes */
	ldr	r7, [r7]	
	mov	r8, #0			/* Local Store for Byte Size */
	mov	r9, #-1			/* Itterator for Store Converted Image */
	mov	r10, #0			/* Itterator for Store New Imagee */

	/* Malloc Memory for Bytes */
	mov	r0, r7			/* Get size */
	bl	malloc	
	
	mov	r7, r0			/* Store New Memory */

	/* Store two new lines */
	mov 	r1, #10
	strb	r1, [r7, r10]
	add	r10, r10, #1
	strb	r1, [r7, r10]
	add	r10, r10, #1

backLoop:	
	/* Store two Spaces */
	mov 	r1, #32
	strb	r1, [r7, r10]
	add	r10, r10, #1
	strb	r1, [r7, r10]
	add	r10, r10, #1

	/* Iterate Image Counter */
	add	r9, r9, #1

	/* Load First Byte */
	ldrb	r0, [r5, r9]		/* Load Byte of Memory */
	mov	r2, #10
	cmp	r0, r2		/* Compare to One Hundred */
@	blt	tens
@	ldr	r2, =0x5C28F5C3
@	umull	r1, r2, r0, r1
@	mov	r0, r2, lsr #6
	mov	r0, r1	

	bl 	div
	mov	r1, r2			/* move remaineder */
	mov	r0, r1			/* move quotient */		
	add	r1, r1, #48		/* Convert back to ascii */
	str	r1, [r7, r10]		/* Store */
	add	r10, r10, #1

@ tens:
@	cmp	r0, #10
@	blt	ones
@	mov	r1, r0, lsl #2		/* Left shift it by two */
@	add	r1, r1, #48		/* Convert back to ascii */
@	str	r1, [r7, r10]		/* Store */
@	add	r10, r10, #1

@ones:
@	mov	r1, r0, lsl #2		/* Left shift it by two */
@	add	r1, r1, #48		/* Convert back to ascii */
@	str	r1, [r7, r10]		/* Store */
@	add	r10, r10, #1
@	cmp	r0, #10			/* Compare to Ten */
@	cmp	r0, #10			/* Compare with New Line if not new line move onn*/

	/* Return New Memory */
	mov	r0, r7

	ldmfd 	sp!, {r4,r5,r6,r7,r8,r9,r10,lr}
	mov  	pc, lr


/* Function Insert Secret Messagee */
/* Opens file stores headers and memory buffery */
/* Parameter: r0 is set to the memory buffer of image */ 
/* Parameter: r1 is set to the memory buffer of text file */
/* Return: r0 memory bugger of image */
insertMessage:
	stmfd 	sp!, {r4,r5,r6,r7,r8,r9,lr}

	mov	r6, r0			/* Store Image Memory Buffer */
	mov  	r7, r1			/* Store Memory Buffer of Text */
	mov	r8, #3			/* Load 0011 Mask */
	ldr	r9, =maskTwoDigit	/* Load 11111100 or 0xFFFC Mask */
	ldr	r9, [r9]
	mov	r10, #0			/* Itterator Image File */
	mov	r5, #0			/* Itterator Text File */

	/* Store Key Value to Image Memory */
	ldr 	r2, =keyValue
	ldr	r2, [r2]		/* Load Key Value */	

keyLoop:	
	/* Load First Byte */
	ldr	r0, [r6, r10]		/* Load Byte of Memory */
	cmp	r0, #32			/* Compare with Space if not space move on */
	bne	keySkip
	cmp	r0, #10			/* Compare with New Line if not new line move onn*/
	bne	keySkip

	/* If a new line is found go back one byte and load that byte */
	/* If the last line was a new line is there move on */
	sub	r1, r10, #1		/* Move back one byte */
	ldrb 	r0, [r6, r1]		
	/* If the last byte was a new line or space move on */ 
	cmp	r0, #32
	beq	keySkip
	cmp	r0, #10
	beq	keySkip

	/* Split Key Value Lower */
	orr	r3, r2, r9		/* And Key Value with Lower Bit Mask */
		
	/* Alter last two significant digits of number pulled */
	orr	r0, r0, r8		/* Or Bit Mask wiht 0011 */
	
	
	and	r0, r0, r3		/* And Bit Mask with Key Value Lower */	

	/* Store First Byte */
	strb	r0, [r6, r10]		/* Store Byte Back into Memory */

	/* Split Key Value Upper */
	mov	r2, r2, lsr #2 		/* Right Shift by 2 Key Value  */

	/* Itterate Text */
	add	r5, r5, #1	
keySkip:
	/* Itterate Image First Byte by Two Two always just to least significant digit */
	add	r10, r10, #1	
	cmp	r5, #4
	blt	keyLoop
	
	/* Return Image Memory */
	mov	r0, r6

	ldmfd 	sp!, {r4,r5,r6,r7,r8,r9,lr}
	mov  	pc, lr


/* Function Write Image */
/* Opens file stores headers and memory buffery */
/* Parameter: r0 is set to the new image file */ 
/* Parameter: r1 is set to the memory buffer */
/* Return: none */
writeImage:
	stmfd 	sp!, {r4,r5,r6,r7,lr}

	mov  	r7, r1		/* Store Memory Buffer */
	
	/* Open File */
	ldr  	r1, =wmode
	bl   	fopen
	
	mov  	r4, r0		/* Store File Pointer to Memory */

	/* Print Code to File */
	ldr  	r1, =outfmtS
	ldr  	r2, =code
	bl   	fprintf
	
	/* Read in Width and Height */
	mov  	r0, r4		/* Reload File Pointer Address */
	ldr  	r1, =outfmtInt2
	ldr  	r2, =width
	ldr  	r2, [r2]
	ldr  	r3, =height
	ldr  	r3, [r3]
	bl   	fprintf

	/* Read in Max Value Type */
	mov  	r0, r4		/* Reload File Pointer Address */
	ldr  	r1, =outfmtInt
	ldr  	r2, =maxval
	ldr  	r2, [r2]
	bl   	fprintf
	
	/* Load Allocated Size */
	/* TODO: Load size */
	ldr  	r2, =width
	ldr  	r2, [r2]
	ldr  	r3, =height
	ldr  	r3, [r3]
	mul  	r6, r2, r3

	/* Write Memory Buffer Out to File */
	mov  	r0, r7		/* Reload Memory Buffer */
	mov  	r1, #1		/* Size of */
	mov 	r2, r6		/* Specify Size */
	mov  	r3, r4		/* Reload File Pointer Address */
	bl   	fwrite

	/* Close New File */
	mov  	r0, r4
	bl   	fclose

	ldmfd 	sp!, {r4,r5,r6,r7,lr}
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

	/* Multiply by 8 for Byte Size */
@	mov	r1, #4
@	mul	r6, r6, r1

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
	
/* Function Encrpyt Characters Array */
/* Sets random number based on time y */
/* Parmeter: r0 is set to the memory pointery */ 
/* Paramter: No other paramters set */
encryptText:
	stmfd sp!, {r4,r5,r6,r7,r8,lr}

	mov	r4, r0		/* Store Memory Pointer */
	ldr	r5, =msgLength	/* Load Secret Msg Length */
	ldr	r5, [r5]
	ldr	r6, =mask	/* Load bit mask */
	ldr	r6, [r6]

	/* Calculate Random Number */
	mov	r0, #0
	bl	time		/* Get time */
	bl	srand		/* Seed random number generator with time */
	
	bl	rand		/* Generate random number */
	ands	r7, r0, r6	/* Store value of bit mask and rand */	

	/* Store Encryption Key */
	ldr	r8, =keyValue
	str	r7, [r8]	

	mov	r1, #0		/* Iterator for Counting Bytes Transformed */
	mov 	r0, r4		/* Move memory address */
encryptLoop:
	ldrb	r3, [r0, r1]	/* Load char value from memory buffery */ 
	add	r3, r3, r7	/* Add random value to number pulled from memory */
	cmp	r3, r6 		/* Compare value to 127 if gt subtract */ 
	subge	r3, r3, r6	

	strb	r3, [r0, r1]	/* Store back into memoryy */

  	add	r1, r1, #1	/* Iterate counter */
	cmp	r1, r5		/* Compare to size of char array */ 
	blt	encryptLoop
encryptEnd:
	
	ldmfd sp!, {r4,r5,r6,r7,r8,lr}
	mov  pc, lr

/* Function Read Secret Text to Memory */
/* Opens file, reads contents and stores them to a memory buffery */
/* Parmeter: r0 is set to the text file name */ 
/* Paramter: No other paramters set */
/* Return: r0 memory pointerd */
readSecret:
	stmfd sp!, {r4,r5,r6,r7,lr}
	/* r5 memory pointer */
	/* r6 file pointer */
	/* r7 file size */

	/* Set ReadMode Open File */
	ldr	r1, =rmode  
	bl	fopen

	mov	r6, r0		/* Save file pointer for later use */
	
	/* Call lseek to find end of File */
	mov	r0, r6		/* Set File Pointer */
	mov	r1, #0		/* Set off Set */	
	mov	r2, #2		/* Two Equal End of File */
	bl	fseek		/* Fseek to end of file */

	/* Call ftell to get position */
	mov	r0, r6		/* Set File Pointer */
	bl	ftell

	mov	r7, r0		/* Save file size to register */
	ldr	r1, =msgLength	/* Store file size to Data */
	str	r0, [r1]	
	/* TODO if two big quit */

	/* Return position to top of file */
	mov	r0, r6
	bl	rewind

	/* Allocate Memory */
	mov  	r0, r7
	bl   	malloc

	mov  	r5, r0		/* Store Memory Pointer */

	/* Perform Read to Allocated Memory */
	mov	r0, r5		/* Set Memory Pointer */
	mov  	r1, #1		
	mov  	r2, r7		/* Pass Size */
	mov  	r3, r6		/* Restore File Pointer */
	bl   	fread
	
	mov	r0, r6
	bl	fclose		/* Close file */

	/* Return Memory Pointer */
	mov	r0, r5

	ldmfd sp!, {r4,r5,r6,r7,lr}
	mov  pc, lr

/* Main Program Call */
main:
	/* r7 Image Read Memory */
	/* r6 Text Read Memory */

	/* Print Image File Name */
	ldr	r0, =outfmtImageFN	
	ldr	r1, =imageFile
	bl	printf	

	/* Print Secret Text File Name */
	ldr	r0, =outfmtSecretFN	
	ldr	r1, =textFile
	bl	printf	

	/* Print Secret Image File Name */
	ldr	r0, =outfmtSecretFN	
	ldr	r1, =secretImage
	bl	printf	

	/* Load Image */
	ldr	r0, =imageFile
	bl	readImage
	mov	r7, r0			/* Store Allocated memory */

	/* Load Text File and Encrypt Text */
	ldr	r0, =textFile
	bl	readSecret
	mov	r6, r0			/* Store Text Memory */

	/* Encrypt Text */
	mov	r0, r6			/* Restore Text Memory */
	bl	encryptText	

	/* Convert Imagey */
	mov	r0, r7			/* Image Memory */
	bl	convertImage		/* Convert Image Memory to Words */
	mov	r5, r0			/* Store Converted Image Memory */
	mov	r4, r1			/* Store number of bytes converted */

	/* TODO add encrypted text */

	/* Convert back to image memory */
	mov	r0, r5			/* Get new allocated image memory */
	mov	r1, r4			/* Pass count */
	bl	convertBack


	/* Create New Image */
	ldr	r0, =secretImage	/* Load Secret Image File */
	mov	r1, r7			/* Load Allocated Memory */ 
	bl	writeImage	

	/* Free Converted Image */
	mov	r0, r5	
	bl	free

	/* Free Image Memory */
	mov	r0, r7
	bl	free

	/* Free Text Memory */
	mov	r0, r6
	bl	free

	/* Print Image to Screen */
	ldr	r0, =syscomm
	bl	system	 

	/* Finish Execution */
	mov	r0, #0
	mov	r7, #1
	svc	#0

.data

/* System Message */
syscomm:   	.asciz  "gpicview pepper_secret.pgm"

/*************************** Constants ***** **********************/
/* Original Image File */
imageFile:	.asciz	"pepper.pgm"

/* Secret Message Text File */
textFile:	.asciz	"secret.txt"

/* Bit Mask to 127 */
mask:		.word 0x0000007f

/* Bit mask for last two digits of Word */
maskTwoDigit:	.word 0xFFFC

/* Image with Secret Message */
secretImage:	.asciz	"pepper_secret.pgm"

/********************* In and Out Formats **********************/
/* Output Format for Image File Name */
outfmtImageFN:		.asciz	"Image File Name: %s \n"

/* Output Format for Secret Text File Name */
outfmtSecretFN:		.asciz	"Secret Text File Name: %s \n"

/* Output Format for Secret Text File Name */
outfmtSecretImageFN:	.asciz	"Secret Image File Name: %s \n"

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
/* TODO Char to Retrieve */
debugNum:	.word 0

/* TODO Char Array */
charArray:	.space 1000

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

/* Perhaps Unneeded */
alpha:
	.float 0.5
notalpha:
	.float 1.0
alphainc:
	.float 0.1

flushy:
	.asciz  "\n"


