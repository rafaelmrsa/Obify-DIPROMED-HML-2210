#INCLUDE "PROTHEUS.CH"
User Function SD1140E()
Local aAreaCBE  := CBE->(GetArea())                                      
Local cChave 	:= SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

CBE->(dbSetOrder(2))
If CBE->(dbSeek(xFilial("CBE")+cChave))
	While CBE->(dbSeek(xFilial("CBE")+cChave))
		CBE->(RecLock("CBE",.F.))
			CBE->(dbDelete())
		CBE->(MsUnlock())
	EndDo
EndIf
RestArea(aAreaCBE)

Return