#include "rwmake.ch"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  � FA080POS � Autor �   Eriberto Elias   � Data �  30/01/2003   ���
���������������������������������������������������������������������������͹��
���Descricao � Ajusta historico da baixa para imprimir verso do cheque      ���
���          �                                                              ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

User Function FA080POS()
 
_area := GETAREA()

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

DbSelectArea('SA2')
_areaA2 := GETAREA()

DbSetOrder(1)
DbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)

//msgstop(cHist070+SA2->A2_NOME,SE2->E2_FORNECE+SE2->E2_LOJA)

cHist070 := SA2->A2_NOME    
cBenef   := SA2->A2_NOME

RESTAREA(_areaA2)
RESTAREA(_area)

Return(.t.)