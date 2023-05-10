#include "rwmake.ch"        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SFINE008 ³ Autor ³   Natalino Oliveira   ³ Data ³ 06/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do numero da agencia no Layout CNAB PAGAR         ³±±
±±³          ³ Bradesco - PAGFOR                                          ³±±
±±³          ³ SEPARAR A AGENCIA DO CODIGO DE BARRA PARA O PROGRAMA DO    ³±±
±±³          ³ PAGFOR - POSICOES ( 99 - 103 )                             ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Dipromed                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SFINE008()       

Private _AGENCIA

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

_Agencia  :=  "00000"

If SubStr(SE2->E2_CODBAR,1,3) == "237"

    _Agencia  :=  StrZero(Val(SubStr(SE2->E2_CODBAR,20,4)),5)

ElseIf SUBSTR(SE2->E2_LD,1,3) == "237"

    _Agencia  :=  StrZero(Val(SubStr(SE2->E2_LD,05,4)),5)

ElseIf Empty(SE2->E2_CODBAR) .AND. EMPTY(SE2->E2_LD)

    _Agencia  := StrZero(Val(SA2->A2_AGENCIA),5)

EndIf

U_CalcDig(_Agencia)

Return(_Agencia)     

User Function CalcDig()   
Local Modulo, StrMult, BaseDac, vardac

modulo := 11
strmult := "65432"
BaseDac := _Agencia
varDAC  := 0
FOR idac := 1 TO 5
	varDAC := VarDac+VAL (SUBSTR (baseDAC, idac, 1)) * VAL (SUBSTR (strmult, idac, 1))
NEXT
varDAC  := modulo - varDAC % modulo
varDAC  := IF (varDAC == 10, "P", IF (varDAC == 11, "0", STR (vardac, 1)))
_Agencia:= _Agencia+vardac

Return(_Agencia)

