/*
+===========================================================+
|Funcao: MT250TOK | Autor: Reginaldo Borges | Data: 01/03/17|
+-----------------------------------------------------------+
|Descricao:  Executado na fun��o A250TudoOk(), rotina       |
|            responsavel por validar os apontamentos de     |
|            produ��o simples.                              |
|            Permite validar algo digitado dependendo da    |
|            necessidade do usu�rio, ele valida a tela toda.|
+-----------------------------------------------------------+
|Uso: Health Quality - PCP                                  |
+===========================================================+
*/

#INCLUDE "PROTHEUS.CH"

User Function MT250TOK()
Local cLote    := Posicione("SC2",1,xFilial("SC2")+SC2->C2_NUM+SC2->C2_ITEM+"001","SC2->C2_XLOTECT")
Local cOP      := SC2->C2_NUM+SC2->C2_ITEM+"001"
Local nRev 	   := Val(SubStr(SC2->C2_XLOTECT,9,2))
Local lRet     := U_cConLote(cOP,cLote)
Local _cProdCA := GetNewPar("ES_PROD_CA","227006/227004/299128/227020") 

/*
If Empty(cLote) .And. Substr(SC2->C2_PRODUTO,1,1) <> "2"
		MsgInfo("Lote ainda n�o gerado na OP!","ATEN��O!")
		lRet:= .F.			
ElseIf  !lRet 
		If ! SC2->C2_PRODUTO $ _cProdCA
			MsgInfo("Lote "+cLote+" j� foi utilizado, gerar um novo!","ATEN��O!")
			lRet := .F.
		Else
			lRet := .T.		
		EndIF	
ElseIf lRet .And. cLote <> SC2->C2_NUM+StrZero(month(Date()),2)+cValToChar(StrZero(nRev,2)) .And. Substr(SC2->C2_PRODUTO,1,1) <> "2" 
		MsgInfo("Lote fora do m�s, verificar a possbilidade de gerar um NOVO!","ATEN��O!")
		lRet:= .F.			
EndIf
*/

Return lRet  
