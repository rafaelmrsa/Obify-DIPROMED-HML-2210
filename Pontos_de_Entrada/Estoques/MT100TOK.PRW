#include "RwMake.ch"
#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ MT100TOK º Autor ³ Giovani Zago        º Data ³  04/01/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida data de emissao menor que informado no parametro     º±±
±±º          ³                                                             º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*---------------------------------------------------*
User Function MT100TOK()
*---------------------------------------------------*

Local _xArea      := GetArea()
Local _xAreaSB1   := SB1->(GetArea())
Local _lRetorno   := .T.
Local _nDi        :=  GetMv("ES_MT100_1",,60)


U_DIPPROC(ProcName(0),U_DipUsr()) // Gravando o nome do Programa no SZU

If "MATA103" $ FunName()
	If DateDiffDay( Date() , DDEMISSAO ) >= _nDi
		_lRetorno:= .F.
		//MSGINFO("Data de Emissão Inválida !!!!","ATENÇÃO!")          
    	Aviso("ATENÇÃO - Data de emissão","DATA DE EMISSÃO INVÁLIDA, FAVOR CORRIGIR!",{"Ok"} )
	EndIf
	If Empty(CNFISCAL) .And. DateDiffDay( Date() , DDEMISSAO ) <> 0
		_lRetorno:= .F.		          
    	Aviso("ATENÇÃO - Data de emissão","A data de emissão não pode ser alterada para formulário próprio.",{"Ok"} )
	EndIf
EndIf
RestArea(_xAreaSB1)
RestArea(_xArea)

Return(_lRetorno)

