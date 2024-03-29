.MODEL TINY
ASSUME CS:MYCODE
ASSUME DS:MYDATA
ASSUME SS:MYSTACK

MYDATA SEGMENT
	COUNTER DB 0h
	END_PROG DB 0
	QTY DB 06H
	FIRST_CALL DB 01H
MYDATA ENDS

MYCODE SEGMENT
MYHANDLER:    
                PUSH ES
		PUSH BX
		PUSH CX
		PUSH DX
                MOV AX, 0B800H
                MOV ES, AX
		MOV AH, 03EH

		IN AL, 60H
                INT 90H
		MOV BL, AL
		CMP FIRST_CALL, 01H
		JZ FIRST_CALL_HANDLER	;27

CONTINUE:
		CMP BL, 10H		; Q
		JZ END_OF_INT
		CMP BL, 1EH		; A
		JZ GO_UP
		CMP BL, 1FH		; S
		JZ GO_DOWN
		JMP SKIP

GO_DOWN:	
		DEC COUNTER
		JMP OUTPUT_COUNTER

FIRST_CALL_HANDLER:
		JMP FIRST_CALL_HANDLER1

GO_UP:
		INC COUNTER
		JMP OUTPUT_COUNTER

OUTPUT_COUNTER:
		MOV DI, 0AH
		MOV AL, COUNTER
OUTPUT_CYCLE:
		CMP DI, 0FFFEh
		JZ SKIP
		MOV AH, 0
		MOV BL, 02h
		DIV BL
		MOV CL, AH		; ostatok -> cl
		ADD CL, 030h		; go to '0' symbol in ascii table
		MOV CH, 03Eh
		MOV ES:[DI], CX
		SUB DI, 2
		JMP OUTPUT_CYCLE

FIRST_CALL_HANDLER1:
		MOV AL, '0'
		MOV ES:[DI], AX
		ADD DI, 2
		CMP DI, 0CH	; 12/2 = 6 - kol-vo simvolov
		JNZ FIRST_CALL_HANDLER1
		MOV DI, 0H
		JMP SKIP
END_OF_INT:
		MOV END_PROG, 01H
SKIP:
		MOV FIRST_CALL, 0H
		POP DX
		POP CX
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
	MOV DI, 0
	
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
