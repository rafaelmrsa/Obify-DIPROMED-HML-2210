#INCLUDE 'RWMAKE.CH'
#INCLUDE 'APVT100.CH'
#INCLUDE "TOPCONN.CH"
/*                                                                                                                                                                       fonte
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AV120NFE  �Autor  �  � Data �  12/11/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para tratar confer�ncia f�sica na Pr� Nota���
���          � de acordo com o cadastro de Fornecedor.
�������������������������������������������������������������������������͹��
���Uso       � ACD                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/            
User Function AV120NFE()
Local aArea    := GetArea()
Local aAreaSA2 := SA2->(GetArea())
Local lVldNFE    := .T.

If SA2->A2_CONFFIS <> "1"
			VTAlert("Fornecedor referente a pr� nota n�o esta habilitado em seu cadastro.", "Aviso",.T.,4000)     
			lVldNFE := .F.
EndIf
                                  
RestArea(aAreaSA2)
RestArea(aArea)

Return(lVldNFE)
