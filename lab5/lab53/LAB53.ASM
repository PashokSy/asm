;* СОЗДАНИЕ СЕГМЕНТА СТЭКА *
STACKSEG SEGMENT PARA STACK "STACK"
	     DW      32   DUP(0)
STACKSEG ENDS
;* СОЗДАНИЕ СЕГМЕНТА ДАННЫХ *
DSEG SEGMENT PARA PUBLIC "DATA"
							  ; ПРОМЕЖУТОЧНЫЕ ПЕРЕМЕННЫЕ ДЛЯ УРАВНЕНИЙ
	X 	  DW ?
	REZ	  DW ?
	REZ2  DW ?
	
	FL    DB 0 				  ; ФЛАГ НЕГАТИВНОГО(1)/ПОЗИТИВНОГО(0) ЧИСЛА
	DUMP  DB 5, ?, 4 DUP('?') ; СТРУКТКРА ДАННЫХ ДЛЯ ХРАНЕНИЯ ВВОДА
	ERRCD DB 0				  ; ФЛАГ ОШИБКИ
							  ; 0 - ОШИБОК НЕТ
							  ; 1 - ОШИБКА	
	ERRTXT  DB '*ERROR*'
			DB ' - SOMETHING WENT WRONG$'
	MSGTXT  DB 'ENTER YOUR NUMBER:$'
	MSG2TXT DB 'ANSWER:  $'
	CELOETXT   DB 'CELOE:   $'
	OSTATOKTXT DB 'OSTATOK: $'
DSEG ENDS
;--------------------------------------------------------------------------
INCLUDE MACROSI.ASM
;--------------------------------------------------------------------------
;* СОЗДАНИЕ СЕГМЕНТА КОДА *
CSEG     SEGMENT PARA PUBLIC "CODE"
;* НАЧАЛО ОСНОВНОЙ ПРОЦЕДУРЫ
 MAIN 	 PROC    FAR
         ASSUME  CS: CSEG, DS: DSEG, SS: STACKSEG	
	MAGIC		DSEG
    	
	PRINTF		MSGTXT
	NEWLINE
	
	INPUT		DUMP,ERRCD,X,FL
	
	CMP			ERRCD,1
	JNE			NO_ERROR
	NEWLINE
	PRINTF		ERRTXT		;ИНАЧЕ ВЫВЕСТИ СООБЩЕНИЕ ОБ ОШИБКЕ
	MOV			AX,4C00H
	INT			21H
	NO_ERROR:
	
	NEWLINE
	PRINTF		MSG2TXT			;'ANSWER'
	NEWLINE
	
	
	; ПРОВЕРКА ТРЕТЬЕГО УСЛОВИЯ X<0
	CMP			FL,1				; X < 0
	JNE			NOEQ3				;ЕСЛИ НЕ МЕНЬШЕ 0 ПРЫГНУТЬ
									;ИНАЧЕ
	EQUATION3	X,REZ,REZ2			;НАЙТИ РЕЗУЛЬТАТ
	CALL		PRINT_RESULT		;ВЫВЕСТИ РЕЗУЛЬТАТ
	NOEQ3:
	;*
	
	; ПРОВЕРКА ВТОРОГО УСЛОВИЯ X = 0
	CMP			X,0					
	JNE			NOEQ2				;ЕСЛИ НЕ РАВНО 0, НЕ ВЫПОЛНЯТЬ
	EQUATION2	REZ
	OUTPUT		REZ
	NOEQ2:
	;*
	
	; ПРОВЕРКА ТРЕТЬЕГО УСЛОВИЯ X>0
	CMP			X,0
	JE			NOEQ1
	JL			NOEQ1
	CMP			FL,1
	JE			NOEQ1
	EQUATION1	X,REZ,REZ2
	CALL		PRINT_RESULT		;ВЫВЕСТИ РЕЗУЛЬТАТ
	NOEQ1:
	;*		
	
	RET		;ВОЗВРАЩАЕМ УПРАВЛЕНИЕ ВЫЗЫВАЮЩЕЙ ПРОЦЕДУРЕ
 MAIN ENDP
;* КОНЕЦ ОСНОВНОЙ ПРОЦЕДУРЫ 
;--------------------------------------------------------------------------
PRINT_RESULT PROC	
	PRINTF		CELOETXT	
	OUTPUT		REZ
	NEWLINE
	PRINTF		OSTATOKTXT
	OUTPUT		REZ2
	MOV			AL,'/'
	INT			29H
	OUTPUT		X
	
	RET
ENDP

CSEG ENDS   ; КОНЕЦ СЕГМЕНТА КОДА
END MAIN	; ВЫХОД ИЗ ПРОГРАММЫ
