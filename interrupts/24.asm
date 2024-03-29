; Используя обработку прерывания клавиатуры (см. 2), реализовать бегущую строку. 
; Четырехзначное десятичное число 1234 двигается по шестизначному индикатору. 
; Цифры, выходящие за пределы индикатора, перебрасываются в начало. 
; Смена состояния индикатора должна выполняться по нажатию клавиш A и S на клавиатуре. 
; Каждое нажатие клавиши A переводит индикатор на одно состояние вперед, каждое нажатие клавиши S возвращает индикатор на одно состояние назад. 
; При нажатии клавиши Q программа должна завершаться.

.MODEL TINY
ASSUME CS:MYCODE
ASSUME DS:MYDATA
ASSUME SS:MYSTACK

MYDATA SEGMENT
	FIRST DW 0H, 0H, 02631H, 02632H, 02633H, 02634H
	SECOND DW 02634H, 0H, 0H, 02631H, 02632H, 02633H
	THIRD DW 02633H, 02634H, 0H, 0H, 02631H, 02632H
	FOURTH DW 02632H, 02633H, 02634H, 0H, 0H, 02631H
	FIFTH DW 02631H, 02632H, 02633H, 02634H, 0H, 0H
	SIXTH DW 0H, 02631H, 02632H, 02633H, 02634H, 0H
	COUNTER DB 01h
	END_PROG DB 0
	FIRST_CALL DB 01H
MYDATA ENDS

MYCODE SEGMENT
MYHANDLER:    
                PUSH ES
		PUSH BX
		PUSH DX
		PUSH CX
		PUSH SI
                MOV AX, 0B800H
                MOV ES, AX
		MOV DI, 0

		IN AL, 60H
                INT 90H
		MOV BL, AL
		CMP FIRST_CALL, 01H
		JZ TO_FIRST_CALL_HANDLER

		CMP BL, 10H
		JZ TO_END_OF_INT
		CMP BL, 1EH
		JZ TO_RIGHT
		CMP BL, 1FH
		JZ TO_LEFT
		JMP SKIP
TO_LEFT:
		DEC COUNTER
		CMP COUNTER, 0H
		JNZ CHECK
		MOV AL, 06H
		MOV COUNTER, AL
		JMP CHECK

TO_FIRST_CALL_HANDLER:
		JMP FIRST_CALL_HANDLER
TO_RIGHT:
		INC COUNTER
		CMP COUNTER, 07H
		JNZ CHECK
		MOV AL, 01H
		MOV COUNTER, AL
		JMP CHECK
CHECK:
		CMP COUNTER, 01H
		JNZ SKIP1
		MOV SI, OFFSET FIRST
		JMP PRINT
SKIP1:
		CMP COUNTER, 02H
		JNZ SKIP2
		MOV SI, OFFSET SECOND
		JMP PRINT
SKIP2:
		CMP COUNTER, 03H
		JNZ SKIP3
		MOV SI, OFFSET THIRD
		JMP PRINT
TO_END_OF_INT:
		JMP END_OF_INT
SKIP3:
		CMP COUNTER, 04H
		JNZ SKIP4
		MOV SI, OFFSET FOURTH
		JMP PRINT
SKIP4:
		CMP COUNTER, 05H
		JNZ SKIP5
		MOV SI, OFFSET FIFTH
		JMP PRINT
SKIP5:
		CMP COUNTER, 06H
		MOV SI, OFFSET SIXTH
		JMP PRINT	

FIRST_CALL_HANDLER:
		MOV SI, OFFSET FIRST
PRINT:
		MOV AX, DS:[SI]
		MOV ES:[DI], AX
		ADD SI, 2
		ADD DI, 2
		CMP DI, 0CH
		JNZ PRINT
		JMP SKIP
END_OF_INT:
		MOV END_PROG, 01H
SKIP:
		MOV FIRST_CALL, 0H
		POP SI
		POP CX
		POP DX
		POP BX
                POP ES
    		MOV AL, 20H
		OUT 20H, AL
		IRET

MYENTRY:
	; 1. INITSIALIZATSIYA SEGMENTNYKH REGISTROV
        MOV AX, MYSTACK
        MOV SS, AX
	MOV AX, MYDATA
	MOV DS, AX
        MOV AX, 0
        MOV ES, AX
	
	CLI
	; 2. PERENASTROIKA VEKTORA 90H NA 09H, 09H NA MYHADLER
        MOV AX, ES:[09H*4]
        MOV ES:[90H*4], AX
        MOV AX, ES:[09H*4+2]
        MOV ES:[90H*4+2], AX
        MOV WORD PTR ES: [09H*4], OFFSET MYHANDLER
        MOV WORD PTR ES: [09H*4+2], SEG MYHANDLER
        STI

	; 3. POLEZNAYA RABOTA
CYCLE:
        CMP END_PROG, 1H
        JNE CYCLE	;	ESLI NERAVNO


	; 4. VOSSTANOVLENIE SYSTEMNOGO VEKTORA 09H
        CLI
        MOV AX, ES:[90H*4]
        MOV ES:[09H*4], AX
        MOV AX, ES:[90H*4+2]
        MOV ES:[09H*4+2], AX
        STI

	; 5. VYKHOD V DOS
EXIT:
        MOV AX, 4C00H
        INT 21H
MYCODE ENDS

.STACK
MYSTACK SEGMENT
    DB 1000 DUP(?)
MYSTACK ENDS


END MYENTRY
