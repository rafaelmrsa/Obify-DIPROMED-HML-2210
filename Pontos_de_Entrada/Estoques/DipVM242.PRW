#INCLUDE "Protheus.ch"
#include "rwmake.ch"

/*====================================================================================\
|Programa  |   DipVM242                     | Autor | GIOVANI.ZAGO| Data | 31/10/2011 |
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
User Function DipVM242 (nCon)
*---------------------------------------------------*
Local _xArea    := GetArea()
Local lRet      := .T.
Local nDeTi		:=  NoRound(If(nCon=1,M->D3_QUANT,M->D3_QTSEGUM),0)  

If "MATA242" $ FunName()
	If  If(nCon=1,M->D3_QUANT,M->D3_QTSEGUM) > nDeTi
		alert("A Quantidade não pode conter valor Decimal !!!!!")
		lRet      := .F. 		
	EndIf
EndIf
	nDeTi:=0
RestArea(_xArea)
Return(lRet)

