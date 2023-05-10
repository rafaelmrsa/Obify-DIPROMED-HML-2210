User Function V166VLD()
Local lRet := .T.

SC5->(dbSetOrder(1))
If SC5->(dbSeek(xFilial("SC5")+CB7->CB7_PEDIDO)) .And. !Empty(SC5->C5_XBLQNF)
	VtAlert("Foi solicitado o estorno do pedido. Pare a separação.","Aviso",.t.,4000,3)
	VtKeyboard(Chr(20))  // zera o get
	lRet := .F.
EndIf

Return lRet