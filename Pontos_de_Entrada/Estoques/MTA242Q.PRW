#INCLUDE "Protheus.ch"
#include "rwmake.ch"

/*====================================================================================\
|Programa  |   MTA242Q                     | Autor | GIOVANI.ZAGO| Data | 31/10/2011 |
|=====================================================================================|
|Descri��o | valida��o na msgetdados mata242                                          |
|          | bloquear digita��o de casas decimais na quantidade                       |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   |                                                                          |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist�rico....................................|
\====================================================================================*/
*---------------------------------------------------*
User Function MTA242Q ()
*---------------------------------------------------*
Local _xArea    := GetArea()
Local lRet      := .T.
Local nDecT	    := NoRound(nQtdOrig,0)

If "MATA242" $ FunName()
	If  nQtdOrig > nDecT
		alert("A Quantidade n�o pode conter valor Decimal!!!!!")
		lRet      := .F.
		EndIf
EndIf
	nDecT     := 0
RestArea(_xArea)
Return(lRet)

