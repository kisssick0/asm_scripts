; Используя обработку прерывания часов реального времени (см.  1) и команду DIV деления нацело, реализовать секундомер с десятыми долями секунды следующего формата: <час (1 цифра)>.<минута (2 цифры)>.<секунда (2 цифры)>.<десятая доля секунды (1 цифра)>. 
; Для тестирования начать счет с 1 часа 59 минут 55 секунд 7 десятых секунды.

.model tiny
assume cs:mycode
assume ds:mydata
assume ss:mystack

mydata segment 
	number dw 7195d
	ms db 7
	how_times db 0
mydata ends

mycode segment
;  ------------ Polzovatelskii obrabotchik preryvaniya ---------
myhandler:
    sti    
    push ax bx cx dx si di es ds
	
    cmp how_times, 2d		;0.1 s
	jnz continue_j
	
	mov al, 0
	mov how_times, al
	
	mov ax, 0B800h
	mov es, ax
	
	inc ms
	cmp ms, 10d
	jnz skip
	mov ms, 0
	inc number
	jmp skip

continue_j:
	jmp continue
	
skip:
	mov cl, ms
	add cl, 030h
	mov ch, 036h
	mov di, 10
	mov es:[di], cx
	sub di, 2
	
	mov ax, number
	mov bl, 60d
	div bl
	mov al, ah
	mov ah, 0
	mov bl, 10d
	div bl
	mov cl, ah
	add cl, 030h
	mov es:[di], cx
	sub di, 2
	mov cl, al
	add cl, 030h
	mov es:[di], cx
	sub di, 2
	
	;mins
	mov ax, number
	mov bl, 60d
	div bl
	mov ah, 0
	div bl
	mov al, ah
	mov ah, 0
	mov bl, 10d
	div bl
	mov cl, ah
	add cl, 030h
	mov es:[di], cx
	sub di, 2
	mov cl, al
	add cl, 030h
	mov es:[di], cx
	sub di, 2
	
	;hours
	mov ax, number
	mov bl, 60d
	div bl
	mov ah, 0
	div bl
	add al, 030h
	mov ah, 036h
	mov es:[di], ax
	
	

continue:
	inc how_times
    pop ds es di si dx cx bx
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

    mov ax, 0
    mov es, ax

; ---------------------TIMER--------------------------
; 1. SOKHRANENIE SISTEMNOGO VEKTORA

    mov bx, es:[1Ch*4]
    mov bp, es:[1Ch*4+2]

; 2. PERENASTROIKA VEKTORA NA MOU PROTSEDURU
    cli
    mov word ptr es:[1Ch*4], offset myhandler
    mov word ptr es:[1Ch*4+2], seg myhandler
    sti
	
; 3. POLEZNAYA RABOTA
	mov cx, 0FFFFh

cycle1:
	mov dx, 0FFFFh
cycle2:
	dec dx
	jnz cycle2
	dec cx
	jnz cycle1

; 4. VOSSTANOVIT SISTEMNYI VECKTOR PRERYVANIYA 1CH --- timer
    cli
    mov word ptr es:[1Ch*4], bx
    mov word ptr es:[1Ch*4+2], bp
    sti
	
; ----------------- Vyhod v DOS -------------------------
    mov ax, 4C00h
    int 21h
mycode ends

.stack
mystack segment
    db 1000 dup(?)
mystack ends

end mystart
