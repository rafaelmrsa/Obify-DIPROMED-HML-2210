#include "rwmake.ch"        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � SFINE013 � Autor �NATALINO OLIVEIRA      � Data � 06/06/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � VLR DOCUMENTO COD BARRA DA POSICAO 06 - 19, NO ARQUIVO E   ���
���          �DA POSICAO 190-204,QUANDO NAO FOR COD BARRA VAI O VLR do SE2���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para Dipromed                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SFINE013()       

Private _VALOR
U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009
_Valor :="000000000000000"

IF !Empty(SE2->E2_CODBAR)

   _Valor := StrZero(Val(SubStr(SE2->E2_CODBAR,06,14)),15)

ElseIf !Empty(SE2->E2_LD)

   _Valor := StrZero(Val(SubStr(SE2->E2_LD,34,14)),15)

Endif

Return(_Valor)        
