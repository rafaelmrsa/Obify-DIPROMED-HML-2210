#INCLUDE "Protheus.ch"
#include "rwmake.ch"

/*====================================================================================\
|Programa  |   MTA242S                     | Autor | GIOVANI.ZAGO| Data | 31/10/2011 |
|=====================================================================================|
|Descrição | validação na msgetdados mata242                                          |
|          | bloquear digitação de casas decimais na quantidade                       |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   |                                                                          |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
\====================================================================================*/
*---------------------------------------------------*
User Function MTA242S ()
*---------------------------------------------------*
Local _xArea    := GetArea()
Local lRet      := .T.
Local nDeci		:= NoRound(nQtdOrigSe,0) 

If "MATA242" $ FunName()
	If  nQtdOrigSe > nDeci
		alert("A Quantidade não pode conter valor Decimal !!!!!")
		lRet      := .F. 
	
	EndIf
EndIf
	nDeci     := 0
RestArea(_xArea)
Return(lRet)

