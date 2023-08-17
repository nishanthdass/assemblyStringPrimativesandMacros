TITLE String Primitives & Macros  (Proj6_dassn.asm)


INCLUDE Irvine32.inc
; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Display a prompt, then get the user’s keyboard input into a memory location(inString). 
;
; Preconditions: Does not use eax, ecx, esi as arguments. All arguments passed by reference.
;
; Receives:
; promptIn = array address of a string array used to prompt user
; regisIn = array address used as memory location for output string
; countIn = array length of input
; countOut = array length of output
;
; returns: regisIn = user’s keyboard input
;		 : countOut = length of keyboard input
; ---------------------------------------------------------------------------------
mGetString MACRO promptIn, regisIn, countIn, countOut
	PUSH	EAX
	PUSH	ECX
	PUSH	EDX
	;		Print prompt in the console
	MOV		EDX, promptIn
	CALL	WriteString
	MOV		EDX, regisIn					;	point to address of empty array 
	MOV		ECX, countIn					;	specify max characters of input
	CALL	ReadString						
	MOV		countOut, EAX					;	return length of keyboard input
	POP		EDX
	POP		ECX
	POP		EAX
ENDM


; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Print any string which is stored in a specified memory location
;
; Preconditions: Does not use eax, ecx, esi as arguments. All arguments passed by reference.
;
; Receives:
; alignedOutput = array address of a string array used to hold integers in string format
;
; returns: None
;
; ---------------------------------------------------------------------------------
mDisplayString MACRO alignedOutput
	PUSH	EDX
	MOV		EDX, alignedOutput
	Call	WriteString
	POP EDX
ENDM

;	Constants
MAXSIZE = 10								;	Maximum size of the array that holds each integers that are input by the user(originally in string format)
LOWER = 48d									;	Lower bound decimal used to compare string input. 48b is equal to 0 char
UPPER = 57d									;	Upper bound decimal used to compare string input. 57d is equal to 9 char

.data
;	Below variables hold text for program introduction, program prompts, errors and labels of results
titleText1		BYTE	"			PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 10, 13, 0
titleText2		BYTE	"									Written by: Nishanth Dass", 10, 13, 0
introText1		BYTE	"Please provide 10 signed decimal integers.", 10, 13
				BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.", 10, 13, 0
promptText1		BYTE	"Please enter an signed number: ", 0
spaceText		BYTE	", ",0
result1			BYTE	"You entered the following numbers: ", 10, 13, 0
result2			BYTE	"The sum of these numbers is: ", 0
result3			BYTE	"The truncated average is: ", 0
error1			BYTE	"ERROR: You did not enter an signed number or your number was too big.", 10, 13, 0
goodbye1		BYTE	"Writing code for this class has been a blast. It's been a pleasure. Goodbye!", 10, 13, 0
;	Below variables used for array memory locations & their length. Some variables hold the numeric results.
array			DWORD	MAXSIZE DUP(0)		;	Array that holds each integers that are input by the user(originally in string format)
sumVar			DWORD	?					;	Holds the sum of the array in integer format for conversion to string
avgVar			DWORD	?					;	Holds the average of the array in integer format for conversion to string
numVar			SDWORD	?					;	Used as temporary holder variable for integers stored in array so that they can be converted to string in WriteVal Procedure
byteCount		DWORD	?					;	Holds the array length of the keyboard input output
boolVar			DWORD	?					;	Holds either 0 or 1 to signify boolean values to determine if user input is positive or negative
inString		BYTE	20 DUP(?)			;   array address used as memory location for keyboard 
outString		BYTE	20 DUP(?)			;   array address used as memory location for output string for WriteVal
outIntegers		SDWORD	20 DUP(?)			;	Used as temporary holder variable to store integer before inserting in main array
revString		BYTE	20 DUP(?)			;	Used as temporary holder variable to store a string(in reverse due to conversion method)


.code
main	PROC
	;	Print introduction in the console
	PUSH	OFFSET titleText1					
	PUSH	OFFSET titleText2	
	PUSH	OFFSET introText1	
	Call	introduction	

	;	Take user input using a loop
	MOV		ECX, 0							;	ECX will hold the loop counter
	MOV		EBX, 0							;	EBX	will increment the array position of EDI
	MOV		EDI, OFFSET array				;	EDI	set to address of main array where each integer is stored
	_fillArray:
			PUSH	boolVar
			PUSH	OFFSET outIntegers
			PUSH	byteCount
			PUSH	LENGTHOF inString
			PUSH	OFFSET inString
			PUSH	OFFSET promptText1
			Call	ReadVal					;	Call ReadVal after pushing the prompt text and variables to hold keyboard input & integer output
			MOV		EAX, outIntegers		;	Move returned integer from Readval into EAX
			MOV		[EDI+EBX], EAX			;	Insert integer into array
			INC		ECX						
			ADD		EBX, 4  
			CMP		ECX, MAXSIZE			;	If ECX does not MAXSIZE
			JNE		_fillArray				;	then loop again
	MOV		ECX, 0
	MOV		EBX, 0

	;	Read all integers stored in the array and print them as strings in the console
	MOV		ESI, OFFSET array				;	Point the main array to the source index so that array values can be read
	Call	Crlf
	mDisplayString OFFSET result1			;	use macro to WriteString 

	;	Loop over array
	_readArray:
		MOV   EAX, [ESI]					;	Move first element of array into EAX
		ADD	  EBX, EAX						;	Add EAX to EBX. EBX used as an accumulator 
		MOV	  numVar, EAX

		;	Convert integer to string
		Push	OFFSET	outString
		Push	OFFSET	revString
		PUSH	numVar
		Call	WriteVal					;	Call WriteVal after pushing integer from array and addresses of output arrays for string conversion

		XOR		EAX,	EAX
		XOR		EDX,	EDX
		ADD		ESI, 4						
		INC		ECX							;	ECX used as a counter for looping over array
		CMP		ECX, MAXSIZE				;	If ECX does not equal MAXSIZE
		JNE		_AddComma					;	then add comma and loop again
		JE		_NoComma					;	else do not add comma and stop looping

		_AddComma:
			mDisplayString OFFSET SpaceText
			JMP _readArray
	
		_NoComma:
			Call	Crlf
	
	;	Show Sum of all integers in an array
	MOV		[EDI], EBX						;	Move sum to first position in the main array
	MOV		ESI, OFFSET array				;	Point ESI to the main array
	mDisplayString OFFSET result2			;	use macro to WriteString 

	_readSum:
		MOV		EAX, [ESI]					;	Move first element of array into EAX
		MOV		sumVar, EAX					

		;	Convert integer to string
		Push	OFFSET	outString
		Push	OFFSET	revString
		PUSH	sumVar
		Call	WriteVal
		XOR		EAX,	EAX
		XOR		EDX,	EDX

	;	Show average of all integers in an array
	Call	Crlf
	MOV		EAX,	EBX
	MOV		EBX,	MAXSIZE
	CDQ
	IDIV	EBX								;	Divide sum of number in array with length of array
	MOV		[EDI], EAX						;	Move result to first position in  main array
	MOV		ESI, OFFSET array				;	Point ESI to the main array
	mDisplayString OFFSET result3

	_readAverage:
		MOV   EAX, [ESI]					;	Move first element of array into EAX
		MOV	  avgVar, EAX			
		;	Convert integer to string
		Push	OFFSET	outString
		Push	OFFSET	revString
		PUSH	avgVar
		Call	WriteVal
		XOR		EAX,	EAX
		XOR		EDX,	EDX

	;	Outro or goodbye message
	Call	Crlf
	Call	Crlf
	mDisplayString OFFSET goodbye1			;	use macro to WriteString 

	Invoke ExitProcess, 0
main ENDP


; ---------------------------------------------------------------------------------
; Name: introduction
;
; Prints an introduction to the program in the console
;
; Preconditions: 3 Predefine string arrays must be provided to the procedure
;
; Postconditions: none.
;
; Receives:
; [ebp+16] = address of string array titleText1
; [ebp+12] = address of string array titleText2
; [ebp+8] = address of string array introText1
;
; returns: None
; ---------------------------------------------------------------------------------
introduction PROC
	PUSH    EBP					;	preserve base pointer					
	MOV     EBP,ESP	
	PUSHAD						;	preserve registers
	;	print introduction and description
	MOV     EDX, [EBP+16]		;	Move address of string array titleText1 to EDX
	CALL    WriteString		
	MOV     EDX, [EBP+12]		;	Move address of string array titleText2 to EDX
	CALL    WriteString		
	Call	CrLf
	MOV     EDX, [EBP+8]		;	Move address of string array introText1 to EDX
	CALL    WriteString	
	Call	CrLf
	POPAD
	POP     EBP
	RET		12
introduction ENDP



; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Get user input as a string, converts the string of ascii digits to its numeric value, valides the user’s input and stores this one value in a memory variable
;
; Preconditions: inString([EBP+12]) should be a BYTE array and outIntegers([EBP+24]) should be SDWORD
;
; Postconditions: none.
;
; Receives:
; [EBP+8] = predefined string to prompt user
; [EBP+12] = array address used as memory location for keyboard input
; [EBP+16] = length of array address used as memory location for keyboard input
; [EBP+24] = temporary holder array to store integer before inserting in main array
; [EBP+20] = length of temporary holder variable
; [EBP+28] = variable to hold boolean result(either 0 or 1)
;
; returns: None
; ---------------------------------------------------------------------------------
ReadVal	PROC
	PUSH    EBP									;	preserve base pointer			
	MOV     EBP,ESP	
	PUSHAD
	_getData:
		mGetString [EBP+8], [EBP+12], [EBP+16], [EBP+20]
	; Convert  string of ascii digits to its numeric value representation(SDWORD)
	_convertData:
		CLD										;	clear direction flag
		MOV		ECX, [EBP+20]					;	Loop length intitalized to length of keyboard input
		MOV		ESI, [EBP+12]					;	move offset of inString to ESI
		MOV		EDI, [EBP+24]					;	move offset of outIntegers to EDI

		MOV		EBX, 0
		MOV		EDX, 0
		MOV		[EBP+28], EDX					;	[EBP+28] or boolVal is intialized to 0(0 indicates positive value)
		;	Convert string to integer
		_convert:
			MOV		EAX, 0
			LODSB
			CMP		ECX, [EBP+20]				;	If ECX equals length of keyboard input
			JE		_signCheck					;	Then check if a sign exists
			JMP		_numberCheck				;	Else jump to verification of number

			_signCheck:
				CMP		AL,	45d					;	compare AL with -
				JE		_isNegative
				CMP		AL,	43d					;	compare AL with +
				JE		_isPositive
				JMP		_numberCheck			;	If neither - or + then check if the first string is a valid nummber

			_isNegative:
				MOV		EDX, 1				
				MOV		[EBP+28], EDX			;	Set boolean variable to 1 for negative
				MOV		EDX,	0
				LOOP	_convert

			_isPositive:
				MOV		EDX, 0
				MOV		[EBP+28], EDX			;	Set boolean variable to 0 for positive
				LOOP	_convert

			;	Check if string is a nummber
			_numberCheck:
				;	Check if string is a number
				CMP		AL,	LOWER				;	If AL is below 0 char
				JB		_errorHex				;	Show error and re=prompt user
				CMP		AL,	UPPER				;	If AL is above 9 char
				JA		_errorHex				;	Show error and re=prompt user
				;	Below formula is implemented
				;	numInt = 10 * numInt + (numChar - 48)
				SUB		EAX, 48d
				PUSH	EAX
				MOV		EAX, EBX
				MOV		EBX, 10
				IMUL	EBX
				MOV		EBX, EAX
				POP		EAX
				JO		_errorHex				
				ADD		EAX, EBX
				JO		_errorHex
				MOV		EBX, EAX
				LOOP	_convert

				;	Store number based on if it is positive or negative
				MOV		EDX, [EBP+28]
				CMP		EDX, 1
				JE		_storeNegative
				JMP		_storePositive

				_storeNegative:
					MOV	EBX, -1
					IMUL EBX
					STOSD
					JMP		_storeData

				_storePositive:
					STOSD
					JMP		_storeData

		_errorHex:
			MOV		EAX, 0
			;MOV		EBX, 0
			;MOV		EDX, 0
			MOV		ECX, 0
			MOV		EDX, OFFSET error1
			CALL    WriteString	
			JMP		_getData

	_storeData:
		POPAD
		POP     EBP
		RET		24
ReadVal	ENDP


; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Converts a numeric SDWORD value to a string of ASCII digits and prints the ASCII representation of the SDWORD value to the output.
;
; Preconditions: numVar([EBP+8]) should be SDWORD
;
; Postconditions: none.
;
; Receives:
; [EBP+8] = holds integers value from main array
; [EBP+12] = array address pointing to temporary holder variable to store a string(in reverse due to conversion method)
; [EBP+16] = array address pointing memory location for output string after conversion from int to char
;
; returns: None
; ---------------------------------------------------------------------------------
WriteVal PROC
	PUSH    EBP									;	preserve base pointer					
	MOV     EBP,ESP	
	PUSHAD

	MOV		ECX,	0
	CLD
	MOV		EDI, [EBP+12]						;	provide EDI with address of empty array
	MOV		EAX, [EBP+8]						
	CMP		EAX, 0								;	If integer value is negative
	JS		_negInt								;	Jump to negative integer evaluation
	JNS		_notNegInt							;	If not negative, jump to non-negative integer evaluation 
	;	handles negative integer
	_negInt:
			INC		ECX
			MOV		DL, '-'
			PUSH	EDX							;	Push EDX(holding '-') which will be concatenated later
			NEG		EAX
			JMP		_intCompare
	;	handles postiive integer
	_notNegInt:
			XOR		DL, DL						
			PUSH	EDX
			JMP		_intCompare
	;	below calculation divides each integer by 10, adds 48 to the remainder and adds a '-' so the string if necessary
	;	below calculation stores the number as a sting in reverse order
	_intCompare:
		INC		ECX
		CDQ
		MOV		EBX, 10
 		IDIV		EBX
		ADD		DL,	48
		PUSH	EAX
		MOV		AL,	DL
		STOSB
		POP		EAX
		CMP		EAX, 0
		JE		_endLoop
		JMP		_intCompare
	_endLoop:
		POP	EDX
		MOV	AL, DL
		STOSB
	
	;	reverses the string so the numerical string is oriented correctly
	MOV		ESI, [EBP+12]				;	Point ESI to reversed string
	add		ESI, ECX
	dec		ESI
	mov		EDI, [EBP+16]				;	Point EDI to empty string for storage of final string value
	_reverseNum:
		STD
		LODSB
		CLD
		STOSB
		Loop	_reverseNum
	MOV		BYTE ptr[EDI],0				;	Allow EDI to store values in BYTE size
	mDisplayString [EBP+16]				;	Print string value stored in output string
	POPAD
	POP		EBP
	RET		12
WriteVal ENDP

END main