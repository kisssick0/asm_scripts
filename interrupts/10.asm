; Используя обработку прерывания часов реального времени, реализовать шестнадцатеричный счетчик на одну цифру с циклическим смещением поля вывода. 
; Смена состояния индикатора должна выполняться раз в секунду.

.model tiny
assume cs:mycode
assume ds:mydata
assume ss:mystack

mydata segment 
	number db "0"
	sdvig dw 0
	how_times db 0
mydata ends

mycode segment
;  ------------ Polzovatelskii obrabotchik preryvaniya ---------
myhandler:
    sti    
    push ax bx cx dx si di es ds
	
    cmp how_times, 18d
	jnz continue
	
	mov how_times, 0
	
	mov ax, 0B800h
	mov es, ax
	mov ax, 0h
	add ax, sdvig
	mov di, ax
	
	mov ax, offset number
	mov si, ax
	mov ax, seg number
	mov ds, ax
	
	movsb 		;	 ds[si]->al
	
	cmp number, "9"
	jz to_letters
	                                                                                	
	cmp number, "F"
	jz clear_number
	jnz inc_number

to_letters:
	mov number, "A"
	jmp symbol_done
	
clear_number:
	mov number, "0"
	jmp symbol_done
	
inc_number:
	inc number
	jmp symbol_done
	
symbol_done:
	cmp sdvig, 0Ah
	jz clear_sdvig
	jnz inc_sdvig

clear_sdvig:
	mov sdvig, 0
	jmp continue
	
inc_sdvig:
	add sdvig, 2
	jmp continue

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
	mov cx, 0FF0h

cycle1:
	mov dx, 01FF0h
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
