#INCLUDE "PROTHEUS.CH"   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ACD060VE  �Autor  �Microsiga           � Data �  07/03/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ACD060VE()
Local aArea := SDA->(GetArea())

If cEmpAnt+cFilAnt=="0401" .And. !(FWIsInCallStack("ACDV063"))
	SDA->(dbSetOrder(4))
	If SDA->(dbSeek(xFilial("SDA")+cNota+cSerie))
   		cArmazem := SDA->DA_LOCAL
 	EndIf
EndIf

RestArea(aArea)

Return .T.