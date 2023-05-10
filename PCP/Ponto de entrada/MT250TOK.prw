/*
+===========================================================+
|Funcao: MT250TOK | Autor: Reginaldo Borges | Data: 01/03/17|
+-----------------------------------------------------------+
|Descricao:  Executado na função A250TudoOk(), rotina       |
|            responsavel por validar os apontamentos de     |
|            produção simples.                              |
|            Permite validar algo digitado dependendo da    |
|            necessidade do usuário, ele valida a tela toda.|
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
		MsgInfo("Lote ainda não gerado na OP!","ATENÇÃO!")
		lRet:= .F.			
ElseIf  !lRet 
		If ! SC2->C2_PRODUTO $ _cProdCA
			MsgInfo("Lote "+cLote+" já foi utilizado, gerar um novo!","ATENÇÃO!")
			lRet := .F.
		Else
			lRet := .T.		
		EndIF	
ElseIf lRet .And. cLote <> SC2->C2_NUM+StrZero(month(Date()),2)+cValToChar(StrZero(nRev,2)) .And. Substr(SC2->C2_PRODUTO,1,1) <> "2" 
		MsgInfo("Lote fora do mês, verificar a possbilidade de gerar um NOVO!","ATENÇÃO!")
		lRet:= .F.			
EndIf
*/

Return lRet  
