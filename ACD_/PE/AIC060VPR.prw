#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AIC060VPR �Autor  �Microsiga           � Data �  08/21/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AIC060VPR()
Local lRet 	    := .T.   
Local aArea     := GetArea()
Local cProduto  := PARAMIXB[1]     
Local nQtdInf   := PARAMIXB[2]     
Local nQtdCxEmb := 0

SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cProduto))	
	If SB1->B1_XCXFECH=="1"
		If SB1->B1_XVLDCXE=="1"
		    If SB1->B1_XTPEMBV=="1"
		    	nQtdCxEmb := SB1->B1_XQTDEMB
		    ElseIf SB1->B1_XTPEMBV=="2" 
		    	nQtdCxEmb := SB1->B1_XQTDSEC
		    Else             
		    	nQtdCxEmb := 1
			EndIf    
		    
			If Mod(nQtdInf,nQtdCxEmb)<>0       
				VtAlert("S� ser� permitido endere�ar multiplos de "+AllTrim(Str(nQtdCxEmb))+" para este produto","Caixa Fechada")
				lRet := .F.
			EndIf
		Else 
			VtAlert("Produto em an�lise para regra de caixa fechada. Falar com a Expedi��o.","Caixa Fechada")
			lRet := .F.
		EndIf
    EndIf
EndIf

If AllTrim(u_DipUsr())$'ddomingos/mcanuto'
	lRet := .T.
EndIf
	
RestArea(aArea)
Return lRet