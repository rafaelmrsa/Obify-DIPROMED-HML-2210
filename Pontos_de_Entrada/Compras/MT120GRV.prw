/*
+------------------------------------------------------------+
| Funcao: MTA120G()  | Autor Reginaldo Borges  | 28/07/2017 |
+------------------------------------------------------------+
|Descrição: Será executado antes da gravação dos itens do    |
|           Pedido Compra. Retorna um Array (Paramixb) com   | 
|           as informações a serem gravadas.                 |
+------------------------------------------------------------+
|Uso: Departamento de Compras                                |
+------------------------------------------------------------+
*/
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

User Function MT120GRV()
Local lRet := .T.
Local lIncluirKardex := .T.
Local _cPedido := PARAMIXB[1] // Numero do Pedido de compras
Local lInclui  := PARAMIXB[2] // .T. indica se é inclusão
Local lAlterar := PARAMIXB[3] // .T. indica se é alteração
Local lExclui  := PARAMIXB[4] // .T. indica se é exclusão
Local cTpOcorre:= ""
Local cTpMovime:= ""
Local _cUsuario:= Upper(U_DipUsr())
Local aSC7     := {}

SC7->(dbSetOrder(1))
SC7->(dbSeek(xfilial("SC7")+_cPedido+ACOLS[1,1]))
While SC7->(!Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM == _cPedido
	aadd(aSC7,{SC7->C7_ITEM, SC7->C7_PRODUTO, SC7->C7_QUANT, SC7->C7_PRECO})
	SC7->(DbSkip())
EndDo


If     lInclui
	cTpMovime:= "Inclusao de Pedido"
	cTpOcorre:= "Pedido Incluso"
	U_DipKardexb(_cPedido,_cUsuario,cTpMovime,lIncluirKardex,cTpOcorre)
	
ElseIf lAlterar
	
	If Len(aSC7) > 0 //.And. Len(aSC7) == Len(aCOLS)
		
		For I = 1 To Len(aCOLS)
			
			If 	ACOLS[I,Len(aHeader)+1] = .T.  // Produto deletado
				cTpMovime:= "Item Alterado  "+aCOLS[I,1]+"-"+aSC7[I,2]
				cTpOcorre := "Produto Deletado "+aSC7[I,2]
				U_DipKardexb(_cPedido,_cUsuario,cTpMovime,lIncluirKardex,cTpOcorre)
			EndIf
			
			If (Len(aSC7) - I) >= 0
				If ACOLS[I,7] <> aSC7[I,3]  // Quantidade alterada
					cTpMovime:= "Item Alterado  "+aCOLS[I,1]+"-"+aSC7[I,2]
					cTpOcorre := "Quantidade Alterada de "+cValToChar(aSC7[I,3]) +" para "+cValToChar(ACOLS[I,7])
					U_DipKardexb(_cPedido,_cUsuario,cTpMovime,lIncluirKardex,cTpOcorre)
				EndIf
			EndIf
			
			If (Len(aSC7) - I) >= 0
				If ACOLS[I,8] <> aSC7[I,4]   // Valor alterada
					cTpMovime:= "Item Alterado  "+aCOLS[I,1]+"-"+aSC7[I,2]
					cTpOcorre := "Valor Alterado de "+cValToChar(aSC7[I,4]) +" para "+cValToChar(ACOLS[I,8])
					U_DipKardexb(_cPedido,_cUsuario,cTpMovime,lIncluirKardex,cTpOcorre)
				Endif
			EndIf
			
		Next I
		
		If Len(aSC7) <> Len(aCOLS)
			cont :=  Len(aSC7)+1
			For I = cont To Len(aCOLS)
				cTpMovime:= "Item Alterado  "+aCOLS[I,1]+"-"+aCOLS[I,2]
				cTpOcorre:= "Produto Incluso "+aCOLS[I,2]
				U_DipKardexb(_cPedido,_cUsuario,cTpMovime,lIncluirKardex,cTpOcorre)
			Next I
		EndIf
		
	EndIf
	
ElseIf lExclui
	cTpMovime:= "Exclusao de Pedido"
	cTpOcorre:= "Pedido Excluso"
	U_DipKardexb(_cPedido,_cUsuario,cTpMovime,lIncluirKardex,cTpOcorre)
EndIf

Return(lRet)

