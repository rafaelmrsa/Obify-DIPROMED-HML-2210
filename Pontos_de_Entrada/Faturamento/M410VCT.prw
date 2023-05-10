/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M410VCT   �Autor  �Reginaldo Borges    � Data �  29/06/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. permiti que seja alterado o vencimento e valor        ���
���          � das parcelas na aba de duplicatas da Planilha Financeira   ���
���          � do pedido de vendas.                                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#INCLUDE "PROTHEUS.CH"

User Function M410VCT()                                   	
Local _aVencto   := PARAMIXB[1] // Array com as duplicatas
Local aAreaSE4   := SE4->(GetArea())
Local nCont      := 1
Local cDias      := ""
Local cCondpag   := ""
Local dDatAux	 := StoD("")
Local nI		 := 0

SE4->(dbSetOrder(1))
If !Empty(M->C5_CONDPAG) .And. SF4->(dbSeek(xFilial("SF4")+M->C5_CONDPAG))

	cCondAux := AllTrim(SE4->E4_COND)
                                                           
	If !Empty(M->C5_NOTA) .And. !Empty(M->C5_SERIE)
		dDatAux :=POSICIONE("SF2",1,xFILIAL("SF2")+M->C5_NOTA+M->C5_SERIE+M->C5_CLIENTE+M->C5_LOJACLI,"F2_EMISSAO")
	Else        
		dDatAux := dDataBase
	EndIf

	For nI = 1 to Len(_aVencto)		
		If Empty(SubStr(cCondAux,nCont,AT(',',cCondAux)))
			cDias := SubStr(cCondAux,nCont,Len(cCondAux))
		Else
			cDias := SubStr(cCondAux,nCont,AT(',',cCondAux)-1)
		EndIf		
		
		_aVencto[nI][1] := DataValida(dDatAux+Val(cDias),.T.)
		
		nCont := nCont+3		
	Next nI
EndIf

RestArea(aAreaSE4)

Return(_aVencto)