#include "rwmake.ch"       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � SFINE011 � Autor �  NATALINO OLIVEIRA    � Data � 06/06/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao do ano do nosso numero no Layout CNAB PAGAR       ���
���          � Bradesco - PAGFOR                                          ���
���          � SELECIONAR O ANO DO NOSSO NUMERO DO NUMERO CNAB QUANDO NAO ���
���          � TIVER TEM QUE SER COLOCADO "000"                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para Dipromed                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function SFINE011()       


Private _RETANO

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

_RETANO  :=  "000"

If SubStr(SE2->E2_CODBAR,1,3) == "237"

   _RETANO  := StrZero(Val(SubStr(SE2->E2_CODBAR,26,2)),3)

ElseIf SubStr(SE2->E2_LD,1,3) == "237"

   _RETANO  := StrZero(Val(SubStr(SE2->E2_LD,12,2)),3)

EndIf

Return(_RETANO)        
