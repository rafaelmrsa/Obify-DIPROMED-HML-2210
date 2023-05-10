#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AIC060VPR ºAutor  ³Microsiga           º Data ³  08/21/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
				VtAlert("Só será permitido endereçar multiplos de "+AllTrim(Str(nQtdCxEmb))+" para este produto","Caixa Fechada")
				lRet := .F.
			EndIf
		Else 
			VtAlert("Produto em análise para regra de caixa fechada. Falar com a Expedição.","Caixa Fechada")
			lRet := .F.
		EndIf
    EndIf
EndIf

If AllTrim(u_DipUsr())$'ddomingos/mcanuto'
	lRet := .T.
EndIf
	
RestArea(aArea)
Return lRet