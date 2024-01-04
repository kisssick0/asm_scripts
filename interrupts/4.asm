; COM-порт – это микросхема, которая позволяет передавать  данные на удаленный компьютер по каналу связи. 
; У него есть два программно доступных регистра: регистр передатчика THR (доступен через порт 2F8h на запись) и регистр приемника RBR (доступен через порт 2F8h на чтение). 
; Для отправки данных в канал связи достаточно записать их в регистр передатчика THR. 
; При поступлении данных из канала связи COM-порт вызывает прерывание 0Bh (IRQ3), в обработчике прерывания процессор может прочитать принятые данные из регистра приемника RBR. 
; COM-порт имеет особый диагностический режим, в котором данные, отправляемые в канал связи из регистра передатчика THR, мгновенно возвращаются из канала в регистр приемника RBR, также вызывая прерывание. 

; Необходимо разработать программу, которая вызывает выданную подпрограмму настройки COM-порта на работу в диагностическом режиме, перенастраивает вектор прерывания 0Bh на пользовательский обработчик прерывания, в цикле отправляет все символы строки  “Hello, world!” в COM-, затем возвращает вектор прерывания 0Bh в исходное состояние. 
; После отправки каждого символа необходимо реализовать задержку 0,5 секунды перед отправкой следующего символа. 
; После отправки символа он по обратной связи поступает на вход COM-порта, что приводит к вызову прерывания COM-порта. 
; При каждом вызове пользовательского обработчика необходимо считывать принятый символ из регистра приемника и выводить его на экран.

.model tiny
assume cs:mycode
assume ds:mydata
assume ss:mystack

mydata segment 
	how_times db 15d
	mystring db "HELLO, WORLD!", 0
	first_call db 1
mydata ends

mycode segment
myCOM:
    push bx
    push dx
    push es
    cmp first_call, 1
    jz ext
   
    mov dx, 2F8h
    in al, dx
print:
    mov dx, 0b800h
    mov es, dx
    mov ah, 26h 
    stosw ; mov es:[di], ax add di, 2
ext:
    mov first_call, 0
    mov al, 20h
    out 20h, al
    pop es
    pop dx
    pop bx
    iret


; Initsializatsiya COM-porta
initialize:
        ; 1. Ustanovka skorosti peredachi
        mov dx, 2FBh  
        in al, dx
        or al, 10000000b
        out dx, al

        mov dx, 2F8h
        mov al, 01100000b ; mladshii bait delitelya chastoty
        out dx, al
        inc dx
        mov al, 00000000b ; starshii bait delitelya chastoty
        out dx, al

        mov dx, 2FBh
        in al, dx
        and al, 01111111b
        out dx, al

        ; 2. Ustanovka formata asinhronnoy posylki
        mov dx, 2FBh
        mov al, 00011111b
        out dx, al

        ; 3. Vklyuchit diagnosticheskii rezhim i razreshit COM-portu
        ; vyrabatyvat zaprosy na preryvanie
        mov dx, 2FCh
        mov al, 00011000b
        out dx, al

        ; 4. Razreshit COM-portu formirovat zaprosy na preryvanie po priemu
        mov dx, 2F9h
        mov al, 00000010b 
        out dx, al

        ; 5. Razreshaem obrabotku preryvaniya v kontrollere preryvanii
        in al, 21h
        and al, 11110111b
        out 21h, al
        
        ret
; --------------START--------------
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

    call initialize

; ----------COM----------
    ; 1. SOKHRANENIE SISTEMNOGO VEKTORA
    MOV BX, ES:[0Bh*4] ; SMESTCHENIE --> BX
    MOV BP, ES:[0Bh*4+2]; SEGMENT --> BP
    

    ; 2. PERENASTROIKA VEKTORA NA MOU PROTSEDURU
    CLI
    MOV ES:[0Bh*4], OFFSET myCOM
    MOV ES:[0Bh*4+2], SEG myCOM
    STI

    ; 3. POLEZNAYA RABOTA
SEND_LETTER:
    dec how_times
    cmp how_times, 0
    jz EXIT
    lodsb ; mov al, ds:[si] + inc si
    mov dx, 2F8h
    out dx, al
    MOV CX, 00FFH
CYCLE1:
    MOV DX, 0AFFH
CYCLE2:
    DEC DX
    JNZ CYCLE2
    DEC CX
    JZ SEND_LETTER
    JNZ CYCLE1

EXIT:
    ; 4. VOSSTANOVIT SISTEMNYI VECTOKTOR PRERYVANIYA --- COM
    CLI
    MOV ES:[0Bh*4], BX
    MOV ES:[0Bh*4+2], BP
    STI

    ; Vyhod v DOS
    mov ax, 4C00h
    int 21h
mycode ends

.stack
mystack segment
          db 1000 dup(?)  ; zadayom razmer  steka v 1000 bait
mystack ends
end mystart

