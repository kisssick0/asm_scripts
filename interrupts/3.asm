; Когда процессор встречает в программе команду деления на ноль, он вызывает прерывание 00h. 
; Вектор прерывания 00h указывает на системный обработчик прерывания деления на ноль. 

; В главной программе требуется перенастроить вектор прерывания 00h на пользовательский обработчик прерывания и выполнить команду деления на ноль. 
; В пользовательском обработчике прерывания вывести на экран в шестнадцатиричной системе счисления адрес команды, вызвавшей прерывание 00h (его можно считать со стека), восстановить вектор 00h в исходное состояние и завершить программу выходом в DOS.

.model tiny
assume cs:mycode
assume ss:mystack

mycode segment
;-----------------Polzovatelskii obrabotchik preryvaniya----------
myhandler:
   sti
   mov si, sp
   mov ax, ss:[si] 	
   mov cx, 0b800h
   mov ds, cx 		
   mov si, 8 		
   mov cl, 4		

cycle:
   mov dx, 000fh	
   and dx, ax
   add dl, '0'
   cmp dl, '9'
   jle metka1		; jump if dl >= '9'
   add dl, 7

metka1:
   mov dh, 0EH		
   mov ds:[si], dx	
   shr ax, cl		
   sub si, 2		
   JNZ cycle

   mov al, 20h
   out 20h, al
   iret			

; -----------Tochka vhoda v programmu----------------------
mystart:
   mov ax, 0
   mov es, ax		; es -> vector table
   mov ax, mystack
   mov ss, ax		
   mov sp, 0


; SAVE VECTOR 00h
   mov bx, es:[00h*4] 		; SYSTEM VECTOR -> BX
   mov bp, es:[00h*4+2] 	; STSEM VECTOR -> BP

; CHANGE VECTOR SYSTEM TO MYHANDLER
   cli
   mov word ptr es:[00h*4], offset myhandler
   mov word ptr es:[00h*4+2], seg myhandler
   sti

; POLEZNAYA RABOTA

;DELAY
mov cx, 0fh
cycle1:
	mov dx, 0ffffh
cycle2:
	dec dx
	jnz cycle2
	dec cx
	jnz cycle1

; INTERRUPT div 0
   mov ax, 5
   mov dl, 0
   div dl 			; AX div DL --> INTERRUPT (MYHANDLER)

; RECHANGE VECTOR MYHANDLER TO SYSTEM
   cli
   mov ax, 0
   mov es, ax		
   mov es:[00h*4], bx
   mov es:[00h*4+2], bp
   sti

; Vyhod v DOS
   mov ax, 4C00h
   int 21h
mycode ends

.stack
mystack segment
   db 1000 dup(?)
mystack ends
end mystart
