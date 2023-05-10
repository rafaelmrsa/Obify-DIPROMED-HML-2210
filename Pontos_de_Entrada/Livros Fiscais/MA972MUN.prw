#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA972MUN  �Autor  �Microsiga           � Data �  02/18/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MA972MUN()                    
Local cAlias 	:= Paramixb[1]
Local aArea  	:= GetArea()  
Local aAreaSA1 	:= SA1->(GetArea())
Local cCodMun 	:= ""

SA1->(dbSetOrder(1))
If SA1->(dbSeek(xFilial("SA1")+&(cALias+"->(F3_CLIEFOR+F3_LOJA)")))
	Do Case
		Case SA1->A1_COD_MUN == "25201" //Jarinu
			cCodMun := "04005"
		Case SA1->A1_COD_MUN == "34401" //Osasco
			cCodMun := "04923"
		Case SA1->A1_COD_MUN == "47809" //Santo Andre
			cCodMun := "06269"
		Case SA1->A1_COD_MUN == "50308" //S�o Paulo
			cCodMun := "01004"
		OtherWise
			cCodMun := "01004"
	End Case
EndIf

RestArea(aArea)      
RestArea(aAreaSA1)

Return cCodMun