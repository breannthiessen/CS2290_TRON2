INCLUDE Irvine32.inc

.data

addr8 EQU <[EBP + 8]>
addr12 EQU <[EBP + 12]>
addr16 EQU <[EBP + 16]>
addr20 EQU <[EBP + 20]>

topCornerL = 201
topCornerR = 187
botCornerL = 200
botCornerR = 188
vert = 186
horiz = 205
block = 219
dimension = 80
path = 178
center = 40
leftKey = 4Bh
rightKey = 4Dh
downKey = 50h
upKey = 48h
escKey = 01h
pauseKey = 39h
scoreDH = 81
scoreDL = 0
levelDH = 80
resetDelay = 100
nextLevel = 500
upper = 5
lower = 4
boxBoundary = 69
pathDelay DWORD 100

tronTitle BYTE 87,69,76,67,79,77,69,255,84,79,255,84,82,79,78
levelTitle BYTE 76,69,86,69,76,255
diedMessage BYTE "YOU DIED", 0
gameDone BYTE "GAME OVER", 0
scoreMsg BYTE "SCORE: ", 0
levelMsg BYTE "LEVEL: ", 0
cumScoreMsg BYTE "CUMULATIVE SCORE: ",0
highLevelMsg BYTE "HIGHEST LEVEL ACHIEVED: ", 0
skull BYTE 10 dup(" "), 13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10
	  BYTE 36 dup(" "),255,95,95,95,95,95,95,13,10
	  BYTE 36 dup(" "),47,255,255,255,255,255,255,92,13,10
	  BYTE 35 dup(" "),179,255,40,41,255,40,41,255,179,13,10
	  BYTE 35 dup(" "),179,255,255,255,255,255,255,255,179,13,10
	  BYTE 35 dup(" "),179,255,255,255,255,255,255,255,179,13,10
	  BYTE 36 dup(" "),92, 255,255,94,255,255,47,13,10
	  BYTE 37 dup(" "),179,179,179,179, 179,13,10
	  BYTE 37 dup(" "),179,179,179,179, 179,13,10, 0	  
score DWORD 0
level DWORD 1
highestLevel DWORD 1
cumScore DWORD 0
speedUp DWORD 0
grid BYTE 6400 dup (0) ; playscreen 2d array
memLoc BYTE 0
row BYTE 0
col BYTE 0
numBoxes DWORD 0
boxWidth BYTE ?
boxHeight BYTE ?

.code
main PROC

call Randomize
call TitleVariables
call Initialize 

ENDGAME::
exit
main ENDP

; resets the speed delay  and resets the speed up value for comaprisons
; as the levels get further along. resets score to 0
; reintializes the entire grid array and starts game over at new level
Initialize PROC

mov speedUp, resetDelay
mov pathDelay, resetDelay ; initialize the speed
mov score, 0 ; reset the score after each level and at the beginning of the game

call LoadBorder
call BoxVariables
call DrawScreen
mov eax, LightBlue
call SetTextColor
call RandomVariables

ret
Initialize ENDP

TitleVariables PROC

	push offset tronTitle ; push location of the array on the stack
	push lengthof tronTitle ; push the length of the array on the stack
	push 31 ; push the location for both dl and dh on the stack
	call TitlePage

ret
TitleVariables ENDP

;prints the title letter by letter
TitlePage Proc 
push ebp
mov ebp, esp

mov eax, 0 ; clear
mov dl, addr8 ; mov 31 into both the dh and dl to get location
mov dh, addr8
mov ecx, addr12 ; get the length of the array from the stack
mov esi, addr16 ; move the address into the esi 
mov eax, LightRed
call setTextColor
mov ebx, 0
print: ; print the welcome to tron title one letter at a time
	call GoToXY
	mov al,[esi]
	call WriteChar
	inc dl
	inc esi
	mov eax, 200
	call delay
loop print
mov dl, 26
mov dh, 32
call GoToXY
call WaitMsg
call ClrScr

done:

pop ebp

ret 12
TitlePage ENDP

BoxVariables PROC

mov ecx, level
dec ecx
mov numBoxes, ecx

Boxes:
	cmp numBoxes, 0
	je done
	
	; generate random width between 4-10 
	mov eax, upper
	call RandomRange
	add eax, lower
	push eax ; push the width on the stack
	;generate the height between 4 and 10
	mov eax, upper
	call RandomRange
	add eax, lower
	push eax ; push the random height on the stack
	
	;first generate a random location
	; finds random row
	mov eax, boxBoundary
	call RandomRange
	inc eax
	push eax ; push random row onto stack
	
	;finds random column
	mov eax, boxBoundary
	call RandomRange
	inc eax
	push eax ; push the random column onto stack

	call GenerateBox
	dec numBoxes

jmp Boxes	
	
done:

ret
BoxVariables ENDP
;is called to geneate random obstacles at the beginning of each level
;the number of boxes generated and placed is one less than the level
GenerateBox PROC 

	push ebp
	mov ebp, esp
	
	mov al, addr20 ; move the random box width into the width variable
	mov boxWidth, al
	
	mov al, addr16 ; move the random box height into the height variable
	mov boxHeight, al
	
	mov al, addr12
	mov row, al ; move the random row into the row variable
	
	mov al, addr8
	mov col, al ; mov the random col into the col variable
	
	call GetIndex ; get the memory location and store it in the esi
				  ;now the esi holds the spot to where the box will begin

	mov eax, White
	call SetTextColor ; make the boxes white
	
	mov grid[esi], topCornerL ; move the top left corner into the grid
	mov al, boxWidth
	top:
		inc esi
		cmp al, 0
		je continue
		mov grid[esi], horiz	
		dec al
	jmp top	
	inc esi
	
	continue:
	mov grid[esi], topCornerR 
	mov al, boxHeight
	inc al
	left:
		cmp al, 0
		je continue1
		inc row 
		push eax
		call GetIndex
		mov grid[esi], vert
		pop eax
		dec al
	jmp left
	
	continue1:
	mov grid[esi], botCornerL
	mov al, boxWidth
	inc al
	bottom:
		cmp al, 0
		je continue2
		inc col
		push eax
		call GetIndex
		mov grid[esi], horiz
		pop eax
		dec al
	jmp bottom
	
	continue2:
	mov grid[esi], botCornerR
	mov al, boxHeight
	right:
		cmp al, 0
		je done
		dec row
		push eax
		call GetIndex
		mov grid[esi], vert
		pop eax
		dec al
	jmp right
	
done:
pop ebp
ret 16
GenerateBox ENDP

RandomVariables PROC

;generate random number for dh and dl
mov eax, 0
mov  al,40   ;get random col coordinate from 30-40
call RandomRange ;
add al, 30       
push eax ; move random dl ont the stack

mov eax, 0
mov  al,40    ;get random row coordinate from 30-40
call RandomRange ;
add al, 30 
push eax ;push a random dh on the stack

mov eax, 4
call RandomRange
push eax ; push the random direction on the stack

call RandomSpotDir

ret
RandomVariables ENDP

;determine the direction that the cursor will start moving
RandomSpotDir PROC
push ebp
mov ebp, esp

mov dl, addr20
mov dh, addr16

mov eax, addr8

cmp eax, 3
je right
cmp eax, 2
je left
cmp eax, 1

call GoUpwards

down:
	call GoDownwards
left:
	call GoLeft
right:
	call GoRight

pop ebp
ret 16
RandomSpotDir ENDP

; get the index of the array
GetIndex Proc
push edx
	mov eax, dimension
	mul row
	movzx ebx, col
	add eax, ebx
	mov esi, eax
pop edx

ret
GetIndex ENDP

; this procedure prints the play screen and fills a 2d array with the
; border entries and the empty spots where the light track can be inserted
LoadBorder Proc USES EAX ECX ESI EDX

mov ecx, lengthof grid ; load the entire grid with 0's
mov esi, 0
mov eax, 0
loadGrid:
	mov grid[esi], al
	inc esi
loop loadGrid

;;; set up the variables to draw the top border
mov ecx, dimension
mov esi, 0
topBorder: ; load the first 80 spots of the array with the border number
	mov grid[esi], block
	inc esi
loop topBorder

mov ecx, dimension
mov esi, 0
mov row, 1
mov col, 0
leftBorder:
	call GetIndex
	mov grid[esi], block
	inc row
loop leftBorder

mov ecx, dimension
mov esi, 0
mov row, 1
mov col, dimension
dec col
rightBorder:
	call GetIndex
	mov grid[esi], block
	inc row
loop rightBorder

mov ecx, dimension
mov esi, lengthof grid
sub esi, 80
bottomBorder:
	mov grid[esi], block
	inc esi
loop bottomBorder

ret
LoadBorder ENDP

;draws the screen for the border
DrawScreen PROC USES EAX ECX ESI

mov eax, yellow + (black * 16)
call settextcolor

	mov ecx, lengthof grid
	mov esi, 0
	draw:
		mov al, grid[esi]
		call writeChar
		inc esi
	loop draw

ret
DrawScreen ENDP

;continously moves the smile up
GoUpwards PROC USES EAX EBX EDX

DrawPath:

Start:

	call GoToXY ; go back over cursor

	call GetIndex ; save the location into the array
	mov grid[esi], path
	
	mov bl, grid[esi] ; mov the location into bl
	mov row, dh
	mov col, dl
	call GetIndex
	mov bh, grid[esi] ; get the next location and compare
	cmp bl, bh
	jb die
	
	mov eax, 0 ; clear eax
	mov al, path ; write the space over the cursor
	call WriteChar

	dec dh
	
	mov eax, pathDelay ; let cursor stay on screen
	call delay
	
	call KeyPress
	inc score
	call KeepScore
	
jmp DrawPath

Die:
	call GameOver
	
ret
GoUpwards ENDP

; continuously move the smile down
GoDownwards PROC USES EAX EBX EDX

DrawPath:

	call GoToXY ; go back over cursor
	
	call GetIndex ; save the location into the array
	mov grid[esi], path
	
	mov bl, grid[esi] ; mov the location into bl
	mov row, dh
	mov col, dl
	call GetIndex
	mov bh, grid[esi] ; get the next location and compare
	cmp bl, bh
	jb die
	
	mov eax, 0 ; clear eax
	mov al, path ; write the space over the cursor
	call WriteChar
	
	inc dh

	call KeyPress
	inc score
	call keepScore
	
	mov eax, pathDelay
	call delay
	
jmp DrawPath

Die:
	call GameOver
	
ret
GoDownwards ENDP

; continuously move the cursor to the left
GoLeft PROC USES EAX EBX EDX

DrawPath:

	call GoToXY
	
	call GetIndex ; save the location into the array
	mov grid[esi], path
	
	mov bl, grid[esi] ; mov the location into bl
	mov row, dh
	mov col, dl
	call GetIndex
	mov bh, grid[esi] ; get the next location and compare
	cmp bl, bh
	jb die
	
	mov eax, 0 ; clear eax
	mov al, path 
	call WriteChar
	
	dec dl
	
	mov eax, pathDelay ; let cursor stay on screen
	call delay
		
	call KeyPress	
	inc score
	call keepScore
jmp DrawPath

Die:
	call GameOver

ret
GoLeft ENDP

; continously moves the cursor right
GoRight PROC USES EAX EBX EDX

DrawPath:
	
	call GoToXY
	
	call GetIndex ; save the location into the array
	mov grid[esi], path
	
	mov bl, grid[esi] ; mov the location into bl
	mov row, dh
	mov col, dl
	call GetIndex
	mov bh, grid[esi] ; get the next location and compare
	cmp bl, bh
	jb die
	
	mov eax, 0 ; clear eax
	mov al, path ; write the space over the cursor
	call WriteChar
	
	inc dl
	
	mov eax, pathDelay ; let cursor stay on screen
	call delay
	
continue:	
	call KeyPress	
	inc score	
	call keepScore
jmp DrawPath

Die:
	call GameOver
	
ret
GoRight ENDP

; keeps the score for the game so the players know where they are at
keepScore PROC USES EAX EDX 
	
	mov ecx, score ; compares score to the proper hundred and speeds up if score has 
	cmp ecx, speedUp ; increased by 100
	jne display ; if doesn't need to increase jump to the display code to keep the speed the same
	add speedUp, 100

	mov ecx, pathDelay
	cmp ecx, 20
	je display
	sub pathDelay, 10
	
	display:
	mov dl, scoreDL
	mov dh, scoreDH
	call GoToXY
	mov edx, offset scoreMsg
	call WriteString
	mov dl, scoreDL
	add dl, 7
	mov dh, scoreDH
	call GoToXY
	mov eax, score
	call WriteDec
	mov dl, scoreDL
	mov dh, levelDH
	call GoToXY
	mov edx, offset levelMsg
	call WriteString
	mov dh, levelDH
	mov dl, 7
	call GoToXY
	mov eax, level
	call WriteDec
	
ret
keepScore ENDP

; resets the score and and level increases, then random spot and random direction are called to start new game
;speed is also reset
LevellingUp PROC

inc level
mov pathDelay, resetDelay
call RandomVariables

ret
LevellingUp ENDP

; Is called in each direction Proc in order to see if a key has been read
; if a key has been pressed then it will call the appropriate procedure
KeyPress PROC USES EAX EDX
	
	push edx
	call ReadKey
	pop edx
	
	cmp ah, UpKey
	je Up
	cmp ah, DownKey
	je Down
	cmp ah, LeftKey
	je Left
	cmp ah, RightKey
	je Right
	cmp ah, EscKey
	je GameOver
	cmp ah, PauseKey
	je Waiting
	jmp GoBack
	
	Up:
		call GoUpwards

	Down:
		call GoDownwards

	Left:
		call GoLeft
	
	Right:
		call GoRight
		
	GameOver:
		call GameOver
		
	Waiting:
		mov eax, 50
		call Delay
		push edx
		call ReadKey
		pop edx
		cmp ah, PauseKey
	jne Waiting
	
GoBack:
ret
KeyPress ENDP

; displays the died message and skull for when the player dies
; calls the global variable to end the game
GameOver PROC USES EAX EDX 

mov ecx, cumScore
add ecx, score
dec ecx
mov cumScore, ecx

cmp ah, EscKey
je GameFin
mov ecx, nextLevel
cmp score, ecx
jbe DeathScreen
inc level
mov ecx, level
mov highestLevel, ecx


call clrscr
call Initialize

DeathScreen:
	call clrscr
	mov edx, 0
	mov dl, 36
	mov dh, 20
	call GoToXY
	mov eax, LightRed 
	call SetTextColor
	mov edx, OFFSET diedMessage
	call WriteString
	mov eax, White
	call SetTextColor
	mov edx, OFFSET skull
	call WriteString
	mov eax, 2000
	call Delay

GameFin:
	call clrscr
	mov dl, 36
	mov dh, 20
	call GoToXY
	mov eax, LightRed
	call SetTextColor
	mov edx, OFFSET GameDone
	call WriteString
	mov edx, 0
	mov dh, 25
	mov dl, 29
	call GoToXY
	mov edx, OFFSET cumScoreMsg
	call WriteString
	mov eax, cumscore
	call WriteDec
	mov edx, 0
	mov dh, 23
	mov dl, 29
	call GoToXY
	mov edx, OFFSET highLevelMsg
	call WriteString
	mov eax, highestLevel
	call WriteDec

jmp ENDGAME

ret
GameOver ENDP
END  main