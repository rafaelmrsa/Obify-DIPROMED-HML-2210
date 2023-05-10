#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO4     �Autor  �Microsiga           � Data �  08/23/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function A103CLAS()
Local _nLin 	:= 0
Local _nPosTes 	:= 0

If Type("l103Class")<>"U" .And. l103Class    
	_nLin    := Len(aCols)
	_nPosTes := aScan(aHeader,{|x|AllTrim(x[2])=="D1_TES"})
	
	aCols[_nLin,_nPosTes] := u_VldTesD1(aCols[_nLin,_nPosTes])
EndIf

Return