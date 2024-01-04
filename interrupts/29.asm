; Используя обработку прерывания клавиатуры (см. 2), реализовать бегущую строку, в которой три одинаковых шестнадцатиричных цифры двигаются из стороны в сторону. 
; При касании правой границы индикатора все три цифры инкрементируются. 
; Смена состояния индикатора должна выполняться по нажатию клавиш A и S на клавиатуре. 
; Каждое нажатие клавиши A переводит индикатор на одно состояние вперед. 
; Kаждое нажатие клавиши S возвращает индикатор на одно состояние назад. 
; При нажатии клавиши Q программа должна завершаться.

.MODEL TINY
ASSUME CS:MYCODE
ASSUME DS:MYDATA
ASSUME SS:MYSTACK

MYDATA SEGMENT
	COUNTER DB 00h
	END_PROG DB 0
	QTY DB 03H
	FIRST_CALL DB 01H
MYDATA ENDS

MYCODE SEGMENT
MYHANDLER:    
                PUSH ES
		PUSH BX
		PUSH DX
                MOV AX, 0B800H
                MOV ES, AX
		MOV AH, 26H

CONTINUE_AFTER_CLEAR:
		IN AL, 60H
                INT 90H
		MOV BL, AL
		CMP FIRST_CALL, 01H
		JZ FIRST_CALL_HANDLER	;27
CONTINUE_AFTER_INC:
		CMP COUNTER, 10H
		JZ CLEAR
		MOV AL, COUNTER
		ADD AL, '0'
		CMP AL, '9'
		JLE CONTINUE
		ADD AL, 7
CONTINUE:
		CMP BL, 10H
		JZ END_OF_INT
		CMP BL, 1EH
		JZ TO_RIGHT
		CMP BL, 1FH
		JZ TO_LEFT
		JMP SKIP
TO_LEFT:	;50
		CMP DI, 0H
		JZ SKIP
		SUB DI, 2
		MOV ES:[DI], AX
		ADD DI, 2
		MOV ES:[DI], AX
		ADD DI, 2
		MOV ES:[DI], AX
		ADD DI, 2
		MOV DX, 0000H
		MOV ES:[DI], DX
		SUB DI, 6
		JMP SKIP

FIRST_CALL_HANDLER:
		JMP FIRST_CALL_HANDLER1
TO_RIGHT:
		CMP DI, 6H
		JNZ CONTINUE_TO_RIGHT
		INC COUNTER
		SUB DI, 2
		JMP CONTINUE_AFTER_INC
CONTINUE_TO_RIGHT:
		MOV DX, 0000H
		MOV ES:[DI], DX
		ADD DI, 2
		MOV ES:[DI], AX
		ADD DI, 2
		MOV ES:[DI], AX
		ADD DI, 2
		MOV ES:[DI], AX
		SUB DI, 4H
		JMP SKIP
;84
CLEAR:
		MOV COUNTER, 0H
		JMP CONTINUE_AFTER_CLEAR
FIRST_CALL_HANDLER1:
		MOV AL, '0'
		MOV ES:[DI], AX
		ADD DI, 2
		CMP DI, 6H
		JNZ FIRST_CALL_HANDLER1
		MOV DI, 0H
		JMP SKIP
END_OF_INT:
		MOV END_PROG, 01H
SKIP:
		MOV FIRST_CALL, 0H
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
