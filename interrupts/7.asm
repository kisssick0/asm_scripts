; Используя обработку прерывания часов реального времени (см. Вариант 1), реализовать десятичный счетчик на 4 цифры (использовать команду DAA после команды сложения). 
; Начальное значение счетчика равно 0. Шаг счетчика должен задаваться в программе константой в диапазоне 1..255. 
; Смена состояния индикатора должна выполняться раз в секунду.
Команда DAA позволяет перевести результат сложения чисел, в двоично-десятичный код. 



.model tiny
assume cs:mycode
assume ds:mydata
assume ss:mystack

mydata segment 
	number dw 0h
	step db 03h
	how_times db 0h
	iterator db 08h
mydata ends

mycode segment
myhandler:
	push ax bx cx dx es di
	inc how_times
	cmp how_times, 18d
	jnz exit

	mov how_times, 0h
	mov bx, 0b800h
	mov es, bx
	mov di, 06h
	cmp number, 270fh
	jle skip_clear
	mov number, 0h
skip_clear:
	mov ax, number
	mov bx, 03h
	add number, bx
	add al, 03h
	daa
	mov bh, 026h
	mov bl, al
	and bl, 000Fh
	add bl, 030h
	mov es:[di], bx
	mov bl, al
	and bl, 00F0h
	shr bl, 4
	add bl, 030h
	sub di, 2
	mov es:[di], bx

exit:
	pop di es dx cx bx
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
	mov cx, 0FFFh

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
