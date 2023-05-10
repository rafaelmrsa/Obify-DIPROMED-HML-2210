/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT140ACD   �Autor  �Emerson Leal Bruno  Data �  02/05/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada na inclusao  da pre nota para validar o   ���
���          � produto que nao controla endereco a nem lote, para nao     ���
���          � efetuar conferencia via pre nota							  		  ���
�������������������������������������������������������������������������͹��
���Uso       � ACD                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MT140ACD()

Local aArea    		:= GetArea()
Local aAreasSF1 	:= SF1->(GetArea())
Local aAreasSB1 	:= SB1->(GetArea())
Local I				:= 1
Local lExisteConf   :=.F.   

IF ALLTRIM((cFilAnt)) $ ('01|04')
	FOR I := 1 TO LEN(ACOLS)		
		DBSELECTAREA("SB1")
		DBSETORDER(1)  //B1_FILIAL+B1_COD
		DBSEEK(XFILIAL("SB1")+ACOLS[I][1])		

		IF SB1->B1_LOCALIZ == 'S' //.AND. SB1->B1_RASTRO == 'L'		
			lExisteConf:=.T.			
		ENDIF
		
	NEXT
EndIf

IF !lExisteConf //.f.
	SF1->F1_STATCON := '1' //Conferido
ENDIF

RestArea(aAreasSB1)
RestArea(aAreasSF1)
RestArea(aArea)

Return