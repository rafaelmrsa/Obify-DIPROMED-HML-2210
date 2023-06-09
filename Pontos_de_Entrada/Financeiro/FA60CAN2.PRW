#include "rwmake.ch"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  � FA60CAN2 � Autor � Maximo Canuto V. neto � Data �  24/07/2013���
���������������������������������������������������������������������������͹��
���Descricao � Atualiza E1_NUMBCO dos t�tulos com boletos impressos na Dipro���
���          � com o numero gravado no campo E1_NCLIDIP                     ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

User Function FA60CAN2()
 
Local _area := GETAREA()

U_DIPPROC(ProcName(0),U_DipUsr()) 


DbSelectArea("SE1")              

If !Empty(Alltrim(SE1->E1_NCLIDIP))
	RecLock("SE1",.F.)
	SE1->E1_NUMBCO  := Alltrim(SE1->E1_NCLIDIP)
	SE1->E1_NCLIDIP := ''
	SE1->(MsUnLock())
EndIf

RESTAREA(_area)

Return(.t.)