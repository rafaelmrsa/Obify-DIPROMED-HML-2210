#include 'protheus.ch'
/*-------------------------------------------------------------------------------------
{Protheus.doc} GATC6TES

@Author  	   Tiago Stocco - Obify
@since		   08/2021
@version	   P12

@description Gatilho do SC6 para automatizar o TES inteligente de acordo com o Campo C5_XOPER
*/
user function GATC6TES()
Local cTESOld		:= GDFieldGet("C6_TES")
Local cTESInt		:= ""
Local cLine			:= ""

cTESInt := MaTesInt(2,M->C5_XOPER,M->C5_CLIENTE,M->C5_LOJACLI,If(M->C5_TIPO$"DB","F","C"),GDFieldGet("C6_PRODUTO"))

If Empty(cTESInt)
	cLine += "Cliente:"+M->C5_CLIENTE+M->C5_LOJACLI + " " + CRLF
	cLine += "Item:"+ GDFieldGet("C6_ITEM") + " " + CRLF
	cLine += "Produto:"+ GDFieldGet("C6_PRODUTO") + " " + CRLF
	MemoWrite( "\tesint\"+M->C5_NUM+M->C6_ITEM+" TES VAZIO" + ".txt", cLine )
	cTESInt	:= cTESOld
ElseIF !Empty(cTESInt) .and. Alltrim(cTESInt) <> Alltrim(cTESOld)

cLine += "Cliente:"+M->C5_CLIENTE+M->C5_LOJACLI + " " + CRLF
cLine += "Item:"+ GDFieldGet("C6_ITEM") + " " + CRLF
cLine += "Produto:"+ GDFieldGet("C6_PRODUTO") + " " + CRLF
cLine += "TES INT:"+ cTESInt + " " + CRLF
cLine += "TES OLD:"+ cTESOld + " " + CRLF
MemoWrite( "\tesint\"+M->C5_NUM+ " "+ GDFieldGet("C6_PRODUTO") + " DIFERENTE " + ".txt", cLine )	
cTESInt	:= cTESOld

EndIf

cLine += "Cliente:"+M->C5_CLIENTE+M->C5_LOJACLI + " " + CRLF
cLine += "Item:"+ GDFieldGet("C6_ITEM") + " " + CRLF
cLine += "Produto:"+ GDFieldGet("C6_PRODUTO") + " " + CRLF
cLine += "TES INT:"+ cTESInt + " " + CRLF
cLine += "TES OLD:"+ cTESOld + " " + CRLF
MemoWrite( "\tesint\"+M->C5_NUM+ " "+ GDFieldGet("C6_PRODUTO")+".txt", cLine )

return cTESInt
