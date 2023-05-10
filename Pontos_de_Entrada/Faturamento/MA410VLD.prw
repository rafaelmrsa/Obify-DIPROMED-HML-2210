#include "rwmake.ch"
/*
PONTO.......: MA410VL           PROGRAMA....: MATA410
DESCRI��O...: Executado na confirma��o da altera��o/exclus�o
UTILIZA��O..: Chamado no programa de exclusao de Pedidos de Venda
PARAMETROS..: <NENHUM>
RETORNO.....: Retorna um valor logico. Se retornar .F. impede a exclus�o do Pedido de Venda.
OBSERVA��ES.: <NENHUM>
*/
/*
�������������������������������������������������������������������������������
���Programa �MA410VL  � Autor �   Maximo Canuto  � Data �  25/04/2007       ���
���������������������������������������������������������������������������͹��
���Desc.    �Guardar o campo C6_PEDCLI do Pedido no cancelamento da Exclusao���
�������������������������������������������������������������������������������
*/
User Function MA410VLD()
Local _lRetorno := .T.
Local _xAlias   := GetArea()

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU


If Inclui
	If M->C5_TIPODIP == "1"
		_lRetorno := MsgBox("Cancela inclus�o do Pedido? ","Atencao","YESNO") // 29/07/09 MCVN
	ElseIf M->C5_TIPODIP == "2"                                                                        
		_lRetorno := MsgBox("Cancela inclus�o do Or�amento? ","Atencao","YESNO") // 29/07/09 MCVN
	Else                                                                           
		_lRetorno := MsgBox("Cancela inclus�o da Programa��o? ","Atencao","YESNO") // 29/07/09 MCVN
	Endif
ElseIf Altera
	If M->C5_TIPODIP == "1"
		_lRetorno := MsgBox("Cancela altera��o do Pedido? ","Atencao","YESNO") // 29/07/09 MCVN
	ElseIf M->C5_TIPODIP == "2"                                                                        
		_lRetorno := MsgBox("Cancela altera��o do Or�amento? ","Atencao","YESNO") // 29/07/09 MCVN
	Else                                                                           
		_lRetorno := MsgBox("Cancela altera��o da Programa��o? ","Atencao","YESNO") // 29/07/09 MCVN
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
