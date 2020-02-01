;* СОЗДАНИЕ СЕГМЕНТА СТЭКА *
STACKSEG SEGMENT PARA STACK "STACK"
	     DW      32   DUP(0)
STACKSEG ENDS
;* СОЗДАНИЕ СЕГМЕНТА ДАННЫХ *
DSEG SEGMENT PARA PUBLIC "DATA"
	MES1 DB	 	0DH,"START ARRAY: $"
	MES2 DB	 	0DH,"SORTED ARRAY - $"
	MES3 DB		0DH,"ELEMENT SUM  - $"
	MES4 DB		0DH,"MAX ELEMENT  - $"
	MES5 DB		0DH,"ENTER YOUR ARRAY:$"
	MES6 DB		0DH,"ENTER YOUR NUMBER FOR SEARCH:$"
	MES7 DB		0DH,"COORDINATES FOUND: $"
	MES8 DB		"( $"
	MES9 DB		" ; $"
	MES10 DB	" ) $"
	MES11 DB	" $"
	N 	 EQU	16
	MAS  DW 	17 DUP (?)
	SRTMAS DW	17 DUP (?)
	SRCH DW 	?
	TMP  DW 	?
	OUTPT DW	?
	I	 DW		0
	J	 DW 	0
DSEG ENDS
;--------------------------------------------------------------------------
INCLUDE LB54.ASM
;--------------------------------------------------------------------------
;* СОЗДАНИЕ СЕГМЕНТА КОДА *
CSEG     SEGMENT PARA PUBLIC "CODE"
;* НАЧАЛО ОСНОВНОЙ ПРОЦЕДУРЫ
 MAIN 	 PROC    FAR
         ASSUME  CS: CSEG, DS: DSEG, SS: STACKSEG		 
   MAGIC	DSEG
   
   ;ВВОД МАССИВА
   PRINTF		MES5   
   NEWLINE
   INPUT		MAS,N
   COPY_ARRAY   SRTMAS,MAS
   NEWLINE
   ;*
   
   NEWLINE
   PRINTF		 MES1
   NEWLINE
   OUTPUT_MATRIX MAS,N
   NEWLINE
   NEWLINE
   
   ; ПОДСЧЕТ СУММЫ ЭЛЕМЕНТОВ И ВЫВОД НА ЭКРАН
   ARRAY_SUM	MAS,N,TMP 
   PRINTF		MES3
   OUTPUT		TMP
   ;*   
   NEWLINE
   
   ; НАХОЖДЕНИЕ МАКСИМАЛЬНОГО ЭЛЕМЕНТА И ВЫВОД НА ЭКРАН
   ARRAY_MAX	MAS,TMP
   PRINTF   	MES4
   OUTPUT		TMP
   ;*
   NEWLINE
   
   ; СОРТИРОВКА МАСИВА И ВЫВОД НА ЭКРАН
   ARRAY_SORT	SRTMAS,N		; БЕЗ 'ПУЗЫРЬКА' НЕ РАЗОБРАТЬСЯ
   PRINTF		MES2
   OUTPUT_ARRAY	SRTMAS,N
   NEWLINE
   NEWLINE
   ;*
   
   ; ПОЛУЧИТЬ ПОИСКОВЫЙ
	PRINTF	MES6				; ПОПРОСИТЬ ВВЕСТИ ПОИСКОВЫЙ
	NEWLINE						; ПЕРЕВЕСТИ КАРЕТКУ
	INPUT_POISKOVIY	SRCH		; ПОЛУЧИТЬ ОТ ПОЛЬЗОВАТЕЛЯ ПОИСКОВЫЙ
	NEWLINE						; ПЕРЕВЕСТИ КАРЕТКУ
	;*
	
	; НАЙТИ КООРДИНАТЫ ВХОЖДЕНИЯ	
	PRINTF	MES7				; "ENTRY FOUND"
	CALL	FIND_COORDINATES	;НАЙТИ ВХОЖДЕНИЯ И ВЫВЕСТИ ИХ НА ЭКРАН	
	NEWLINE						; ПЕРЕВЕСТИ КАРЕТКУ	
	;*
	
	RET		;ВОЗВРАЩАЕМ УПРАВЛЕНИЕ ВЫЗЫВАЮЩЕЙ ПРОЦЕДУРЕ
 MAIN ENDP
 ;* КОНЕЦ ОСНОВНОЙ ПРОЦЕДУРЫ  

;--------------------------------------------------------------------------
 FIND_COORDINATES PROC 
	MOV		I,0				; НАЧАТЬ С ПЕРВОГО ЭЛЕМЕНТА
	MOV		J,0
	MOV		CX,16			; 16 ЭЛЕМЕНТОВ В МАССИВЕ
	
   FORLOOP:
	; ПРЕОБРАЗОВАТЬ 'I' 
	MOV		BX,I
	MOV		AX,8			; (4*2) 4 ДЛИНА РЯДКА, 2 ИЗ-ЗА DW 
	MUL 	BX
	MOV		BX,AX
	; ПРЕОБРАЗОВАТЬ 'J' 
	MOV		SI,J
	SHL		SI,1
	
    MOV		AX,MAS[BX+SI]		; ВЗЯТЬ ЭЛЕМЕНТ МАССИВА ПО АДРЕСУ
	MOV		BX,SRCH	
	CMP		J,4
	JNE	   CONTINUE_LINE
	MOV		J,0
	ADD		I,1
   CONTINUE_LINE:
	CMP		AX,BX				; СРАВНИТЬ С ПОИСКОВЫМ
	JNE	   NOT_PRINT_COORD		; ЕСЛИ НЕ СОВПАЛИ ПЕРЕПРЫГУНТЬ ВЫВОД КООРДИНАТЫ НА ЭКРАН
	
	MOV		TMP,CX				; 'OUTPUT_PROC' ЗАТИРАЕТ 'CX'
	;ВЫВОД КООРДИНАТЫ НА ЭКРАН
	NEWLINE	
	PRINTF	MES8				; "( "	
	MOV		AX,I				; 'OUTPUT_PROC' РАБОТАЕТ С 'AX'
	INC		AX					; НЕ ПРОГРАММИСТСТСТСКАЯ КООРДИНАТА
	CALL	OUTPUT_PROC			; ВЫВОДИТ ЦИФРУ
	PRINTF	MES9				; " ; "
	MOV		AX,J				; 'OUTPUT_PROC' РАБОТАЕТ С 'AX'
	INC		AX					; НЕ ПРОГРАММИСТСТСТСКАЯ КООРДИНАТА
	CALL	OUTPUT_PROC			; ВЫВОДИТ ЦИФРУ
	PRINTF	MES10				; " )"
	;*
	MOV		CX,TMP				; ВОЗВРАЩАЕТСЯ СЧЕТЧИК	
	
   NOT_PRINT_COORD:	
    ADD		J,1
	LOOP	FORLOOP
		
	RET
 FIND_COORDINATES ENDP
;-------------------------------------------------------------------------- 
OUTPUT_PROC PROC
	OUTPUT AX

	RET
OUTPUT_PROC ENDP
;--------------------------------------------------------------------------	   

CSEG ENDS   ; КОНЕЦ СЕГМЕНТА КОДА
END MAIN	; ВЫХОД ИЗ ПРОГРАММЫ
