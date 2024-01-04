; Реализовать обработку прерываний от таймера (см. 1) и от клавиатуры (см. 2). 
; По прерыванию таймера один раз в три секунды переключать цвет фона первой строки экрана между черным и красным. 
; Когда цвет строки становится красным, запрещать прерывание клавиатуры. 
; Когда цвет строки становится черным, разрешать прерывание клавиатуры. 
; По прерыванию клавиатуры при нажатии цифровой клавиши '0', '1','2','3','4','5','6','7','8','9' закрашивать вторую строку экрана в цвет фона, код которого равен значению соответствующей цифры. 
; Программа должна завершаться после нажатия клавиши '0'.

.MODEL TINY
ASSUME CS:MYCODE
ASSUME DS:MYDATA
ASSUME SS:MYSTACK

MYDATA SEGMENT
        COUNTER DW 0
        END_PROG DB 0
MYDATA ENDS

MYCODE SEGMENT
MYHANDLER_KEYBOARD:
        STI     
                PUSH ES
		PUSH BX
                PUSHF
                MOV AX, 0B800H
                MOV ES, AX

                MOV AH, 0FH
                INT 10H
                MOV AH, 00H
                INT 10H

                IN AL, 60H
                INT 90H
                MOV DI, 0A1H
                CMP AL, 0BH	; '0'
                JE STOP		; ESLI =
                DEC AL
                SHL AL, 4
              
        DRAW_COLOR:
                MOV ES:[DI], AL
                ADD DI, 2
                CMP DI, 141H
                JNE DRAW_COLOR
                JMP END_KEYBOARD
        STOP:
                MOV END_PROG, 1H
        END_KEYBOARD:
                POPF
		POP BX
                POP ES
        IRET

MYHANDLER_TIMER:
        STI     
		PUSH BX
                PUSH ES
                MOV AX, 0B800H
                MOV ES, AX
                MOV DI, 1
                CMP COUNTER, 6EH	;110 6 SEK
                JE ALLOW_KB
                CMP COUNTER, 37H	;55 3 SEK
                JE BLOCK_KB		;ESLI =
                INC COUNTER
                JMP SKIP
        ALLOW_KB:
                MOV COUNTER, 0H
                IN AL, 21H
                AND AL, 0FDH
                OUT 21H, AL
                MOV BL, 0H
                JMP DRAW_STATUS
        BLOCK_KB:
                IN AL,21H
                OR AL,2H
                OUT 21H,AL
                INC COUNTER
                MOV BL, 40H
        DRAW_STATUS:
                MOV ES:[DI], BL
                ADD DI, 2
                CMP DI, 0A1H
                JNE DRAW_STATUS
        SKIP:
                MOV AL, 20H
                OUT 20H, AL
                POP ES
		POP BX
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
