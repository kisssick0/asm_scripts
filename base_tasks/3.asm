; Удалить все пробелы из строки 1. Результат вывести на экран.

ASSUME CS:MYCODE
ASSUME DS:MYDATA

MYDATA SEGMENT

MYSTR1 DB "Kozlova Alina",0
MYSTR2 DB "236fjs 2000", 0

MYDATA ENDS

MYCODE SEGMENT

MYENTRY:
; INITSIALIZATSIYA SEGMENTNOGO REGISTRA
MOV AX, MYDATA
MOV DS, AX		; DS --> MYDATA
; MOV AX, 0B800H
; MOV ES, AX    ; ES --> VIDEOBUFFER

; POLEZNAYA RABOTA
; INITSIALIZATSIYA
MOV BX, 00000H  ; ispolzuetsya dlya sohraneniya gde my byli do sdviga
MOV DI, 00000H  ; ukazatel po bukvam
MOV CX, 00000H  ; hranit bukvu
MOV SI, 00001H  ; ukazatel DI+1

METKA_INIT:
MOV DI, BX      ; vozvrat na pozitsiyu do sdviga

METKA:
MOV CL, DS:[MYSTR1+DI]   ; sohranyaem simvol v registr
CMP CL, 0       ; sravnivaem simvol c kontscom stroki
JZ VYVOD_INIT   ; esli eto konets, vyvodim
CMP CL, 32      ; sravnivaem s probelom
JZ SDVIG_INIT   ; esli eto probel, sdvigaem
INC DI          ; perehodim na sleduyuschuyu bukvu
JMP METKA       ; 

SDVIG_INIT:
MOV BX, DI      ; sohranyaem gde my byli do nachala sdviga
MOV AX, DS
MOV ES, AX
MOV SI, DI
INC SI

SDVIG:
MOV AL, DS:[MYSTR1+DI] 	; AL = ASCII KOD BUKVY
CMP AL, 0		        ; KONETS STROKI
MOVSB                   ; ES:[MYSTR+DI] <-- DS:[MYSTR+SI] 
JNZ SDVIG       ;
MOVSB
JZ METKA_INIT   ; 

VYVOD_INIT:
MOV AX, 0B800H  ;
MOV ES, AX		; ES --> VIDEOBUFFER
MOV SI, 0
MOV BX, 1654
VYVOD:
MOV AL, DS:[MYSTR1+SI] 	; AL = ASCII KOD BUKVY
CMP AL, 0		; KONETS STROKI
JZ KONETS       ;
MOV AH, 0EH	         	; AH = TSVET
MOV ES:[BX], AX		; AX --> videobufer
INC SI          ;
INC BX          ;
INC BX          ;
JMP VYVOD       ;

; ZAVERSHENIE PROGRAMMY
KONETS:         ;
MOV AX, 4C00H   ;
INT 21H         ;

MYCODE ENDS

END MYENTRY
