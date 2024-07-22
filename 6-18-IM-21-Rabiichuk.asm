.386
.model flat, stdcall
option casemap: none

include \masm32\include\masm32rt.inc

.data?
  myResultOfCalculation dq 1 dup(?)
  firstPartOfFormula dt 16 dup(?)
  secondPartOfFormula dt 16 dup(?)
  myFinalResultOfCalculation dt 64 dup(?)

  myNumberForFormulaA db 32 dup(?)
  myNumberForFormulaB db 32 dup(?)
  myNumberForFormulaC db 32 dup(?)
  myNumberForFormulaD db 32 dup(?)

  myMessageRabiichukLab6 db 128 dup(?)
  labMyMessageBuffer6 db 128 dup(?)

.data 
  labTitle db "Laboratorna 6 Rabiichuk IM-21", 0
  myMessageNormalText db "Variant: 18", 10,
                "Formula: (2*c + ln(d/4) + 23)/(a*a-b)", 10, 10,
                "(2*%s + ln(%s/4) + 23)/(%s*%s-%s) = %s", 10,
                "a = %s, b = %s, c = %s, d = %s", 10, 10, 0

  myMessageErrorText1 db "Variant: 18", 10,
                "Formula: (2*c + ln(d/4) + 23)/(a*a-b)", 10, 10,
                "(2*%s + ln(%s/4) + 23)/(%s*%s-%s) = ERROR", 10,
                "a = %s, b = %s, c = %s, d = %s", 10, 10,
                "you have divison by 0, try again", 10, 10, 0

  myMessageErrorText2 db "Variant: 18", 10,
                "Formula: (2*c + ln(d/4) + 23)/(a*a-b)", 10, 10,
                "(2*%s + ln(%s/4) + 23)/(%s*%s-%s) = ERROR", 10,
                "a = %s, b = %s, c = %s, d = %s", 10, 10,
                "you have error in logaritm, try again", 10, 10, 0

  arrayForCalculationA dq 2.5, 1.1, 2.3, 0.6, 2.8, -0.3
  arrayForCalculationB dq 1.2, 1.21, 5.29, -1.4, 3.5, 4.8 
  arrayForCalculationC dq 1.5, 0.6, 2.5, -0.9, -1.9, -7.6
  arrayForCalculationD dq 8.1, 1.7, 3.6, -2.8, -9.9, 6.9 

  two dq 2.0
  four dq 4.0
  twentyThree dq 23.0

displayMessage macro windowMessage, windowTitle 
  invoke MessageBox, 0, offset windowMessage, offset windowTitle, 0
endm

.code 
myProgram6Laboratorna:
  mov ebp, 0
  .while ebp < 6

    invoke FloatToStr2, arrayForCalculationA[ebp * 8], addr myNumberForFormulaA
    invoke FloatToStr2, arrayForCalculationB[ebp * 8], addr myNumberForFormulaB
    invoke FloatToStr2, arrayForCalculationC[ebp * 8], addr myNumberForFormulaC
    invoke FloatToStr2, arrayForCalculationD[ebp * 8], addr myNumberForFormulaD

     ; Ініціалізація FPU
    finit

    ; Загрузка даних 
    
fld     arrayForCalculationD[ebp * 8]   ; Завантаження d
fld     four                             ; Завантаження числа 4
fdiv                                      ; Обчислення d / 4

fldln2                                    ; Обчислення ln(d/4)
fxch                                      ; Обмін верхніми двома значеннями в стеку
fyl2x                                     ; Обчислення результату ln(d/4)

ftst
fnstsw ax
sahf
jz errorValidValues

; Завантаження і обчислення першої частини формули
fld     st(0)                             ; Копіювання результату ln(d/4) для подальших обчислень
fld     arrayForCalculationC[ebp * 8]      ; Завантаження c
fld     two                                ; Завантаження числа 2
fmul                                      ; Обчислення 2*c
fadd                                      ; Обчислення 2*c + ln(d/4)
fld     twentyThree                        ; Завантаження числа 23
fadd                                      ; Обчислення 2*c + ln(d/4) + 23
fstp    qword ptr [firstPartOfFormula]     ; Збереження першої частини формули в long double


    ; Обчислення знаменника (a^2 - b)
fld     arrayForCalculationA[ebp * 8]             ; Загрузка a
fmul    st(0), st(0)                              ; Обчислення a^2
fld     arrayForCalculationB[ebp * 8]             ; Загрузка b
fsub                                              ; Обчислнння a^2 - b
fstp    qword ptr [secondPartOfFormula]            ; Збереження другої частини виразу в qword ptr

    ; Перевірка флагів статусу FPU
    ftst                                           
    fnstsw   ax                                        
    sahf
  
    jbe errorFormulaWIthZero ; Перехід до обробника помилки, якщо ділення на нуль  
    

    fld qword ptr [firstPartOfFormula] ; st(1)
    fdiv    qword ptr [secondPartOfFormula]           ; Ділення чисельник на знаменник
    fstp    qword ptr [myResultOfCalculation]         ; Збереження результату в qword ptr
   jmp formulaHaveNoErrors                                                              
    
    ; Підготовка строкового представлення для виводу повідомлення
    
    formulaHaveNoErrors:
    invoke  FloatToStr2, myResultOfCalculation, addr myFinalResultOfCalculation
    invoke  wsprintf, addr labMyMessageBuffer6, addr myMessageNormalText, 
            addr myNumberForFormulaC, addr myNumberForFormulaD, 
            addr myNumberForFormulaA, addr myNumberForFormulaA, addr myNumberForFormulaB,
            addr myFinalResultOfCalculation,
            addr myNumberForFormulaA, addr myNumberForFormulaB, addr myNumberForFormulaC, addr myNumberForFormulaD
    invoke  szCatStr, addr myMessageRabiichukLab6, addr labMyMessageBuffer6
    displayMessage myMessageRabiichukLab6, labTitle
    jmp     nextIterationOfFormula

    errorFormulaWIthZero:
      invoke wsprintf, addr labMyMessageBuffer6, addr myMessageErrorText1, 
        addr myNumberForFormulaC, addr myNumberForFormulaD, 
        addr myNumberForFormulaA, addr myNumberForFormulaA, addr myNumberForFormulaB,
        addr myNumberForFormulaA, addr myNumberForFormulaB, addr myNumberForFormulaC, addr myNumberForFormulaD
      invoke szCatStr, addr myMessageRabiichukLab6, addr labMyMessageBuffer6
      displayMessage myMessageRabiichukLab6, labTitle 
      jmp nextIterationOfFormula

errorValidValues:    
         invoke wsprintf, addr labMyMessageBuffer6, addr myMessageErrorText2, 
        addr myNumberForFormulaC, addr myNumberForFormulaD, 
        addr myNumberForFormulaA, addr myNumberForFormulaA, addr myNumberForFormulaB,
        addr myNumberForFormulaA, addr myNumberForFormulaB, addr myNumberForFormulaC, addr myNumberForFormulaD
      invoke szCatStr, addr myMessageRabiichukLab6, addr labMyMessageBuffer6
      displayMessage myMessageRabiichukLab6, labTitle 
      jmp nextIterationOfFormula

    nextIterationOfFormula:
      mov myMessageRabiichukLab6, 0h
      inc ebp
  .endw
  invoke ExitProcess, 0
end myProgram6Laboratorna