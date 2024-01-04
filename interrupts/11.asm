; Используя обработку прерывания часов реального времени (см. 1), реализовать бегущую строку, в которой три одинаковых шестнадцатиричных цифры двигаются из стороны в сторону. 
; При касании правой границы индикатора все три цифры инкрементируются. 
; Смена состояния индикатора должна выполняться раз в секунду.

.model tiny
assume cs:mycode
assume ds:mydata
assume ss:mystack

mydata segment 
	number db "0"
	sdvig dw 0
	how_times db 0
	direction db 0
mydata ends

mycode segment
;  ------------ Polzovatelskii obrabotchik preryvaniya ---------
myhandler:
    sti    
    push ax bx cx dx si es ds
	
    cmp how_times, 18d
	jnz to_exit
	
	mov how_times, 0

	mov ah, 0fh
        int 10h
        mov ah, 00h
        int 10h

	mov ax, 0B800h
	mov es, ax
	
	mov al, number
	mov ah, 026h
	
	cmp direction, 0
	jnz left
right:
	mov es:[di], ax
	add di, 2
	mov es:[di], ax
	add di, 2
	mov es:[di], ax
	jmp compare_right
left:
	mov es:[di], ax
	sub di, 2
	mov es:[di], ax
	sub di, 2
	mov es:[di], ax
	
	cmp di, 0
	jnz skip
	mov bl, 0
	mov direction, bl
	add di, 2
	jmp exit
skip:
	add di, 2
to_exit:
	jmp exit

compare_right:
	cmp di, 10
	jz incr
	sub di, 2
	jmp exit

incr:
	mov bl, 1
	mov direction, bl
	inc number

	cmp number, ':'
	jz to_letters
	                                                                                	
	cmp number, "G"
	jz clear_number
	jmp exit

to_letters:
	mov number, "A"
	jmp exit
	
clear_number:
	mov number, "0"
	jmp exit
exit:
	inc how_times
    	pop ds es si dx cx bx
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
	mov cx, 01FF0h
cycle1:
	mov dx, 0FFFh
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