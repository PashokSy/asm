MAGIC MACRO	DSEG
	;* MAGIC * (РАЗМЕЩЕНИЕ ПРОГРАММЫ В ПАМЯТИ?)
	PUSH     DS
	MOV 	 AX, 0
	PUSH 	 AX
	MOV 	 AX, DSEG       ; *ИНИЦИАЛИЗАЦИЯ СЕГМЕНТНОГО
	MOV 	 DS, AX         ;  РЕГИСРА 'DS'*
   ;* MAGIC END'S *
ENDM

PRINTF	MACRO	STRING
	MOV	AH,9			; Функция вывода строки
	LEA	DX,STRING		; Загружаем адрес строки
	INT	21H 			; Вызов прерывания DOS
ENDM

NEWLINE	MACRO	
	MOV	AL,0AH
	INT 29H
ENDM

INPUT	MACRO DUMP,ERRCD,X,FL
	MOV ERRCD,0  		; ОБНУЛЕНИЕ КОДА ОШИБКИ
   ;* ВВОД ДАННЫХ С КЛАВИТУРЫ *
	LEA 	 DX,DUMP	; РАЗМЕЩЕНИЕ В 'DX' СТРУКТУРЫ 'DUMP'
	MOV 	 AH,10		; КОД '10' ПРЕРЫВНИЯ 21..
	INT 	 21H		; ..ОТВЕЧАЕТ ЗА ВВОД ДАННЫХ С КЛАВИАТУРЫ
   ;* КОНЕЦ ПРОЦЕДУРЫ "ВВОДА ДАННЫХ"
   ;* ОПРЕДЕЛЕНИЕ КОЛ-ВА ВВЕДЕНЫХ СИМОВЛОВ
	LEA 	 SI,DUMP+1 	; РАЗМЕЩЕНИЕ В 'SI' АДРЕСА С КОЛ-ВОМ ВВЕДЕНЫХ ЗНАКОВ
	XOR 	 CX,CX		; ОБНУЛЕНИЕ СЧЕТЧИКА
	MOV 	 CL,[SI]	; "УСТАНОВКА" СЧЕТЧИКА
	CMP 	 CX,0		; *ЕСЛИ НИЧЕГО НЕ ВВЕДЕНО
	JE 		SOME_ERR    ; ВЫВЕСТИ КОД ОШИБКИ
   ;* ОПРЕДЕЛЕНИЕ ПОЗИТИВНОСТИ ЧИСЛА
	MOV 	 FL,0		; ДЛЯ СБРОСА ФЛАГА ПОЗ/НЕГ ЧИСЛА
	INC 	 SI			; *ПЕРЕХОД С КОЛ-ВА ВВЕДЕНЫХ СИМВОЛОВ
						;  НА ПЕРВЫЙ ВВЕДЕННЫЙ СИМВОЛ.
	MOV 	 AL,[SI]	;  РАЗМЕЩЕНИЕ ЕГО В РЕГИСТР ДЛЯ ОБРАБОТКИ.
	CMP 	 AL,'-'		;  ПРОВЕРКА МИНУС ЛИ ЭТО.
	JNE 	NO_MINUS	;  ЕСЛИ МИНУСА НЕТ - ПЕРЕХОД*
	MOV		 FL,1		; УСТАНОКА ФЛАГА НЕГАТИВНОГО ЧИСЛА
	DEC 	 CL			; УЧЕСТЬ МИНУС В КОЛ-ВЕ ВВЕДЕННЫХ СИМВОЛОВ
	CMP 	 CX,0		; *ЕСЛИ КРОМЕ МИНУСА НИЧЕГО НЕ ВВЕДЕНО
	JE 		SOME_ERR	;  ВЫЙТИ ИЗ ПРОГРАММЫ*
	INC 	 SI			; ПЕРЕЙТИ К СЛЕДУЮЩЕМУ РАЗРЯДУ ЧИСЛА   
   NO_MINUS:   			;* НАЧАЛО РАБОТЫ С ЧИСЛОМ
	XOR 	 AX,AX		; ОЧИСТКА 'AX'
	XOR 	 DI,DI		; ОЧИСТКА 'DI'
	MOV 	 DI,10		; ДЛЯ РАЗДЕЛЕНИЯ ЧИСЛА НА РАЗРЯДЫ
	DEC 	 SI			; ВОЗВРАЩАЕМСЯ К РАБОЧЕМУ СИМВОЛУ
   FOR_LOOP:			; НАЧАЛО ЦИКЛА ПРОХОДА ПО ЧИСЛУ(ПОРАЗРЯДНО)
	INC 	 SI			; ПЕРЕХОД К ПЕРВОМУ СИМВОЛУ
	XOR 	 BX,BX		; ОБНУЛЕНИЕ 'BX'
	MOV 	 BL,[SI]	; РАЗМЕЩЕНИЕ ЧИСЛА В РЕГИСТР
	SUB 	 BL,'0'		; ПРЕОБРАЗОВАНИЕ ASCII TO DEC
	CMP 	 BL,9		; *ЕСЛИ ВВЕДЕНА НЕ ЦИФРА
	JA 		SOME_ERR	;  ВЫЙТИ ИЗ ПРОГРАММЫ*
	MUL 	 DI			; *УМНОЖАЕМ 'AX' НА 10 ДЛЯ ДОБАВЛЕНИЯ МЕСТА
						;  ПОД НОВЫЙ СИМВОЛ* (1 -> 10 + 'BX' = 11)
	ADD 	 AX,BX		;  ПРИБАВЛЯЕМ К ЧИСЛУ В 'AX' ПОЛУЧЕННУЮ ЦИФРУ
   LOOP 	FOR_LOOP    ; "КОНЕЦ" ЦИКЛА ПРОХОДА ПО ЧИСЛУ
	CMP 	 FL,1		; *ЕСЛИ ЧИСЛО НЕ ОТРИЦАТЕЛЬНОЕ
	JNE 	NOT_NEG		;  НИЧЕГО НЕ ДЕЛАЕМ.
	NEG 	 AX			;  ИНЧЕ - ДЕЛАЕМ ЕГО НЕГАТИВНЫМ.
   NOT_NEG: 
    CMP 	 ERRCD,0    ; *ЕСЛИ ОШИБОК НЕТ
    JE		 EXIT		;  НА ВЫХОД ИЗ ПРОЦЕДУРЫ*
   
   SOME_ERR:
    MOV		 ERRCD,1	; ПОДНЯТЬ ФЛАГ ОШИБКИ - 1
	
   EXIT:
   MOV		X,AX
ENDM

OUTPUT	MACRO	NUMBER
	MOV		 AX,NUMBER
	MOV 	 BX,AX		; РАЗМЕЩЕНИЕ ЧИСЛА В РЕГИСТРЕ AX
	OR 		 BX,BX 		; *ЕСЛИ ЧИЛО ПОЛОЖИТЕЛЬНОЕ
	JNS		 $+8		;  ПЕРЕЙТИ В M1.	
	MOV 	 AL,"-"		;  ИНЧЕ РАЗМЕСТИТ В РЕЗУЛЬТАТЕ СИМВОЛ МИНУСА.
	INT 	 29H		;  ВЫВЕСТИ МИНУС НА ЭКРАН*
	NEG 	 BX			; ИЗМЕНИТЬ СТАРШИЙ БИТ ЧИСЛА("УБРАТЬ МИНУС")
   ;$+8:				; ТОЧКА ПРЕХОДА ЕСЛИ ЧИСЛО ПОЗИТИВНОЕ
	MOV 	 AX,BX		; ОБНОВИТЬ ЧИСЛО В РЕГИСТРЕ 'AX'(ИЗ-ЗА "NEG BX")
	XOR 	 CX,CX		; ОБНУЛИТЬ РЕГИСТР СЧЕТЧИКА
	MOV 	 BX,10		; ДЛЯ РАЗДЕЛЕНИЯ ЧИСЛА НА РАЗРЯДЫ
   ;$-11:				; НАЧАЛО ЦИКЛА "РАЗМЕЩЕНИЕ ЧИСЛА В СТЕКЕ"
	XOR 	 DX,DX		; ОБНУЛЕНИЕ 'DX'
	DIV 	 BX			; ДЕЛЕНИЕ 'AX' НА 'BX'(ОТДЕЛЕНИЕ РАЗРЯДА)
	ADD 	 DL,"0"		; DECIMAL TO ASCII
	PUSH 	 DX			; РАЗМЕЩЕНИЕ РЕЗУЛЬТАТА В СТЕКЕ
	INC 	 CX			; УВЕЛИЧЕНИЕ СЧЕТЧИКА
	TEST 	 AX,AX		; *ЕСЛИ ЕЩЕ ОСТАЛИСЬ ЦИФРЫ В ЧИСЛЕ
	JNZ 	 $-11		;  ПОВТОРИТЬ "РАЗМЕЩЕНИЕ В СТЕКЕ"
   ;$-3:				; НАЧАЛО ЦИКЛА ВЫВОДА ЧИСЛА ИЗ СТЕК НА ЭКРАН
	POP 	 AX			; ДОСТАТЬ ВЕРХНЮЮ ЦИФРУ ИЗ СТЭКА
	INT 	 29H		; ВЫВЕСТИ ЕЁ НА ЭКРАН
   LOOP 	 $-3		; ПОВТОРИТЬ 'M3' ПОКА СЧЕТЧИК НЕ '0'
ENDM


EQUATION3 MACRO	X,REZ,REZ2
	 MOV	AX,X
	 MOV 	BX,X	 	;'BX' = X
	 IMUL	BX			;'AX' = X*X
	 NEG	AX			; КВАДРАТ УБИРЕТ МИНУС
	 MOV	BX,5		;'BX' = 5
	 IMUL	BX			;'AX' = 5*X*X
	 MOV	REZ,AX		;'REZ' = 5*X*X
	 MOV    AX,X		;'AX' = X
	 MOV    BX,1		;'BX' = 1
	 SUB    AX,BX		;'AX' = 1-X
	 MOV	X,AX		;'X' = 1-X
	 NEG 	X			; ЧТО БЫ В ЗНАМИНАТЕЛЕ БЫЛО БЕЗ МИНУСА
	 MOV	BX,AX		;'REZ2' = 1-X
	 MOV 	AX,REZ		;'AX' = 5*X*X
	 IDIV	BX			;'AX' = 5*X*X/1-X
	 NEG	DX			; ВСЕ МИНУСЫ ПРОПАСТЬ ДОЛЖНЫ
	 MOV	REZ,AX		; ПОМЕСТИТЬ ЧАСТНОЕ В REZ
	 MOV	REZ2,DX		; ПОМЕСТИТЬ ОСТАТОК В REZ2	
ENDM

EQUATION2 MACRO	REZ
	 MOV	REZ,5	 
ENDM

EQUATION1 MACRO X,REZ,REZ2
	 MOV	AX,X		; 'AX' = X
	 MOV 	BX,20	    ; 'BX' = 20
	 MUL	BX		    ; 'AX' = 20X
	 ADD 	AX,25	    ; 'AX' = 20X + 25
	 MOV 	REZ,AX		; 'REZ' = 20X + 25
	 MOV 	AX,X        ; 'AX' = X 
	 MOV 	BX,AX		; 'AX' = X
	 MUL	BX			; 'AX' = X*X
	 MOV	BX,3		; 'BX' = 3
	 MUL	BX			; 'AX' = 3*X*X
	 MOV	REZ2,AX		; 'REZ2' = 3*X*X
	 MOV	AX,X		; 'AX' = X
	 MOV	BX,9		; 'BX' = 9
	 MUL	BX			; 'AX' = 9X
	 ADD 	AX,REZ2		; 'AX' = 3XX + 9X
     ADD	AX,6		; 'AX' = 3XX + 9X + 6
	 MOV 	BX,AX		; 'BX' = 3XX + 9X + 6
	 MOV 	X,AX		; 'X' = 3XX + 9X + 6
	 MOV 	AX,REZ		; 'AX' = 20X+25
	 DIV 	BX			; 'AX' - ЧАСТНОЕ
						; 'DX' - ОСТАТОК
	 MOV	REZ,AX		; ПОМЕСТИТЬ ЧАСТНОЕ В REZ
	 MOV	REZ2,DX		; ПОМЕСТИТЬ ОСТАТОК В REZ2
ENDM