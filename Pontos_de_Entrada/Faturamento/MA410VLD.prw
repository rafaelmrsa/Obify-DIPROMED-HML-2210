#include "rwmake.ch"
/*
PONTO.......: MA410VL           PROGRAMA....: MATA410
DESCRIÇÄO...: Executado na confirmação da alteração/exclusão
UTILIZAÇÄO..: Chamado no programa de exclusao de Pedidos de Venda
PARAMETROS..: <NENHUM>
RETORNO.....: Retorna um valor logico. Se retornar .F. impede a exclusão do Pedido de Venda.
OBSERVAÇÖES.: <NENHUM>
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma ³MA410VL  º Autor ³   Maximo Canuto  º Data ³  25/04/2007       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Guardar o campo C6_PEDCLI do Pedido no cancelamento da Exclusaoº±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MA410VLD()
Local _lRetorno := .T.
Local _xAlias   := GetArea()

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU


If Inclui
	If M->C5_TIPODIP == "1"
		_lRetorno := MsgBox("Cancela inclusão do Pedido? ","Atencao","YESNO") // 29/07/09 MCVN
	ElseIf M->C5_TIPODIP == "2"                                                                        
		_lRetorno := MsgBox("Cancela inclusão do Orçamento? ","Atencao","YESNO") // 29/07/09 MCVN
	Else                                                                           
		_lRetorno := MsgBox("Cancela inclusão da Programação? ","Atencao","YESNO") // 29/07/09 MCVN
	Endif
ElseIf Altera
	If M->C5_TIPODIP == "1"
		_lRetorno := MsgBox("Cancela alteração do Pedido? ","Atencao","YESNO") // 29/07/09 MCVN
	ElseIf M->C5_TIPODIP == "2"                                                                        
		_lRetorno := MsgBox("Cancela alteração do Orçamento? ","Atencao","YESNO") // 29/07/09 MCVN
	Else                                                                           
		_lRetorno := MsgBox("Cancela alteração da Programação? ","Atencao","YESNO") // 29/07/09 MCVN
	Endif
Endif

IF _lRetorno 

	If !Altera .and. !Inclui .And.  Type("_aABN") <> "U"   //MCVN - 29/07/09
    
		// Voltando valor do C5_PARCIAL
		Reclock("SC5",.F.)
		SC5->C5_PARCIAL := _aABN[1]
		SC5->(MsUnLock())
		SC5->(DbCommit())  // MCVN 25/04/07

		// Voltando valor do C5_PARCIAL
		SC6->(dbSetOrder(1))
   		SC6->(dbSeek(xFilial("SC5")+SC5->C5_NUM))
  		Do While SC6->(!EOF()) .and. SC6->C6_FILIAL==xFilial("SC5") .and. SC6->C6_NUM == SC5->C5_NUM
		   	SC6->(RecLock('SC6',.f.))
			SC6->C6_PEDCLI := _aABN[2]
			SC6->(MsUnlock())
			SC6->(DbCommit())  // MCVN 25/04/07
		SC6->(DbSkip())
		EndDo
	
	_aABN := {}
	
	EndIf

ENDIF

RestArea(_xAlias)
Return(_lRetorno)
