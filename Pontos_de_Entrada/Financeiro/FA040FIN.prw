#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA040FIN  �Autor  �Microsiga           � Data �  07/10/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FA040FIN()
Local aArea := GetArea()

If SA1->A1_MSALDO > SA1->A1_XMSALD
	SA1->(RecLock("SA1",.F.))
		SA1->A1_XMSALD := SA1->A1_MSALDO
		SA1->A1_XDMSAL := dDataBase
	SA1->(MsUnlock())
EndIf

RestArea(aArea)
Return