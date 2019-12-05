Include Irvine32.inc

.data

addr24 EQU <[ebp + 24]>
addr20 EQU <[ebp + 20]>
addr16 EQU <[ebp + 16]>
addr12 EQU <[ebp + 12]>
addr8 EQU <[ebp + 8]>

;used for addTwo
val1 DWORD 5
val2 DWORD 6 

;used for addTwoV2
val3 DWORD 45
val4 DWORD 5
val5 DWORD 0

;used for loadArray
array DWORD 10 dup(0)
loadNum DWORD 5

;used for loadArrayRange
loadArrayR DWORD 10 dup(0)
start DWORD 4
ending DWORD 7

;used for a load array general 
genArray1 BYTE 10 dup(0)
genArray2 WORD 10 dup(0)
genArray3 DWORD 10 dup(0)
byteType DWORD 1
wordType DWORD 2
dwordType DWORD 3

.code

Main Proc
; add two
push val1
push val2
call addTwo
call WriteDec ;display sum
call crlf

;add two version 2
push val3
push val4
push offset val5 
call addTwoV2
mov eax, val5
call WriteDec ;display sum
call crlf

;dump memory before loading array, c convention
mov esi,OFFSET array
mov ecx,LENGTHOF array 
mov ebx,TYPE array     
call DumpMem
call crlf

; push varibales and vcall load array
mov eax, loadNum

push esi
push ecx
push eax
call loadArray
add esp, 16

;dump memory after loading array
mov esi,OFFSET array
mov ecx,LENGTHOF array 
mov ebx,TYPE array     
call DumpMem
call crlf

;dumps the array before loading
mov esi,OFFSET loadArrayR
mov ecx,LENGTHOF loadArrayR
mov ebx,TYPE loadArrayR
call DumpMem
call crlf

;pushes variables and call load arrayRange
mov loadNum, 1 
mov eax, loadNum
push esi
push eax
push start
push ending
call loadArrayRange
add esp, 16

;dump memory after loading array
mov esi,OFFSET loadArrayR
mov ecx,LENGTHOF loadArrayR
mov ebx,TYPE loadArrayR
call DumpMem
call crlf

;dumps the array before loading
mov esi,OFFSET genArray3
mov ecx,LENGTHOF genArray3
mov ebx,TYPE genArray3
call DumpMem
call crlf

;push variables on the stack and call array general
mov loadNum, 3
mov eax, loadNum
push esi
push ecx
push ebx
push eax
call loadArrayGeneral
add esp, 20

;dumps the array before loading
mov esi,OFFSET genArray3
mov ecx,LENGTHOF genArray3
mov ebx,TYPE genArray3
call DumpMem
call crlf

Main ENDP

;adds two variables that are pushed on the stack and stores in the eax
addTwo PROC
	push ebp ; boilerplate
	mov ebp, esp
	
	mov eax, addr12 ; access the first variable pushed
	add eax, addr8 ;add the second variable pushed
	
	mov esp, ebp
	pop ebp
	ret 8
addTwo ENDP

;adds two variables that are pushed on the stack and then stores the sum in 
;a third variable that is also on the stack
addTwoV2 PROC

	push ebp ; boilerplate
	mov ebp, esp 
	
	push ebx
	push eax
	mov eax, addr16
	add eax, addr12
	mov ebx, addr8
	mov [ebx],eax 
	pop eax
	pop ebx
	
	mov esp, ebp
	pop ebp
	
	ret 12
addTwoV2 ENDP	

; expects three paramters, the length, the value of 
loadArray PROC
	
	push ebp
	mov ebp, esp
	mov eax, addr8
	mov ecx, addr12
	mov esi, addr16
	load:		
		mov [esi], eax
		add esi, 4
	loop load

	mov esp, ebp
	pop ebp
	ret
loadArray ENDP

; This next procedure will act as a more flexible array loading
; it takes in the start of where you want a number loaded in the array
; and the end of the array index you want to stop loading at
; also takes in the value you want for to load the array with, and the 
;offset of the array
loadArrayRange PROC

	push ebp
	mov ebp, esp
	
	push ecx
	push edx
	
	mov ecx, addr8
	sub ecx, addr12 ;subtract the start from the ending to know how long to load the array
	mov esi, addr12 ; put the starting position into esi
	mov edi, addr20
	shl esi, 2
	add edi, esi
	load:
		mov edx, addr16
		mov [edi], edx
		add edi, 4
	loop load
	
	done:
	
	pop edx
	pop ecx
	mov esp, ebp
	pop ebp
	ret 
loadArrayRange ENDP	


loadArrayGeneral PROC
	
	push ebp
	mov ebp, esp
	
	mov ecx, addr16 ; move into ecx the length
	mov esi, addr20 ; move into esi the offset
	mov edx, addr8 ; move into the edx the number to load
	
	mov eax, dwordType
	cmp eax, addr12
	je loadDword
	mov eax, wordType
	cmp eax, addr12
	je loadWord
	mov eax, byteType
	cmp eax, addr12
	je loadByte

	;default is a double word array
	loadDword:
		mov [esi], edx
		add esi, 4
	loop loadDword
	jmp done
	
	;loads the word array
	loadWord:
		mov [esi], edx
		add esi, 2
	loop loadWord
	jmp done
	
	;loads the byte array
	loadByte:
		mov [esi], edx
		add esi, 1
	loop loadByte
	
	done:
	mov esp, ebp
	pop ebp
ret
loadArrayGeneral ENDP

END Main