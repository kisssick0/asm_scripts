; Реализовать обработку прерываний от таймера (см. 1) и от клавиатуры (см. 2). 
; По прерыванию таймера через каждую секунду весь экран должен закрашиваться в однотонный цвет. 
; Цвета должны переключаться каждую секунду в порядке следования цветов радуги. 
; При нажатии клавиши '0' на клавиатуре программа должна завершаться. 

.model tiny
assume cs:mycode
assume ds:mydata
assume ss:mystack

mydata segment 
how_times db 0
color db 0
endprog db 0
mydata ends

mycode segment
; Polzovatelskii obrabotchik preryvaniya
myhandler_keyboard:
    sti
    IN AL, 60H  ; KOD NAZHATOI KLAVISHI --> AL
    INT 90H     ; VYZOV SISTEMNOI PROTSEDURY
    cmp al, 0Bh
    jnz endx
    mov al, 1
    mov endprog, al
endx:
    mov al, 20h
    out 20h, al
    iret

myhandler_timer:
    sti
    mov ax, mydata
    mov ds, ax
    mov al, how_times
    mov ah, color
    mov bx, 0b800h
    mov ds, bx
    CMP al, 18h
    jnz again
    mov al, 0
    ; <Kod obrabotchika preryvaniya v sootvetstvii s zadaniem>
    CMP AH, 0h
    JZ kras
    CMP AH, 1h
    JZ oran
    CMP AH, 2h
    JZ jelt
    CMP AH, 3h
    JZ zel
    CMP AH, 4h
    JZ gol
    CMP AH, 5h
    JZ sin
    CMP AH, 6h
    JZ fiol

kras: INC AH 
      mov BH, 4Fh
      JMP zakrash
      
oran:  INC AH 
      mov BH, 0EFh
      JMP zakrash

jelt:  INC AH 
      mov BH, 07Fh
      JMP zakrash

zel:   INC AH 
      mov BH, 2Fh
      JMP zakrash

gol:   INC AH 
      mov BH, 3Fh
      JMP zakrash

sin:  INC AH 
      mov BH, 1Fh
      JMP zakrash

fiol:  MOV AH,0   
      mov BH, 0DFh
      JMP zakrash

zakrash: mov bl, 20h
	 mov si,0
	 mov cx, 7D0h
cycle:	 CMP cx, 0
	 JZ endz
	 mov ds:[si], bx
	 ADD si,2 
	 DEC cx
	 JMP cycle

again:  inc al
endz:   mov bx, mydata
        mov ds, bx
	mov how_times, al
	mov color, ah
	mov al, 20h
        out 20h, al
    iret

; Tochka vhoda v programmu
mystart:        
    mov ax, mydata
    mov ds, ax 
    mov ax, mystack
    mov ss, ax
    mov sp, 0       
    mov ax, 0
    mov es, ax



    ; 1. SOKHRANENIE SISTEMNOGO VEKTORA
    MOV BX, ES:[1CH*4] 		; SMESTCHENIE --> BX
    MOV BP, ES:[1CH*4+2]	; SEGMENT --> BP

    
    ; 2. PERENASTROIKA VEKTORA NA POLZAVAT. PROTSEDURU
    CLI
    MOV WORD PTR ES:[1CH*4], OFFSET MYHANDLER_TIMER
    MOV WORD PTR ES:[1CH*4+2], SEG MYHANDLER_TIMER
    STI

    ; 1A. SOKHRANENIE SISTEMNOGO VEKTORA 09H
    MOV CX, ES:[09H*4] 		; SMESTCHENIE --> CX
    MOV DX, ES:[09H*4+2]	; SEGMENT --> DX

    ; 1B. NASTROIKA VEKTORA 90H NA SISTEMNUI PROTSEDURU
    CLI
    MOV ES:[90H*4], CX
    MOV ES:[90H*4+2], DX
    STI
    
    ; 2A. PERENASTROIKA VEKTORA 09H NA POLZAVAT. PROTSEDURU
    CLI
    MOV WORD PTR ES:[09H*4], OFFSET MYHANDLER_KEYBOARD
    MOV WORD PTR ES:[09H*4+2], SEG MYHANDLER_KEYBOARD
    STI


    ; 3. POLEZNAYA RABOTA
CYCLE1: 
       cmp endprog, 1
       jnz cycle1

    ; 4A. VOSSTANOVIT SISTEMNYI VECTOKTOR PRERYVANIYA
    CLI
    MOV ES:[1CH*4], BX
    MOV ES:[1CH*4+2], BP
    STI

    ; 4B. VOSSTANOVIT SISTEMNYI VECKTOR PRERYVANIYA 09H
    CLI
    MOV ES:[09H*4], CX
    MOV ES:[09H*4+2], DX
    STI

    ; Vyhod v DOS
    mov ax, 4C00h
    int 21h
mycode ends

.stack
mystack segment
          db 1000 dup(?)
mystack ends

end mystart


