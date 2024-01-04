; При нажатии клавиши на клавиатуре вызывается аппаратное прерывание 09h (IRQ1). 
; Изначально вектор 09h указывает на системный обработчик прерывания клавиатуры. 

; В главной программе необходимо настроить неиспользуемый вектор прерывания 90h на системный обработчик прерывания, а вектор прерывания 09h на пользовательский обработчик прерывания, реализовать цикл ожидания в течение 10 с, затем восстановить вектор прерывания 09h в исходное состояние.
; Разработать пользовательский обработчик прерывания клавиатуры, который считывает код нажатой клавиши из порта 60h, для клавиш с цифрами ‘1’, ‘2’, ‘3’, ‘4’, ‘5’, ‘6’, ‘7’, ‘8’, ‘9’ выводит соответствующий символ на экран, затем записывает код нажатой клавиши в регистр al и вызывает прерывание 90h программным способом.

.MODEL TINY
ASSUME CS:MYCODE
ASSUME SS:MYSTACK

MYCODE SEGMENT
MYHANDLER:    
                PUSH ES
		PUSH BX
                MOV AX, 0B800H
                MOV ES, AX

                ;MOV AH, 0FH
                ;INT 10H
                ;MOV AH, 00H
                ;INT 10H
		
		MOV AH, 26H
                IN AL, 60H
                INT 90H
                MOV DI, 0
		DEC AL
		ADD AL, '0'
		CMP AL, '1'
		JZ VIDEO
		CMP AL, '2'
		JZ VIDEO
		CMP AL, '3'
		JZ VIDEO
		CMP AL, '4'
		JZ VIDEO
		CMP AL, '5'
		JZ VIDEO
		CMP AL, '6'
		JZ VIDEO
		CMP AL, '7'
		JZ VIDEO
		CMP AL, '8'
		JZ VIDEO
		CMP AL, '9'
		JZ VIDEO
SKIP:
		POP BX
                POP ES
    		MOV AL, 20H
		OUT 20H, AL
		IRET
VIDEO:
		MOV ES:[DI], AX
		JMP SKIP

MYENTRY:
	; 1. INITSIALIZATSIYA SEGMENTNYKH REGISTROV
        MOV AX, MYSTACK
        MOV SS, AX
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

	; 5. POLEZNAYA RABOTA
    	MOV CX, 0FFFH
CYCLE1:
    	MOV DX, 0F0FH
CYCLE2:
    	DEC DX
    	JNZ CYCLE2
    	DEC CX
    	JNZ CYCLE1


	; 6. VOSSTANOVLENIE SYSTEMNOGO VEKTORA 09H
        CLI
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
