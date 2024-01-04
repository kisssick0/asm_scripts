; Реализовать управление курсором с помощью прерываний таймера (см. 1) и клавиатуры (см. 2). 
; С помощью прерываний таймера реализовать мерцание курсора с частотой один раз в секунду. 
; Изначально курсор ‘█’ должен располагаться в центре экрана. 
; При нажатии клавиши 'w' на клавиатуре курсор должен перемещаться на одну строку вверх. 
; При нажатии клавиши 's' курсор должен перемещаться на одну строку вниз. 
; При нажатии клавиши 'a' курсор должен перемещаться на одну позицию влево. 
; При нажатии клавиши 'd' курсор должен перемещаться на одну позицию вправо. 
; При нажатии клавиши 'q' программа должна завершаться. 

.MODEL TINY
ASSUME CS:MYCODE
ASSUME DS:MYDATA
ASSUME SS:MYSTACK

MYDATA SEGMENT
        END_PROG DB 0
	HOW_TIMES DB 0
	FIRST_CALL DB 0
MYDATA ENDS

MYCODE SEGMENT
MYHANDLER_KEYBOARD:
        STI   
		PUSH AX
                PUSH ES
		PUSH BX
                PUSHF
                MOV AX, 0B800H
                MOV ES, AX

                IN AL, 60H
                INT 90H
                CMP AL, 010H	; Q
                JZ STOP
		CMP AL, 011H	; W
		JZ UP
		CMP AL, 01Fh	; S
		JZ DOWN
		CMP AL, 01Eh	; A
		JZ LEFT
		CMP AL, 020H	; D
		JZ RIGHT
		JMP END_KEYBOARD
              
UP:
		SUB DI, 160
		JMP END_KEYBOARD
DOWN:
		ADD DI, 160
		JMP END_KEYBOARD
LEFT:
		SUB DI, 2
		JMP END_KEYBOARD
RIGHT:
		ADD DI, 2
		JMP END_KEYBOARD
STOP:
                MOV END_PROG, 1H
END_KEYBOARD:
                POPF
		POP BX
                POP ES
		POP AX
        IRET

MYHANDLER_TIMER:
        STI     
		PUSH AX
		PUSH BX
                PUSH ES
		MOV AX, 0B800H
                MOV ES, AX

		CMP FIRST_CALL, 1
		JZ SKIP
		MOV FIRST_CALL, 1
		MOV DI, 1999D
		MOV AH, 0FH
                INT 10H
                MOV AH, 00H
                INT 10H
SKIP:
		MOV BH, 0
		MOV ES:[DI], BH
		INC HOW_TIMES
		CMP HOW_TIMES, 18D
		JNZ END_TIMER
		MOV HOW_TIMES, 0H
		
		MOV BH, 020H
		MOV ES:[DI], BH
END_TIMER:
                MOV AL, 20H
                OUT 20H, AL
                POP ES
		POP BX	
		POP AX
        IRET

MYENTRY:
	; 1. INITSIALIZATSIYA SEGMENTNYKH REGISTROV
        MOV AX, MYDATA
        MOV DS, AX
        MOV AX, MYSTACK
        MOV SS, AX
        MOV AX, 0
        MOV ES, AX
        
	; 2. SOKHRANENIE SISTEMNOGO VEKTORA 1CH
        MOV BX, ES:[1CH*4]
        MOV BP, ES:[1CH*4+2]
	
	CLI
	; 3. PERENASTROIKA VEKTORA 90H NA 09H
        MOV AX, ES:[09H*4]
        MOV ES:[90H*4], AX
        MOV AX, ES:[09H*4+2]
        MOV ES:[90H*4+2], AX
        MOV WORD PTR ES: [09H*4], OFFSET MYHANDLER_KEYBOARD
        MOV WORD PTR ES: [09H*4+2], SEG MYHANDLER_KEYBOARD
	; 4. PERENASTROIKA VEKTORA 1CH NA MYHANDLER_TIMER
        MOV WORD PTR ES: [1CH*4], OFFSET MYHANDLER_TIMER
        MOV WORD PTR ES: [1CH*4+2], SEG MYHANDLER_TIMER
        STI

	; 5. POLEZNAYA RABOTA
CYCLE:
        CMP END_PROG, 1H
        JNE CYCLE	;	ESLI NERAVNO

	; 6. VOSSTANOVLENIE SYSTEMNOGO VEKTORA 1CH, 09H
        CLI
        MOV ES: [1CH*4], BX
        MOV ES: [1CH*4+2], BP
        MOV AX, ES:[90H*4]
        MOV ES:[09H*4], AX
        MOV AX, ES:[90H*4+2]
        MOV ES:[09H*4+2], AX
        STI

	; 7. VYKHOD V DOS
EXIT:
        MOV AX, 4C00H
        INT 21H
MYCODE ENDS

.STACK
MYSTACK SEGMENT
    DB 1000 DUP(?)
MYSTACK ENDS


END MYENTRY
