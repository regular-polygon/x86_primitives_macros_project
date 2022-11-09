TITLE Program Proj6_CHENWENH     (Proj6_CHENWENH.asm)

; Author: Wenhao Chen
; Last Modified: 6/3/2022
; OSU email address:  
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 6/5/2022
; Description: This project involves concepts related to string primitives and macros.
;              The program will prompt the user to input a string of digits, convert them
;			   to its numeric value representation, validate input, and perform simple arithmetic
;			   on the numbers.

INCLUDE Irvine32.inc

;-------------------------------------------------------------------------------------------
; Name: mGetString
;
; Prompt user input. Store user input into memory.
;
; Preconditions: Address of prompt. Address of string_input. LENGTHOF string_input. Address of bytes_read.
;
; Postconditions: string_input changed. bytes_read changed.
;
; Receives: Address of prompt. Address of string_input. LENGTHOF string_input. Address of bytes_read.
;
; Returns: string_input changed. Number of bytes read in bytes_read.
;-------------------------------------------------------------------------------------------
mGetString MACRO addr_prompt, addr_str_in, len_str_in, addr_bytes_read
	PUSHAD
	MOV		EDX, addr_prompt
	CALL	WriteString

	MOV		EDX, addr_str_in
	; number of characters to read in
	MOV		ECX, len_str_in
	CALL	ReadString
	; store number of bytes read
	MOV		[addr_bytes_read], AL

	POPAD
ENDM

;-------------------------------------------------------------------------------------------
; Name: mDisplayString
;
; It prints the string at the given address
;
; Preconditions: none
;
; Postconditions: none
;
; Receives: Address of string
;
; Returns: none.
;-------------------------------------------------------------------------------------------
mDisplayString MACRO addr_str_out
	PUSHAD
	MOV		EDX, addr_str_out
	CALL	WriteString
	CALL	CrLf
	POPAD
ENDM


.data
; greeting messages
prog_title		BYTE	"Project 6",13,10,"Author: Wenhao Chen",13,10,0
greeting		BYTE	"Please enter 10 signed decimal integers.",13,10,"Once that is done, this program will display some summary statistics",13,10,0
; input and prompts
string_input	BYTE	12 DUP(?)
bytes_read		DWORD	?
prompt_input	BYTE	"Please enter a signed number: ",13,10,0
; error message
error_input		BYTE	"Error. Please enter a signed number that will fit in a 32 bit register",13,10,0
; conversion
int_array		SDWORD	10 DUP(?)
converted_int	SDWORD	0
string_output	BYTE	12 DUP(?)
test_sdw		SDWORD	-12345
; other messages
num_summary		BYTE	"You entered the following numbers:",13,10,0
sum_msg			BYTE	"The sum of these numbers is:",13,10,0
avg_msg			BYTE	"The truncated average is:",13,10,0
; arithemtic variables
array_sum		SDWORD	?
array_avg		SDWORD	?
.code
;-------------------------------------------------------------------------------------------
; Name: main
;
; It's the main procedure that calls other procedures.
; Includes a test program that call ReadVal 10 times to get 10 integers, calculates summary 
; statistics, and prints them using WriteVal.
;
; Preconditions: none
;
; Postconditions: none
;
; Receives: none.
;
; Returns: none.
;-------------------------------------------------------------------------------------------
main PROC

; greet the user and explain the program's purpose.
	PUSH	OFFSET	prog_title
	PUSH	OFFSET	greeting
	CALL	greet_user
; counted loop, accepts 10 values.
	MOV		ECX, 10
	MOV		EDI, OFFSET int_array
	_read_loop:
		PUSH	OFFSET prompt_input
		PUSH	OFFSET string_input
		PUSH	LENGTHOF string_input
		PUSH	bytes_read
		PUSH	OFFSET error_input
		PUSH	OFFSET converted_int
		CALL	ReadVal
		; store converted integers into array
		MOV		EAX, converted_int
		STOSD	
	LOOP	_read_loop
; counted loop. prints the inputted values.
	MOV		ECX, 10
	MOV		ESI, OFFSET int_array
	MOV		EDX, OFFSET num_summary
	CALL	WriteString
	_write_loop:
		LODSD	
		PUSH	EAX
		PUSH	OFFSET string_output
		PUSH	LENGTHOF string_output
		CALL	WriteVal
	LOOP	_write_loop
; counted loop. Sum up the integers in array_sum variable and print it.
	MOV		ECX, LENGTHOF int_array
	MOV		ESI, OFFSET int_array
	MOV		array_sum, 0
	_sum_loop:
		LODSD
		ADD	array_sum, EAX
	LOOP	_sum_loop

	MOV		EDX, OFFSET sum_msg
	CALL	WriteString

	PUSH	array_sum
	PUSH	OFFSET string_output
	PUSH	LENGTHOF string_output
	CALL	WriteVal
; counted loop. Calculate the truncated average and print it.
; precondition: run the sum_loop to put the correct sum in array_sum
	MOV		EBX, LENGTHOF int_array
	MOV		EAX, array_sum
	CDQ
	IDIV	EBX

	MOV		array_avg, EAX
	MOV		EDX, OFFSET avg_msg
	CALL	WriteString

	PUSH	array_avg
	PUSH	OFFSET string_output
	PUSH	LENGTHOF string_output
	CALL	WriteVal

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;-------------------------------------------------------------------------------------------
; Name: greet_user
;
; Print greeting messages. Explain to user the purpose of this program.
;
; Preconditions: Declared messages strings.
;
; Postconditions: none
;
; Receives: Addresses of the messages via runtime stack.
;
; Returns: none.
;-------------------------------------------------------------------------------------------

greet_user PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD
	; stack OFFSET prog_title, OFFSET greeting, RET ADDR, EBP, PUSHAD
	MOV		EDX, [EBP + 12]
	CALL	WriteString
	MOV		EDX, [EBP + 8]
	CALL	WriteString

	POPAD
	POP		EBP
	
	RET		4
greet_user ENDP

;-------------------------------------------------------------------------------------------
; Name: ReadVal
;
; Prompt user for string input. Accept numbers preceded by + or -. Convert the string to the 
; equivalent signed integer.
;
; Preconditions: Functional mGetString. Declared variables: prompt input, string_input,
;				 bytes_read, error_input, converted_int
;
; Postconditions: none
;
; Receives: Addresses of prompt_input, string_input, length of string_input, value of bytes_read,
;			address of error_input, converted_int
;
; Returns: string converted to integer stored in converted_int
;-------------------------------------------------------------------------------------------
ReadVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD
	; stack ADDR prompt_input, ADDR string_input, LENGTHOF string_input, bytes_read, ADDR error_input, ADDR converted_int, RET ADDR, EBP, PUSHAD
	
	_prompt:
	mGetString [EBP+28], [EBP+24], [EBP+20], [EBP+16]
	; the address of inputted string is at EBP + 24
	
	MOV		ESI, [EBP+24]							; read from string_input
	MOV		EDI, [EBP+8]							; store output to converted_int variable

	; clean up variable, register
	MOV		EAX, 0
	MOV		[EDI], EAX

	MOV		ECX, [EBP+16]							; loop n times for n characters
	_conversion_loop:
		MOV		EAX, 0								; clear the accumulator
		LODSB										; the first byte in string_input gets loaded into AL, then moved to EBX
		MOV		EBX, EAX

		CMP		BL, 48
		JL		_not_numeric
		CMP		BL, 57
		JG		_not_numeric

	_is_numeric:
		; ascii code to actual integer conversion 
		; multiply the current output int by 10, then add the most recent converted int
		SUB		EBX, 48
		MOV		EDX, 10
		MOV		EAX, [EDI]
		MUL		EDX
		JO		_error_message					; detecting 32 bit overflow
		MOV		SDWORD PTR [EDI], EAX
		ADD		SDWORD PTR [EDI], EBX
		JMP		_loop_end

	_not_numeric:
	_check_sign:
		; if not a number, is it a plus sign or minus sign?
		CMP		BL, 43
		JE		_plus_sign
		CMP		BL, 45
		JE		_minus_sign

	_error_message:
		MOV		EDX, [EBP+12]
		CALL	WriteString
		JMP		_prompt

	_plus_sign:
		JMP		_loop_end

	_minus_sign:
		PUSH	1
		JMP		_loop_end

	_loop_end:
		LOOP	_conversion_loop

	; check if we need to make the number negative. The top of the stack is 1 if negative.
	POP		EAX
	CMP		EAX, 1
	JNE		_not_negative

	_negative:
		MOV		EAX, [EDI]
		NEG		EAX
		MOV		SDWORD PTR [EDI], EAX
		JMP		_output

	_not_negative: 
		; pushes EAX back onto stack, because if there's no negative sign, then we didn't push a 1 onto the stack, so we popped off the wrong thing. 
		PUSH EAX

	_output:

	POPAD
	POP		EBP

	RET 24
ReadVal ENDP

;-------------------------------------------------------------------------------------------
; Name: WriteVal
;
; Converts a numeric SDWORD value to a string of ASCII value. Calls mDisplayString to print the string.
;
; Preconditions: Declared string_output
;
; Postconditions: none
;
; Receives: SDWORD value, Address of string_output, LENGTHOF string_output
;
; Returns: Changed string_output
;-------------------------------------------------------------------------------------------
WriteVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD
	; stack: SDWORD value, ADDR string_output, , Lengthof string_output, RET ADDR, EBP, PUSHAD, n ints pushed by _convert_to_ascii

	; clear the string_output variable
	MOV		ECX, 12
	MOV		EDI, [EBP+12]
	_clear_output_loop:
		MOV	EAX, 0
		STOSB
	LOOP	_clear_output_loop

	MOV		EDX, 0
	MOV		EAX, [EBP+16] ;SDWORD
	MOV		EBX, 10
	MOV		ECX, 0
	MOV		EDI, [EBP+12] ;string ADDR

	; if SDWORD is negative, convert the SDWORD in EAX to positive first. We'll add a negative sign later.
	CMP		EAX, 0
	JGE		_positive
	_negative:
	NEG		EAX
	_positive:
	; does nothing. it's already positive.

	; this loop doesn't use ECX, it's uncounted
	_conversion_loop:
	MOV		EDX, 0
	CDQ
	IDIV	EBX
	
	_convert_to_ascii:
	; the remainder from IDIV is in EDX
	; the remainder is integer value of the ones place in the number before division
	; push it onto the stack and pop it off in _fill_array_loop, because it processes the number from right to left.
	ADD		EDX, 48
	PUSH	EDX
	; keep track of how many ascii values we pushed, pop off the same amount later.
	INC		ECX
	; when EAX is zero, we've finished converting from int to ascii, so we move on to add a sign and fill the array.
	CMP		EAX, 0
	JE		_add_sign
	JMP		_conversion_loop

	_add_sign:
	MOV		EAX, [EBP+16]
	CMP		EAX, 0
	JGE		_add_plus_sign
	_add_minus_sign:
	MOV		EAX, 45
	STOSB
	JMP		_fill_array_loop
	_add_plus_sign:
	MOV		EAX, 43
	STOSB

	; this counted loop fills the output string, it relies on the incremented ECX. 
	_fill_array_loop:
	POP		EAX
	STOSB
	LOOP	_fill_array_loop

	mDisplayString [EBP+12]

	POPAD
	POP		EBP

	RET 8
WriteVal ENDP


END main
