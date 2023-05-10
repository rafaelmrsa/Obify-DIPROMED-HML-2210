#INCLUDE "Protheus.ch"
/*====================================================================================\
|Programa  | M240BROW       | Autor | GIOVANI.ZAGO               | Data | 13/10/2011  |
|=====================================================================================|
|Descri��o | Bloqueio da rotina internos                                              |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | M240BROW                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist�rico....................................|
\====================================================================================*/
*---------------------------------------------------*
User Function M240BROW()
*---------------------------------------------------*
Local lRet := .T.

If ("MATA241") $ FunName()
	
	If Upper(U_DipUsr()) $ alltrim(GetMV("ES_MATA240"))
		lRet := .T.
		
	Else
		lRet:= .F.
		alert("Usuario sem autoriza��o para realizar esta opera��o.")
	EndIf
	lRet:= .T.
ElseIf("MATA240") $ FunName()
	alert("A Rotina Internos foi desativada, Utilize a Rotina Internos (Mod.2) !!!!!!! ")
	lRet:= .F.
EndIf
Return(lRet)

