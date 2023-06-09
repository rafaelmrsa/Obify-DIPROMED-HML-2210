#include "RwMake.ch"
#include "Protheus.ch"
/*
������������������������������������������������������������������������������
���Programa  � MT100TOK � Autor � Giovani Zago        � Data �  04/01/2012 ���
��������������������������������������������������������������������������͹��
���Descricao � Valida data de emissao menor que informado no parametro     ���
���          �                                                             ���
������������������������������������������������������������������������������
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
		//MSGINFO("Data de Emiss�o Inv�lida !!!!","ATEN��O!")          
    	Aviso("ATEN��O - Data de emiss�o","DATA DE EMISS�O INV�LIDA, FAVOR CORRIGIR!",{"Ok"} )
	EndIf
	If Empty(CNFISCAL) .And. DateDiffDay( Date() , DDEMISSAO ) <> 0
		_lRetorno:= .F.		          
    	Aviso("ATEN��O - Data de emiss�o","A data de emiss�o n�o pode ser alterada para formul�rio pr�prio.",{"Ok"} )
	EndIf
EndIf
RestArea(_xAreaSB1)
RestArea(_xArea)

Return(_lRetorno)

