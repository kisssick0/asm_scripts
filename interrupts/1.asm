; Таймер (часы реального времени) – это микросхема, которая вырабатывает запросы прерывания по линии IRQ0 с частотой 18,2 Гц (через каждые 55 миллисекунд). 
; При каждом запросе вызывается системный обработчик прерывания 08h (IRQ0), внутри системного обработчика программным способом вызывается прерывание 1Ch. 
; По умолчанию вектор прерывания 1Ch указывает на пустой обработчик прерывания, который ничего не делает, сразу возвращается. 

; Требуется разработать пользовательский обработчик прерывания 1Ch. 
; При каждом 18-м вызове пользовательского обработчика необходимо выводить на экран очередной символ строки “Hello, world!”. 
; Главная программа должна перенастраивать вектор прерывания 1Ch на пользовательский обработчик, ожидать вывода всех символов строки на экран, а затем восстанавливать исходное значение вектора прерывания 1Ch и завершаться.

.model tiny
assume cs:mycode
assume ds:mydata
assume ss:mystack


mydata segment 
  how_times db 13d
  iterator db 18d
  mystring db "HELLO, WORLD!", 0	
mydata ends


mycode segment
;  ------------ Polzovatelskii obrabotchik preryvaniya ---------
myhandler:
    ;sti
    push ax
    dec iterator
    cmp iterator, 0
    jnz skip
    cmp how_times, 0
    jz skip
    dec how_times
    mov iterator, 18d
    lodsb
print:
    push es
    push dx
    mov dx, 0b800h
    mov es, dx
    mov ah, 26h
    stosw	; mov es:[di], ax add di, 2
    pop dx
    pop es

skip:
    mov al, 20h
    out 20h, al
    pop ax
    iret

; ------------ Tochka vhoda v programmu ------------------------
mystart:        
    mov ax, mydata
    mov ds, ax        
    mov ax, 0
    mov es, ax
    mov ax, mystack
    mov ss, ax
    mov sp, 0
    mov di, 0
    mov si, offset mystring


; ---------------------TIMER--------------------------
    ; 1. SOKHRANENIE SISTEMNOGO VEKTORA
    MOV BX, ES:[1CH*4] 		; SMESTCHENIE --> BX
    MOV BP, ES:[1CH*4+2]	; SEGMENT --> BP
    


    ; 2. PERENASTROIKA VEKTORA NA MOU PROTSEDURU
    CLI
    MOV ES:[1CH*4], OFFSET MYHANDLER
    MOV ES:[1CH*4+2], SEG MYHANDLER
    STI

    ; 3. POLEZNAYA RABOTA
    MOV CX, 0140H	;0113H
CYCLE1:
    MOV DX, 0FFFFH
CYCLE2:
    DEC DX
    JNZ CYCLE2
    DEC CX
    JNZ CYCLE1

    ; 4. VOSSTANOVIT SISTEMNYI VECKTOR PRERYVANIYA 1CH --- timer
    CLI
    MOV ES:[1CH*4], BX
    MOV ES:[1CH*4+2], BP
    STI

    ; ----------------- Vyhod v DOS -------------------------
    mov ax, 4C00h
    int 21h
mycode ends

.stack
mystack segment
          db 1000 dup(?)  ; razmer steka 1000 bait
mystack ends

end mystart
