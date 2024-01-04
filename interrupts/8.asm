; Используя обработку прерывания часов реального времени (см. 1), реализовать двоичный счетчик на шесть цифр. 
; Смена состояния индикатора должна выполняться раз в секунду.

.model tiny
assume cs:mycode
assume ds:mydata
assume ss:mystack

mydata segment 
   iterator db 0d
   number db 00000000b
   how_times db 0d
mydata ends

mycode segment
;  ------------ Polzovatelskii obrabotchik preryvaniya ---------
myhandler:
      push ax
      push es
      push di
      cmp iterator, 18d
      jnz toexit
      mov iterator, 0d
      inc number
      cmp number, 00111111b
      jz clear_number
continue_after_clear:
      mov ax, 0B800h
      mov es, ax
      mov di, 10
      mov ah, 26h
continue:
      mov al, number
      inc how_times
      cmp how_times, 7
      jz exit
      cmp how_times, 1
      jz continue_out1
      cmp how_times, 2
      jz continue_out2
      cmp how_times, 3
      jz continue_out3
      cmp how_times, 4
      jz continue_out4
      cmp how_times, 5
      jz continue_out5
      cmp how_times, 6
      jz continue_out6

toexit:
      jmp exit

continue_out1:
      and al, 00000001b
      jz res0
      jnz res1      

continue_out2:
      and al, 00000010b
      jz res0
      jnz res1

continue_out3:
      and al, 00000100b
      jz res0
      jnz res1

continue_out4:
      and al, 00001000b
      jz res0
      jnz res1

continue_out5:
      and al, 00010000b
      jz res0
      jnz res1

continue_out6:
      and al, 00100000b
      jz res0
      jnz res1

res1:
      mov al, 31h
      mov es:[di], ax
      sub di, 2
      jmp continue

res0:
      mov al, 30h
      mov es:[di], ax
      sub di, 2
     jmp continue

clear_number:
     mov number, 00000000b
     jmp continue_after_clear

exit:
       inc iterator
       mov how_times, 0
       pop di
       pop es
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
