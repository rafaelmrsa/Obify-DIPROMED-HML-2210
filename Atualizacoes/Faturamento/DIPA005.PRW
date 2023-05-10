#include "RwMake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DIPA005  º Autor ³   Alexandro Dias   º Data ³  18/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra nome do operador no pedido de venda.                º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA005()
Local _xArea := GetArea()
Local _cRet  := ""

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

SU7->(DbSetorder(6))

If Altera
	If SU7->(DbSeek(xFilial("SU7")+SC5->C5_OPERADO))
		_cRet := SU7->U7_COD
    EndIF    
Else 
	If SU7->(DbSeek(xFilial("SU7")+U_DipUsr())) // JBS 04/04/2006 - Tirei o o upper do usuario
		_cRet := SU7->U7_COD
    EndIF    
EndIF

RestArea(_xArea)

IF Empty(_cRet)
	MsgBox("E necessario cadastrar o Operador na Tabela SU7 !!!","Atencao","INFO")
EndIF

Return(_cRet)