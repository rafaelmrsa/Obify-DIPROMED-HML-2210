#Include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT120LOK �Autor  �D'Leme              � Data �  11/Out/11  ���
�������������������������������������������������������������������������͹��
���Desc.     � PE na valida��o da linha (n�o-deletada) do Pedido de Compra���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Dipromed                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MT120LOK()
Local _xArea    := GetArea()
Local _xAreaSB1 := SB1->(GetArea())
Local _lRetorno := .T.

U_DIPPROC(ProcName(0),U_DipUsr()) //-- Gravando o nome do Programa no SZU

If Type("l120Auto") != "U" .And. !l120Auto

	SB1->(DbSetOrder(1))
	If ( _lRetorno := SB1->(DbSeek(xFilial("SB1")+aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "C7_PRODUTO"})])) )
	
		//-- Valida se o Produto possui TES padr�o de Entrada cadastrada
		If _lRetorno .And. Empty(SB1->B1_TE)
			_lRetorno := .F.
			MsgAlert("O Produto " + SB1->B1_COD + " n�o possui TES padr�o de Entrada indicada em seu cadastro!","Aten��o")
		//-- Obrigat�rio preencher a TES para calcular ST dos produtos do Fornecedor CEPEO 	
		ElseIf _lRetorno .And. !Empty(SB1->B1_TE) .And. CA120FORN == '000855' .And. Empty(Alltrim(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "C7_TES"})]))
			_lRetorno := .F.
			MsgAlert("� necess�rio informar TES DE ENTRADA para este fornecedor!","Aten��o")
		EndIf

	EndIf
EndIf
RestArea(_xAreaSB1)
RestArea(_xArea)

Return _lRetorno