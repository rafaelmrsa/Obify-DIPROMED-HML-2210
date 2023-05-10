#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT120LOK ºAutor  ³D'Leme              º Data ³  11/Out/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE na validação da linha (não-deletada) do Pedido de Compraº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Dipromed                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT120LOK()
Local _xArea    := GetArea()
Local _xAreaSB1 := SB1->(GetArea())
Local _lRetorno := .T.

U_DIPPROC(ProcName(0),U_DipUsr()) //-- Gravando o nome do Programa no SZU

If Type("l120Auto") != "U" .And. !l120Auto

	SB1->(DbSetOrder(1))
	If ( _lRetorno := SB1->(DbSeek(xFilial("SB1")+aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "C7_PRODUTO"})])) )
	
		//-- Valida se o Produto possui TES padrão de Entrada cadastrada
		If _lRetorno .And. Empty(SB1->B1_TE)
			_lRetorno := .F.
			MsgAlert("O Produto " + SB1->B1_COD + " não possui TES padrão de Entrada indicada em seu cadastro!","Atenção")
		//-- Obrigatório preencher a TES para calcular ST dos produtos do Fornecedor CEPEO 	
		ElseIf _lRetorno .And. !Empty(SB1->B1_TE) .And. CA120FORN == '000855' .And. Empty(Alltrim(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "C7_TES"})]))
			_lRetorno := .F.
			MsgAlert("É necessário informar TES DE ENTRADA para este fornecedor!","Atenção")
		EndIf

	EndIf
EndIf
RestArea(_xAreaSB1)
RestArea(_xArea)

Return _lRetorno