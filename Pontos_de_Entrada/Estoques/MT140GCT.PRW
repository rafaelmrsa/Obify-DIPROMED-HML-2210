/*
+===========================================================+
|Funcao: MT140GCT | Autor: Reginaldo Borges | Data: 17/05/17|
+-----------------------------------------------------------+
|Descricao: Este ponto de entrada tem o objetivo de validar |
|           as informa��es preenchidas no aCols de cada item| 
|           do pr�-documento de entrada.                    |
|           Validacao na confirmacao.         				|
+===========================================================+
*/                              
                                                          
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

User Function MT140GCT()
              
Local aArea     := GETAREA()
Local aAcols    := PARAMIXB[1]
Local npos      := PARAMIXB[2]
Local nQtdCxEmb := 0

If "MATA103" $ FunName() .And. aAcols[nPos,1] == "01"       
	
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+aAcols[nPos,1]))
		If SB1->B1_XTPEMBV=="1"
			If  SB1->B1_XQTDEMB > 0
				nQtdCxEmb:= SB1->B1_XQTDEMB
				lCancel  := Mod(aAcols[nPos,5],nQtdCxEmb)>0
			Else
				Aviso("Aten��o","Produto "+SB1->B1_COD+" com diverg�ncia, preencha a quantidade da caixa de embarque.",{"Ok"},1)
			Endif
		ElseIf SB1->B1_XTPEMBV=="2"
			If SB1->B1_XQTDSEC > 0
				nQtdCxEmb:= SB1->B1_XQTDSEC
				lCancel  := Mod(aAcols[nPos,5],nQtdCxEmb)>0
			Else
				Aviso("Aten��o","Produto "+SB1->B1_COD+" com diverg�ncia, preencha a quantidade da caixa secund�ria.",{"Ok"},1)
			Endif
		Else
			nQtdCxEmb := 1
			lCancel  := Mod(aAcols[nPos,5],nQtdCxEmb)>0
		EndIf
	Else
		Aviso("Aten��o","Produto "+SB1->B1_COD+" n�o encontrado.",{"Ok"},1)
	Endif
	
	
	If SB1->B1_XCXFECH == "1" .And. SB1->B1_XVLDCXE == "1" .And. lCancel
		Aviso("ATENCAO","Produto "+aAcols[nPos,1]+CHR(13)+CHR(10)+"est� na regra de caixa fechada."+CHR(13)+CHR(10)+"Fazer entrada m�ltipla de "+cValToChar(nQtdCxEmb),{"Ok"},1)
	EndIf
	
	
	RESTAREA(aArea)      
	
EndIF    
                     
Return ()