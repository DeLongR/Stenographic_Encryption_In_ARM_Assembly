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

	/* Store Key Value */
	ldr 	r2, =keyValue
	ldr	r2, [r2]		/*Store Key Value */

	mov	r6, r0			/* Store Image Memory Buffer */
	mov	r10, #0			/* Itterator Image File */
	mov	r7, #0			/* Multiplier */
	mov	r8, #0			/* Storage Memory Address of Text File */

	/* Create Key Value Storage */
	mov 	r2, #0			/* Key Value */
	mov	r5, #0			/* Itterator Byte */
debug1:
kLoop:	
	/* Load First Byte */
	ldrb	r0, [r6, r10]		/* Load Byte of Memory */
	cmp	r0, #32			/* Compare with Space if not space move on */
	beq	kSkip
	cmp	r0, #10			/* Compare with New Line if not new line move onn*/
	beq	kSkip

	/* Isolate Relevant Bits */
	mov	r9, #3
	and	r0, r0, r9		/* And Image Byte with Bit Mask 00000011 */
	
	/* Left Shift The r0 by the size of the itterator times 2 */
	mov	r7, #2
	mul	r7, r5, r7
	mov	r0, r0, lsl r7
	
	/* Pass the The Least two significant digits of stored number  */
	orr	r2, r2, r0		/* Or Bit Mask with Relevant Bits **/

	/* Itterate Text */
	add	r5, r5, #1
kSkip:
	/* Itterate Image First Byte by Two Two always just to least significant digit */
	add	r10, r10, #1	
	cmp	r5, #4			/* Check for four byte end */
	blt	kLoop

	/* Store Key Value */
	ldr 	r3, =keyValue
	strb	r2, [r3]		/*Store Key Value */

	/* Create Msg Size */
	mov 	r2, #0			/* Msg Lengthe */
	mov	r5, #0			/* Itterator Byte */

mLoop:	
	/* Load First Byte */
	ldrb	r0, [r6, r10]		/* Load Byte of Memory */
	cmp	r0, #32			/* Compare with Space if not space move on */
	beq	mSkip
	cmp	r0, #10			/* Compare with New Line if not new line move onn*/
	beq	mSkip

	/* Isolate Relevant Bits */
	mov	r9, #3
	and	r0, r0, r9		/* And Image Byte with Bit Mask 00000011 */
	
	/* Left Shift The r0 by the size of the itterator times 2 */
	mov	r7, #2
	mul	r7, r5, r7
	mov	r0, r0, lsl r7
	
	/* Pass the The Least two significant digits of stored number  */
	orr	r2, r2, r0		/* Or Bit Mask with Relevant Bits **/

	/* Itterate Text */
	add	r5, r5, #1
mSkip:
	/* Itterate Image First Byte by Two Two always just to least significant digit */
	add	r10, r10, #1	
	cmp	r5, #4			/* Check for four byte end */
	blt	mLoop
debug3:
	/* Store Msg Length  */
	ldr 	r3, =msgLength
	strb	r2, [r3]		/*Store Msg Length */

	/* Based on Msg Length */
	mov  	r0, r2
	bl   	malloc
	mov  	r8, r0		/* Store Memory Pointer */

/* Read Message From Outer Loop */
	/* Retrieve Msg Length  */
	ldr 	r3, =msgLength
	ldr	r4, [r3]		/*Store Msg Length */
	mov	r11, #0			/* Msg Length Counter */

outmLoop:
	/* Create Msg Size */
	mov 	r2, #0			/* Msg Lengthe */
	mov	r5, #4			/* Itterator Byte */

inmLoop:	
	/* Load First Byte */
	ldrb	r0, [r6, r10]		/* Load Byte of Memory */
	cmp	r0, #32			/* Compare with Space if not space move on */
	beq	inmSkip
	cmp	r0, #10			/* Compare with New Line if not new line move onn*/
	beq	inmSkip

	/* Isolate Relevant Bits */
	mov	r9, #3
	and	r0, r0, r9		/* And Image Byte with Bit Mask 00000011 */
	
	/* Left Shift The r0 by the size of the itterator times 2 */
	mov	r7, #2
	mul	r7, r5, r7
	mov	r0, r0, lsl r7
	
	/* Pass the The Least two significant digits of stored number  */
	orr	r2, r2, r0		/* Or Bit Mask with Relevant Bits **/

	/* Itterate Text */
	add	r5, r5, #1
inmSkip:
	/* Itterate Image First Byte by Two Two always just to least significant digit */
	add	r10, r10, #1	
	cmp	r5, #4			/* Check for four byte end */
	blt	inmLoop

	/* Store Message to Memory */
	strb	r2, [r8, r11]
		
	add	r11, r11, #1		/* Increment outer loop */
	cmp	r11, r4
	ble	outmLoop
	
	/* Return Text Memory */
	mov	r0, r8	

	ldmfd 	sp!, {r4,r5,r6,r7,r8,r9,lr}
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
	mov	r8, #0			/* Itterator Text Filek */
	mov	r9, #252		/* Store bit mask */
	mov	r10, #0			/* Itterator Image File */
	mov	r5, #0			/* Itterator Byte */

	/* Store Key Value to Image Memory */
	ldr 	r2, =keyValue
	ldr	r2, [r2]		/* Load Key Value */	
	mov	r4, #4			/* Message size in two bit increments */

keyLoop:	
	/* Load First Byte */
	ldrb	r0, [r6, r10]		/* Load Byte of Memory */
	cmp	r0, #32			/* Compare with Space if not space move on */
	beq	keySkip
	cmp	r0, #10			/* Compare with New Line if not new line move onn*/
	beq	keySkip

	/* Split Key Value Lower */
	mov	r9, #252
	orr	r3, r2, r9		/* Or Key Value with Bit Mask 11111100 */
		
	/* Alter last two significant digits of number pulled */
	mov	r9, #3
	orr	r0, r0, r9		/* Or Bit Mask with 0011 */
	
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
	cmp	r5, r4			/* Check for four byte end */
	blt	keyLoop


	/* Set Up Conditions for Message Size */
	mov	r5, #0			/* Reset R5 */
	ldr	r2, =msgLength		/* Load Message Length */
	ldr	r2, [r2]		
	mov	r4, #4			/* Message Length in two bit increments */	

lenLoop:	
	/* Load First Byte */
	ldrb	r0, [r6, r10]		/* Load Byte of Memory */
	cmp	r0, #32			/* Compare with Space if not space move on */
	beq	lenSkip
	cmp	r0, #10			/* Compare with New Line if not new line move onn*/
	beq	lenSkip

	/* Split Key Value Lower */
	mov	r9, #252
	orr	r3, r2, r9		/* Or Key Value with Bit Mask 11111100 */
		
	/* Alter last two significant digits of number pulled */
	mov	r9, #3
	orr	r0, r0, r9		/* Or Bit Mask with 0011 */
	
	and	r0, r0, r3		/* And Bit Mask with Key Value Lower */	

	/* Store First Byte */
	strb	r0, [r6, r10]		/* Store Byte Back into Memory */

	/* Split Key Value Upper */
	mov	r2, r2, lsr #2 		/* Right Shift by 2 Key Value  */

	/* Itterate Text */
	add	r5, r5, #1
lenSkip:
	/* Itterate Image First Byte by Two Two always just to least significant digit */
	add	r10, r10, #1	
	cmp	r5, r4			/* Check for four byte end */
	blt	lenLoop

debug88:
/* Outer loop for actual msg */
	ldr	r11, =msgLength		/* Load Message Length */
	ldr	r11, [r11]
	mov	r8, #0			/*Set external text loop counter */
msgOuterLoop:
	/* Set Up Conditions for Message Size */
	mov	r5, #0			/* Reset R5 */
	ldrb	r2, [r7, r8]		/* Load Text File Byte */	
	mov	r4, #4			/* Message Length in two bit increments */	
msgLoop:	
	/* Load First Byte */
	ldrb	r0, [r6, r10]		/* Load Byte of Memory */
	cmp	r0, #32			/* Compare with Space if not space move on */
	beq	msgSkip
	cmp	r0, #10			/* Compare with New Line if not new line move onn*/
	beq	msgSkip

	/* Split Key Value Lower */
	mov	r9, #252
	orr	r3, r2, r9		/* Or Key Value with Bit Mask 11111100 */
		
	/* Alter last two significant digits of number pulled */
	mov	r9, #3
	orr	r0, r0, r9		/* Or Bit Mask with 0011 */
	
	and	r0, r0, r3		/* And Bit Mask with Key Value Lower */	

	/* Store First Byte */
	strb	r0, [r6, r10]		/* Store Byte Back into Memory */

	/* Split Key Value Upper */
	mov	r2, r2, lsr #2 		/* Right Shift by 2 Key Value  */

	/* Itterate Text */
	add	r5, r5, #1
msgSkip:
	/* Itterate Image First Byte by Two Two always just to least significant digit */
	add	r10, r10, #1	
	cmp	r5, r4			/* Check for four byte end */
	blt	msgLoop

	/* Jump back to top of outer loop */
	add 	r8, r8, #1		/* Itterate text file counter */
	cmp	r8, r11
	ble	msgOuterLoop	

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

/* TODO Debug Delete for Later Use */
	mov	r7, #3	

	/* Store Encryption Key */
	ldr	r8, =keyValue
	str	r7, [r8]	

	mov	r1, #0		/* Iterator for Counting Bytes Transformed */
	mov 	r0, r4		/* Move memory address */
debug89:
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
debug90:
	/* Return Memory Pointer */
	mov	r0, r5

	ldmfd sp!, {r4,r5,r6,r7,lr}
	mov  pc, lr

/* Print Secret Message Function */
/* Opens memory pointer, reads contents and writes them to file */
/* Parmeter: r0 is set to the text file name */ 
/* Paramter: r1 is set to the memory pointer of the secret text */
/* Return: r0 memory pointerd */
printSecret:
	stmfd sp!, {r4,r5,r6,r7,lr}
	mov	r6, r1			/* Move Secret Message Memory Address */
	mov	r4, #0			/* Itterator for Moving Through Text File */
	ldr 	r5, =msgLength		/* Length of Message */
	ldr	r5, [r5]

	/* Print Key Value */
	ldr	r0, =outfmtKey
	ldr	r1, =keyValue		/* Print Key Value */
	ldr	r1, [r1]
	bl	printf

	/* Print Key Value */
	ldr	r0, =outfmtLength
	mov	r1, r5			/*Print Message Length */
	bl	printf

	/* Print Each Value in Secret Message */
psLoop:
	ldr	r0, =outfmtC
	ldrb	r1, [r6, r4]
	bl	printf
	
	add	r4, r4, #1
	cmp	r4, r5
	blt	psLoop	

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

	/* Add encrypted text */
	mov	r0, r7			/* Restore Image Memory */
	mov	r1, r6			/* Restore Text Memory */
	bl	insertMessage	

	/* Retrieve Secret Message */
	mov	r0, r7
	bl	getMessage
	mov	r8, r0			/* Store Secret Message Memory */

	/* TODO Decode Secret Message */

	/* Print Secret Message */
	mov	r1, r8			/* Restore Secret Message Memory */
	bl	printSecret

	/* Create New Image */
	ldr	r0, =secretImage	/* Load Secret Image File */
	mov	r1, r7			/* Load Allocated Memory */ 
	bl	writeImage	

	/* Free Image Memory */
	mov	r0, r7
	bl	free

	/* Free Text Memory */
	mov	r0, r6
	bl	free

	/* Free Secret Text Memory */
	mov	r0, r8
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
syscomm:   	.asciz  "gpicview columns_secret.pgm"

/*************************** Constants ***** **********************/
/* Original Image File */
imageFile:	.asciz	"columns.pgm"

/* Secret Message Text File */
textFile:	.asciz	"secret.txt"

/* Bit Mask to 127 */
mask:		.word 0x0000007f

/* Bit mask for last two digits of Word */
maskTwoDigit:	.word 0xFFFC

/* Image with Secret Message */
secretImage:	.asciz	"columns_secret.pgm"

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


